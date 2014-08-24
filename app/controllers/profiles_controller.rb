class ProfilesController < ApplicationController

  #проверка session-token + регистрации для всех запросов, кроме :signin,:signUp, confirm
  before_action :set_user_from_session_and_check_registration,       only: [:social_money_send, :social_money_charge, :recieve_pay, :social_money_get, :get_new_requests]
  #проверка session-token БЕЗ регистрации для всех запросов только для get_profile
  before_action :set_user_from_session, except: [:signin,:signup, :confirm, :social_money_send, :social_money_charge, :recieve_pay, :social_money_get, :get_new_requests]
  #проверка app-token только для  :signin,:signUp
  before_action :set_app_profile, only: [ :signin,:signup]
  #before_action :save_profile_params, only: [:save_profile]

  before_action :signin_params, only: [:signin]
  before_action :signup_params, only: [:signup]
  before_action :confirm_params, only: [:confirm]

  skip_before_filter :verify_authenticity_token

  Time::DATE_FORMATS[:session_date_time] = "%Y-%m-%d %k:%M"

  def get_profile
    @profile = Object
    @profile =
        {
            :profile=>
                {
                    :email=>@user.email,
                    :type=>@user.wallet_type==1?'personal':@user.wallet_type==2?'green':@user.wallet_type==3?'biz':@user.wallet_type==4?'biz partner':@user.wallet_type==5?'pale':'unknown', #available types[personal, green, biz, biz partner, pale]
                    :firstName=>@user.name,
                    :lastName=>@user.surname,
                    :phone=>@user.phone,
                    :fid=>@user.fb_token,
                    :birthday=>@user.birthday,
                    :address=>@user.address,
                    :company_name=>@user.company_name,
                    :web_site=>@user.web_site,
                    :confirmed=>(@user.confirm_type!=nil && @user.confirm_type!=0),
                    :reg_number=>@user.company_reg_number,
                    :cp_name=>@user.contact_person_name,
                    :cp_position=>@user.contact_person_position,
                    :cp_birth=>@user.contact_person_date_of_birth,
                    :cp_phone=>@user.contact_person_phone
                }
        }

    respond_to do |format|
      format.json { render :json => @profile.as_json, status: :ok }
    end
  end

  def save_profile
   profile =save_profile_params

    #User was successfully created.
    unless (@user.email)
      @user.reg_token= SecureRandom.hex;
      @user.email =profile[:email];
      link="https://api.onlinepay.com/confirm?token=#{@user.reg_token}";
     send_confirm_mail(@user, link);
    end
    if profile[:firstName]
      @user.name=profile[:firstName]
    end
    if profile[:lastName]
      @user.surname=profile[:lastName]
    end
    if profile[:phone]
      @user.phone=profile[:phone]
    end
    if  profile[:fid]
      @user.fb_token= profile[:fid]
    end
    if profile[:birthday]
      @user.birthday=profile[:birthday]
    end
    if profile[:address]
      @user.address=profile[:address]
    end
    if profile[:company_name]
      @user.company_name=profile[:company_name]
    end
    if profile[:web_site]
      @user.web_site=profile[:web_site]
    end
    # Registration number – рег номер.
    if profile[:reg_number]
      @user.company_reg_number=profile[:reg_number]
    end
    # Contact person – контакт компании (Имя и фамилия).
    if profile[:cp_name]
      @user.contact_person_name=profile[:cp_name]
    end
    # Contact person’s position - Позиция контактного лица.
    if profile[:cp_position]
      @user.contact_person_position=profile[:cp_position]
    end
    # Contact person’s date of birth.
    if profile[:cp_birth]
      @user.contact_person_date_of_birth=profile[:cp_birth]
    end
    # Contact person’s phone (including country code).
    if profile[:cp_phone]
      @user.contact_person_phone=profile[:cp_phone]
    end

    @user.save!
    get_profile
  end

  def signin
    #if(@sign_in.accountid) #decline authorisation via email+fb_token
      # поиск аккаунта по емэйл
      newUser = Profile.find_by_user_token(@sign_in.accountid);
   # else
   #   @newUser = Profile.find_by_fb_token(@sign_in.fb_token);
   # end

    if(newUser && !AccountValidators.get_fbid_match(@sign_in.accountid))
      #checking user password
      user_password = Digest::SHA2.hexdigest(newUser.salt + @sign_in.password);
    end

    unless newUser && (user_password == newUser.password)
        @result = Object
        @result = {:result => 5 ,:message => "user not found or incorrect password"}
        respond_to do |format|
          format.json { render :json => @result.as_json, status: :unauthorized }
        end
        return;
    end

    @session=create_session(newUser);
    sendmail(newUser, "sign-in");
    return_session(@session)
  end

  def check_session
    set_user_from_session
    return_session(@user.session)
  end

  def signOff
    @result = Object
    @result = {:result => 0 ,:message => "session destroyed"}
    if(@user.session)
      unless(@user.session.delete)
        @result = {:result => 10 ,:message => "session destroy error"}
      end
    end
    respond_to do |format|
      format.json { render :json => @result.as_json, status: :unauthorized }
    end
  end

  def signup
    @log = Logger.new(STDOUT)
    @log.level = Logger::INFO
   # @log.info('@sign_up')
   # @log.info( @sign_up)
   # @log.info( @sign_up.accountid)

    @newUser = Profile.new;
    @newUser.user_token = @sign_up.accountid;

#todo вынести все это безобразие в отдельный модуль
    facebookId =AccountValidators::get_fbid_match(@sign_up.accountid)

    if(facebookId)
      @newUser.fb_token=facebookId[0]
      @log.info("facebookId:#{facebookId}")
    else
      emailId = AccountValidators::get_email_match(@sign_up.accountid)
      if(emailId)
        @newUser.email=emailId[0];
        @log.info("emailId:#{emailId}")
      else
        phone =  AccountValidators::get_phone_match(@sign_up.accountid)
        if(phone)
          @newUser.phone=@sign_up.accountid
          @log.info("phone:#{phone}")
        else
          @log.info("not registered. accountId have incorrect format")
          @result = Object
          @result = {:result => 4,:message => "not registered. accountId have incorrect format"}
          respond_to do |format|
            format.json { render :json => @result.as_json, status: :conflict }
          end
          return;
        end
      end
    end

    unless @newUser.fb_token #для  FB account пароль не требуется
      if(@sign_up.password1.length <8)
        to_short_password
        return;
      end
      @newUser.salt = SecureRandom.hex;
      @newUser.password = Digest::SHA2.hexdigest(@newUser.salt + @sign_up.password1);
    end

    if(AccountValidators::is_test_account(@sign_up.accountid))
      @newUser.reg_token = 'confirm-token';
    else
      @newUser.reg_token= SecureRandom.hex;
    end
    @newUser.confirm_type=0;#not confirmed
# добавляем запись

    if(!@newUser.save)
      @result = Object
      @result = {:result => 4,:message => "not registered"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :error }
      end
      return;
    end

    link="https://api.onlinepay.com/confirm?token=#{@newUser.reg_token}";
    @log.debug(link);
    #User was successfully created.
    if (@newUser.email)
          send_confirm_mail(@newUser, link);
    end

    return_session(create_session(@newUser));
  end

  def confirm
    @result = Object
    reg_token = request.params['confirm'];

      unless reg_token
        @result = {:result => 9 ,:message => "confirm token not valid"}
        respond_to do |format|
          format.json { render :json => @result.as_json, status: :unauthorized }
        end
        return;
    end

    user = Profile.find_by_reg_token(reg_token);

    unless user
      @result = {:result => 5 ,:message => "user not found or incorrect password"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :unauthorized }
      end
      return;
    end

    unless user.reg_token == reg_token
      @result = {:result => 9 ,:message => "confirm token not valid"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :unauthorized }
      end
      return;
    end

    @result =  {:result=>0, :message=>"ok" }
    if user && user.confirm_type!=0
      @result =  {:result=>0, :message=>"already confirmed" }
    end

    unless user.update(confirm_type:1)
      @result = {:result => 14 ,:message => "registration not confirmed. internal server error"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :internal_server_error }
      end
      return;
    end

    user.update(reg_token:nil);

    @getResult=Object.new
    @getResult={:confirm=>@result}
    respond_to do |format|
      format.json { render :json => @getResult.as_json, status: :ok }
    end
  end

  def tabs
    @log = Logger.new(STDOUT)
    @log.level = Logger::INFO
    #validating user token
    @tabs = ProfilesHelper::get_tabs_format(@user,@user.session.application);
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
    feeds = Array.new
    queryPrivacy=params.require(:global)
    Feed.where(['privacy = ?', queryPrivacy]).includes(:from_profile, :to_profile).each { |feed|
      feeds << {
          :id => feed.id,
          :message => feed.message,
          :from => "#{feed.from_profile.name} #{feed.from_profile.surname}",
          :from_id => feed.from_profile.user_token,
          :to => "#{feed.to_profile.name} #{feed.to_profile.surname}",
          :to_id => feed.to_profile.user_token,
          :global => feed.privacy,
          :date => feed.created_at.to_s(:session_date_time),
          :likes => feed.likes,
          :paymentId => feed.id,
          :for => feed.description,
          :pic => feed.from_profile.pic_url,
          :type => ProfilesHelper.get_feed_type_string(feed.fType) #available types[charge, charge new, request, request new]
      } }

      feed_container={:feed=>feeds}

      respond_to do |format|
        format.json { render :json => feed_container.as_json, status: :ok }
      end
  end

  def like
    @like=Object.new
    @like={:result=>0}
    respond_to do |format|
      format.json { render :json => @like.as_json, status: :ok }
    end
  end

  #methods with required confirmation email
  def social_money_send

    #на исходном кошельке проверяется наличие необходимой суммы

    #если валюты кошельков различаются, то производится конвертация в валюту назначения
    #на исходном кошельке замораживается необходимая сумма
    #шлется запрос второму кошельку на акцепт суммы
    #рассылка уведомлений
  end

  def recieve_pay

    #находится запрос в кошельке текущего пользователя по ИД запроса
    #с исходнго кошелька списывается замороженная сумма
    #на кошелек назначения эта сумма зачисляется
    #запрос помечается как принятый
    #рассылка уведомлений
  end

  def social_money_charge
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
  def checkSessionValid(session)
    unless(session)
      return false;
    end

    if(session.TimeToDie<Time.now)
      return false;
    end
    return true;
  end

  def create_session(user)

   # if(user.email == "vk100@onlinepay.com")
    if(AccountValidators::is_test_account(user.email))
      sessionId = 'test-token';
    else
      sessionId=SecureRandom.hex;
      if(Session.find_by_SessionId(sessionId))
        sessionId=SecureRandom.hex;
      end
    end

    unless (user.session)
      session=Session.new
      session.SessionId= sessionId;
      session.application=@app
      session.TimeToDie= Time.now + 1.hour;
      user.session=session
    else
      session= user.session;
      session.SessionId=sessionId;
      session.application=@app
      session.TimeToDie= Time.now + 1.hour;
    end

    session.save;
    return session;
  end

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
      format.json { render :json => @result.as_json, status: :conflict }
    end
  end

  def to_short_account
    @result = Object
    @result = {:result => 13,:message => "to short accountid"}
    respond_to do |format|
      format.json { render :json => @result.as_json, status: :conflict }
    end
  end

  def to_short_password
    @result = Object
    @result = {:result => 12,:message => "to short password"}
    respond_to do |format|
      format.json { render :json => @result.as_json, status: :conflict }
    end
  end

  def sendmail(sign_up, subject)
    if sign_up.valid?
      Emailer.email_lead(sign_up.email, subject).deliver;
    end
  end

  def send_confirm_mail(sign_up, link)
    #if sign_up.valid?
      Emailer.email_confirm(sign_up.email, link).deliver;
    #end
  end

  def return_session(session)
    @result = {:result => 0 ,:message => "ok", :expiration => session ? session.TimeToDie.to_s(:session_date_time) : "", :session => session ? session.SessionId : ""}
    respond_to do |format|
      format.json { render :json => @result.as_json, status: :ok }
    end
  end

  def set_user_from_session_and_check_registration
    set_user_from_session
    if(@user)
      check_user_token_valid(@user);
    end
  end

  def set_user_from_session
    session_token = request.headers['session-token'];
    #collecting some data for user
    session = Session.find_by_SessionId(session_token);
    unless(checkSessionValid(session))
      @user=nil
      result = {:result => 11,:message =>"session not valid", :expiration => session ? session.TimeToDie.to_s(:session_date_time) : "", :session => session ? session.SessionId : "" }
      respond_to do |format|
        format.json { render :json => result.as_json, status: :unauthorized }
      end
      return;
    end
    @user=session.profile;
  end

  def set_app_profile
    @app_token = request.headers['app-token'];
    @app = Application.find_by_appToken(@app_token);
    check_app_token_valid(@app);
  end

  def check_user_token_valid(user)
    if(user &&  (user.confirm_type==0))
      result = ((user && user.confirm_type==0)? {:result => 6,:message => 'token not valid'} : {:result => 15,:message => 'confirmation required' });
      respond_to do |format|
        format.json { render :json => result.as_json, status: :unauthorized }
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
  # @reg_token = params.require(:confirm).permit(:token)['token']
  end

  # Never trust parameters from the scary internet, only allow the white list through.
    def signin_params
      @sign_in = SignIn.new(params.require(:signin).permit(:accountid,:password))
    end

  # Never trust parameters from the scary internet, only allow the white list through.
  def signup_params
    @sign_up = SignUp.new( params.require(:signup).permit(:accountid,:password1,:password2))

    if(@sign_up.password1!=@sign_up.password2)
      @result = Object
      @result = {:result => 1,:message => "password1 not equal password2"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :error }
      end
      @sign_up=nil;
      return;
    end
   #unless(@sign_up.phone)
   #  decline_required_param('phone');
   #  @sign_up=nil;
   #  return;
   #end
  # unless(@sign_up.email || @sign_up.fb_token)
  #   unless(@sign_up.fb_token)
  #     decline_required_param('fb_token');
  #     @sign_up=nil;
  #     return;
  #{ }"#   end
      unless(@sign_up.accountid)
        decline_required_param('accountid');
        @sign_up=nil;
        return;
      end
   # end

    unless(@sign_up.accountid )
      decline_already_registered
      return;
    end

    if(@sign_up.accountid.length <8)
      to_short_account
      return;
    end

    if( Profile.find_by_user_token(@sign_up.accountid))
      decline_already_registered
      return;
    end
    if(Profile.find_by_phone(@sign_up.accountid) )
      decline_already_registered
      return;
    end
    if(Profile.find_by_fb_token(@sign_up.accountid) )
      decline_already_registered
      return;
    end
    if(Profile.find_by_email(@sign_up.accountid))
      decline_already_registered
      return;
    end
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def catalog_params
    params.require(:PathModel).permit(:path)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def save_profile_params
    params.require(:profile)
    .permit(:email,
      :firstName,
      :firstName,
      :lastName,
      :phone,
      :fid,
      :address,
      :company_name,
      :web_site,
      :reg_number,
      :cp_name,
      :cp_position,
      :cp_birth,
      :cp_phone)
    end

end
