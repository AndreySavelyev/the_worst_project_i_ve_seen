class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy]
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
    #проверка входных данных
    @sign_in = SignIn.new(signin_params);
    @userNotFound=true;

    if(@sign_in.email !=nil)
      if(@sign_in.fb_token == nil) #decline authorisation via email+fb_token
        # поиск аккаунта по емэйл
        @newUser = Profile.find_by_email(@sign_in.email);
        if(@newUser != nil)
          @userNotFound=false;
        end
      end
    else if(@sign_in.fb_token !=nil)
           #поиск по FB ID
           if(@userNotFound)
             @newUser = Profile.find_by_fb_token(@sign_in.fb_token);
             @userNotFound =( @newUser == nil);
           end
         end
    end

    if(!@userNotFound)
      #checking user password
      @user_password = Digest::SHA2.hexdigest(@newUser.salt + @sign_in.password);
      if(@user_password != @newUser.password)
        @userNotFound=true;
      end
    end

    if(@userNotFound)
      @newUser = Profile.new
      @newUser.result = 5;
      @newUser.message = "user not found or incorrect password";
      respond_to do |format|
        format.json { render :signup_error, status: :error, location: profiles_url }
      end
      return;
    end

    sendmail(@sign_in, "sign-in");
  end

  def signup
    @sign_up = SignUp.new(signup_params)
    @log = Logger.new(STDOUT)
    @log.level = Logger::INFO
    @log.info(@sign_up)

    # найти юзера в бд
    @searchResult =  Profile.find_by_email(@sign_up.email)

    @newUser = Profile.new;
    # если не нашли, значит продолжаем
    if(@sign_up.password1!=@sign_up.password2)
      @newUser.result = 1;
      @newUser.message = "password1 not equal password2";
      respond_to do |format|
        #оставил перенаправление на неработающую страницу сознательно
        format.json { render :signup_error, status: :error, location: profiles_url }
      end
      return;
    end

    if (@searchResult!=nil)
      @newUser.result = 2;
      @newUser.message = "already registered";
      sendmail(@sign_up, "already registered");
      respond_to do |format|
        #оставил перенаправление на неработающую страницу сознательно
        format.json { render :signup_error, status: :error, location: profiles_url }
      end
      return;
    end

    @newUser.email = @sign_up.email;
    @newUser.salt = SecureRandom.hex;
    @newUser.password = Digest::SHA2.hexdigest(@newUser.salt + @sign_up.password1);
    # добавляем запись
    #if\
    if(!@newUser.save)
      @newUser.result = 4;
      @newUser.message = "registered";
      #  #some error
      respond_to do |format|
        #оставил перенаправление на неработающую страницу сознательно
        format.json { render :signup_error, status: :error, location: profiles_url }
      end
      sendmail(@sign_up, "not registered");
      return;
    end

    @newUser.result = 0;
    @newUser.message = "registered";
    #  #User was successfully created.
    sendmail(@sign_up, "registered");
    @newUser.user_token = @newUser.id;
  end

  def confirm
    #проверка входных данных
    @sign_in = SignIn.new(confirm_params);
    @userNotFound=true;
    # поиск аккаунта по емэйл
    @newUser = Profile.find_by_user_token(@sign_in.user_token);
    if(@newUser != nil)
      @userNotFound=false;
    end

    @newUser = Profile.new
    @newUser.result = 0;
    @newUser.message = "ok";
    if(@userNotFound)
      @newUser.result = 6;
      @newUser.message = "token not valid";
      respond_to do |format|
        format.json { render :signup_error, status: :error, location: profiles_url }
      end
      return;
    end

    respond_to do |format|
      format.json { render :signup_error, status: :ok, location: profiles_url }
    end
  end

  # GET /tabs
  def tabs
    @app_token= request.headers['app-token'];
    @user_token= request.headers['user-token'];
    @profile = Tabs.new;
    @profile.services=Array.new(1);
    @testService=Services.new;
    @testService.promolink="http:\\ya.ru";
    @profile.services[0]=@testService;
  end

  def sendmail(sign_up, subject)
    if(true)#turning off email sending
      return;
    end
    if sign_up.valid?
      #respond_to do |format|
        Emailer.email_lead(sign_up.email, subject).deliver;
#        format.json {render json: sign_up, status: :ok, content_type: 'application/json'}
 #     end
#    else
#      respond_to do |format|
#        format.json {render json: { :errors => sign_up.errors.as_json }, status: 420, content_type: 'application/json'}
#      end
    end
  end


  # GET /profiles
  # GET /profiles.json
  def index
    @profiles = Profile.all
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
  end

  # GET /profiles/1/edit
  def edit
  end

  # POST /profiles
  # POST /profiles.json
  def create
    @profile = Profile.new(profile_params)

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: 'Profile was successfully created.' }
        format.json { render :show, status: :created, location: @profile }
      else
        format.html { render :new }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /profiles/1
  # PATCH/PUT /profiles/1.json
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :edit }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    @profile.destroy
    respond_to do |format|
      format.html { redirect_to profiles_url, notice: 'Profile was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @profile = Profile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(:user_token, :fb_token, :pic_url, :name, :surname, :phone, :iban, :reg_num, :birthday, :company_name, :email, :password, :salt, :created_at, :updated_at)
    end

  # Never trust parameters from the scary internet, only allow the white list through.
  def confirm_params
    params.require(:signin).permit(:user_token)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def signin_params
    params.require(:signin).permit(:email,:password,:fb_token, :phone)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def signup_params
    params.require(:signup).permit(:email, :password1, :password2)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def profile_params
    params.require(:updatep_rofile).permit(:email, :password, :fb_token, :phone)
  end
end
