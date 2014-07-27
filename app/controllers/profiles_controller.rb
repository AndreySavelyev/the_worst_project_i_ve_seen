class ProfilesController < ApplicationController
  before_action :set_user_profile, except: [:signin,:signup, :confirm]
  before_action :set_app_profile
  before_action :signin_params, only: [:signin]
  before_action :signup_params, only: [:signup]
  before_action :confirm_params, only: [:confirm]

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

    unless @newUser && (@user_password == @newUser.password)
        @result = Object
        @result = {:result => 5 ,:message => "user not found or incorrect password"}
        respond_to do |format|
          format.json { render :json => @result.as_json, status: :unauthorized }
        end
      return;
    end

    check_user_token_valid(@newUser);
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
    @newUser.reg_token= SecureRandom.hex;
    @newUser.confirm_type=0;#not confirmed
    # добавляем запись
    #if\
    if(!@newUser.save)
      @result = Object
      @result = {:result => 4,:message => "not registered"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :error }
      end
    end

    @newUser.result = 0;
    @newUser.message = "registered";
    #  #User was successfully created.
    sendmail(@sign_up, "registered");
  end

  def confirm
    @result = Object
    @user_token = request.headers['user-token'];
    @user = Profile.find_by_user_token(@user_token);

    unless @user
      @result = {:result => 5 ,:message => "user not found or incorrect password"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :unauthorized }
      end
      return;
    end

    unless @user.reg_token == @reg_token
      @result = {:result => 9 ,:message => "confirm token not valid"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :unauthorized }
      end
      return;
    end

    @result =  {:result=>0, :message=>"ok" }
    if @user && @user.confirm_type!=0
      @result =  {:result=>0, :message=>"already confirmed" }
    end

    unless @user.update(confirm_type:1)
      @result = {:result => 10 ,:message => "registration not confirmed. internal server error"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :internal_server_error }
      end
      return;
    end


    @getResult=Object.new
    @getResult={:confirm=>@result}
    respond_to do |format|
      format.json { render :json => @getResult.as_json, status: :ok }
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
    @feeds = Array.new
    @feeds << {
        :type=>"charge", #available types[charge, charge new, request, request new]
        :global=> 0,
        :likes=> 34,
        :date=>"2014-12-01",
        :pic=> "url",
        :id=> "fgghh56788ffhjj"
    }
    @feed=Object.new
    @feed={:feed=>@feeds}

    respond_to do |format|
      format.json { render :json => @feed.as_json, status: :ok }
    end
  end
  def like
    @like=Object.new
    @like={:result=>0}
    respond_to do |format|
      format.json { render :json => @like.as_json, status: :ok }
    end
  end
  def social_money_send
    @like=Object.new
    @like={:result=>0}
    respond_to do |format|
      format.json { render :json => @like.as_json, status: :ok }
    end
  end
  def social_money_charge
    @like=Object.new
    @like={:result=>0}
    respond_to do |format|
      format.json { render :json => @like.as_json, status: :ok }
    end
  end
  def recieve_pay
    @like=Object.new
    @like={:result=>0}
    respond_to do |format|
      format.json { render :json => @like.as_json, status: :ok }
    end
  end
  def social_money_get

    @gets = Array.new
    @gets <<  {
        :id =>"salkjh234jhkjfh9432y",
        :fromID => "salkjh234jhkjfh9432y",
        :name => "John Smith",
        :pic =>  "url",
        :type =>  "charge", #charge request or money send request
        :amount => 100.00,
        :currency => "eur",
        :message => "Please send me some money for a new car."
    }
    @getResult=Object.new
    @getResult={:moneyRequest=>@gets}

    respond_to do |format|
      format.json { render :json => @getResult.as_json, status: :ok }
    end
  end

  def get_new_requests
    @gets = Object
    @gets =  {:new=>5 }
    @getResult=Object.new
    @getResult={:requests=>@gets}
    respond_to do |format|
      format.json { render :json => @getResult.as_json, status: :ok }
    end
  end


  :private
  def decline_required_param(param_name)
    @result = Object
    @result = {:result => 8,:message => "require param"}
    respond_to do |format|
      format.json { render :json => @result.as_json, status: :error }
    end
  end

  def decline_already_registered
    @result = Object
    @result = {:result => 2,:message => "already registered"}
    respond_to do |format|
      format.json { render :json => @result.as_json, status: :error }
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
    if(!user ||  (user.confirm_type==0))
      @result = Object
      @error_text=((user && user.confirm_type==0)?"confirmation required":"token not valid");
      @result = {:result => 6,:message =>@error_text }
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :unauthorized }
      end
      return;
    end
  end

  def check_app_token_valid(app)
    unless(app)
      @result = Object
      @result = {:result => 7,:message => "app token not valid"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :unauthorized }
      end
      return;
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def confirm_params
   @reg_token = params.require(:confirm).permit(:token)['token']
  end

  # Never trust parameters from the scary internet, only allow the white list through.
    def signin_params
      @sign_in = SignIn.new(params.require(:signin).permit(:email,:password,:fb_token, :phone))
    end

  # Never trust parameters from the scary internet, only allow the white list through.
  def signup_params
    @sign_up = SignUp.new( params.require(:signup).permit(:email,:password1,:password2,:phone, :fb_token))

    if(@sign_up.password1!=@sign_up.password2)
      @result = Object
      @result = {:result => 1,:message => "password1 not equal password2"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :error }
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
