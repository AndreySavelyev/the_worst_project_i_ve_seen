class ProfilesController < ApplicationController
  before_action :set_user_profile, only: [:tabs, :confirm]
  before_action :set_app_profile, only: [:tabs]
  before_action :signin_params, only: [:signin]
  before_action :signup_params, only: [:signup]

  skip_before_filter :verify_authenticity_token

  def update_profile
    #проверка входных данных
    @sign_in = UpdateProfile.new(profile_params);
    # поиск аккаунта по емэйл
    @newUser = Profile.find_by_email(@sign_in.email);
  # проверка текущего пароля
  # если указан второй пароль, значит идет смена пароля
  #
  end

  def signin
    if(@sign_in.email) #decline authorisation via email+fb_token
      # поиск аккаунта по емэйл
      @newUser = Profile.find_by_email(@sign_in.email);
    else
      @newUser = Profile.find_by_fb_token(@sign_in.fb_token);
    end

    if(@newUser)
      #checking user password
      @user_password = Digest::SHA2.hexdigest(@newUser.salt + @sign_in.password);
    end

    unless @newUser || (@user_password == @newUser.password)
      @newUser = Profile.new
      @newUser.result = 5;
      @newUser.message = "user not found or incorrect password";
      respond_to do |format|
        format.json { render :signup_error, status: :unauthorized, location: profiles_url }
      end
      return;
    end

    sendmail(@sign_in, "sign-in");
  end

  def signup
    @log = Logger.new(STDOUT)
    @log.level = Logger::INFO
    @log.info('@sign_up')
    @log.info( @sign_up)


    if(@sign_up.phone && Profile.find_by_phone(@sign_up.phone) )
      decline_already_registered
      return;
    end
    if(@sign_up.fb_token && Profile.find_by_fb_token(@sign_up.fb_token) )
      decline_already_registered
      return;
    end
    if(@sign_up.email && Profile.find_by_email(@sign_up.email))
      decline_already_registered
      return;
    end

    @newUser = Profile.new;
    @newUser.email = @sign_up.email;
    @log.info( @sign_up.fb_token)
    @newUser.fb_token = @sign_up.fb_token;
    @newUser.salt = SecureRandom.hex;
    @newUser.password = Digest::SHA2.hexdigest(@newUser.salt + @sign_up.password1);
    @newUser.phone = @sign_up.phone;
    @newUser.user_token = SecureRandom.hex;
    # добавляем запись
    #if\
    if(!@newUser.save)
      @newUser.result = 4;
      @newUser.message = "not registered";
      respond_to do |format|
        format.json { render :signup_error, status: :error, location: profiles_url }
      end
      sendmail(@sign_up, "not registered");
      return;
    end

    @newUser.result = 0;
    @newUser.message = "registered";
    #  #User was successfully created.
    sendmail(@sign_up, "registered");
  end

  def confirm

    @newUser = Profile.new(            :result => 0,            :message => "ok")
    respond_to do |format|
      format.json { render :signup_error, status: :ok, location: profiles_url }
    end
  end

  # GET /tabs
  def tabs
    @log = Logger.new(STDOUT)
    @log.level = Logger::INFO
    #validating user token
    @tabs = ProfilesHelper::get_tabs_format(@user,@app);
    respond_to do |format|
      format.json { render :json => @tabs.as_json, status: :ok }
    end
  end

  def brief
    @hotOffers = Object
    @hotOffers =
        {
            :brief=>{
                :likes => '231',
                :currency => 'usd',
                :balance => '30.380',
                :name => 'john smith',
                :mood => 4,
                :userpic => 'url'
            }
        }
    respond_to do |format|
      format.json { render :json => @hotOffers.as_json, status: :ok }
    end
  end

  def catalog
    #@path = PathModel.new(catalog_params)

    @catalog = Object
    @catalog =
        {
            :catalog=>{
                :id=>"84574vgdxgugdxgy",
                :pic=> "url",
                :path=> "/shopping/tvsets",
                :name=>"tv sets",
            }
        }

    respond_to do |format|
      format.json { render :json => @catalog.as_json, status: :ok }
    end
  end

  def feed
    #@path = PathModel.new(catalog_params)

    @hotOffers = Array.new
    @hotOffers << {
        :id => '84574vgdxgugdxgy',
        :pic => 'url',
        :path => 'usd',
        :name => '30.380'
    }
    respond_to do |format|
      format.json { render :json => @hotOffers.as_json, status: :ok }
    end
  end

  private
  def decline_required_param(param_name)
    @newUser = Profile.new
    @newUser.result = 8;
    @newUser.message = "require param #%param_name%";
    sendmail(@sign_up, "already registered");
    respond_to do |format|
      #оставил перенаправление на неработающую страницу сознательно
      format.json { render :signup_error, status: :error, location: profiles_url }
    end
    return;
  end

  def decline_already_registered
    @newUser = Profile.new
    @newUser.result = 2;
    @newUser.message = "already registered";
    sendmail(@sign_up, "already registered");
    respond_to do |format|
      #оставил перенаправление на неработающую страницу сознательно
      format.json { render :signup_error, status: :error, location: profiles_url }
    end
  end

  def sendmail(sign_up, subject)
    if sign_up.valid?
      Emailer.email_lead(sign_up.email, subject).deliver;
    end
  end

  def set_user_profile
    @user_token = request.headers['user-token'];
    #collecting some data for user
    @user = Profile.find_by_user_token(@user_token);
    check_user_token_valid(@user);
  end

  def set_app_profile
    @app_token = request.headers['app-token'];
    @app = Application.find_by_appToken(@app_token);
    check_app_token_valid(@app);
  end

  def check_user_token_valid(user)
    unless(user)
      @newUser = Profile.new;
      @newUser =
          {
              :result => 6,
              :message => "app token not valid"
          }
      respond_to do |format|
        format.json { render :signup_error, status: :unauthorized, location: profiles_url }
      end
      return;
    end
  end

  def check_app_token_valid(app)
    unless(app)
      @newUser = Profile.new;
      @newUser =
          {
              :result => 7,
              :message => "app token not valid"
          }
      respond_to do |format|
        format.json { render :signup_error, status: :unauthorized, location: profiles_url }
      end
      return;
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def confirm_params
    params.require(:signin).permit(:user_token)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def signin_params
    @sign_in = SignIn.new(params.require(:signin).permit(:email,:password,:fb_token, :phone))
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def signup_params
    @sign_up = SignUp.new( params.require(:signup).permit(:email,:password1,:password2,:phone, :fb_token))

    if(@sign_up.password1!=@sign_up.password2)
      @newUser = Profile.new;
      @newUser.result = 1;
      @newUser.message = "password1 not equal password2";
      respond_to do |format|
        #оставил перенаправление на неработающую страницу сознательно
        format.json { render :signup_error, status: :not_implemented, location: profiles_url }
      end
      @sign_up=nil;
      return;
    end
    unless(@sign_up.phone)
      decline_required_param('phone');
      @sign_up=nil;
      return;
    end
    unless(@sign_up.email || @sign_up.fb_token)
      unless(@sign_up.fb_token)
        decline_required_param('fb_token');
        @sign_up=nil;
        return;
      end
      unless(@sign_up.email)
        decline_required_param('email');
        @sign_up=nil;
        return;
      end
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def profile_params
    params.require(:updatep_rofile).permit(:email, :password, :fb_token, :phone)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def catalog_params
    params.require(:PathModel).permit(:path)
  end
end
