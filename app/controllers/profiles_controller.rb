require 'wallet_module.rb'
require 'friends_helper.rb'
class ProfilesController < ApplicationController

include WalletModule
include FriendsHelper

  #проверка session-token + регистрации для всех запросов, кроме :signin,:signUp, confirm
  before_action :set_user_from_session_and_check_registration, only: [:social_money_send, :social_money_charge, :recieve_pay, :social_money_get, :get_new_requests]
  #проверка session-token БЕЗ регистрации для всех запросов только для get_profile
  before_action :set_user_from_session, except: [:processing_callback, :signin,:signup, :confirm, :social_money_send, :social_money_charge, :recieve_pay, :social_money_get, :get_new_requests]
  #проверка app-token только для  :signin,:signUp
  before_action :set_app_profile, only: [ :signin,:signup]
  #before_action :save_profile_params, only: [:save_profile]

  before_action :signin_params, only: [:signin]
  before_action :signup_params, only: [:signup]
  before_action :confirm_params, only: [:confirm]

  skip_before_filter :verify_authenticity_token

  Time::DATE_FORMATS[:session_date_time] = "%Y-%m-%d %k:%M"

def add_currency_rate
  from_currency = params.require(:rates).permit(:from_currency)
  to_currency = params.require(:rates).permit(:to_currency)
  rate = params.require(:rates).permit(:rate)
  date = params.require(:rates).permit(:date)

  #is_exist_newer_rate = ChangeRate.where("CurrencyTo = :to_currency AND CurrencyFrom = :from_curerncy AND Rate = :rate AND SetUpDate >= :date",
  #                 {to_currency: to_currency, from_currency: from_currency, rate: rate, date: date }).any?
  # а ведь по большому счету это не важно, сущесвтует ли более новый курс при добавлении более старого. использоваться будет курс новее

  new_rate = ChangeRate.new
  new_rate.CurrencyTo = IsoCurrency.find_by_Alpha3Code(to_currency).Alpha3Code
  new_rate.CurrencyFrom = IsoCurrency.find_by_Alpha3Code(from_currency).Alpha3Code
  new_rate.SetUpDate = date
  new_rate.Rate = rate #целое число, что с ним делать
  new_rate.save!

  operation_result = {
      :from => new_rate.CurrencyFrom,
      :to => new_rate.CurrencyTo,
      :rate => new_rate.Rate,
      :date => new_rate.SetUpDate}
  respond_to do |format|
    format.json { render :json => operation_result.as_json, status: :ok }
  end
end

def get_currency_rates_json
  ChangeRate.group(:CurrencyFrom).group(:CurrencyTo).
  operation_result = {
      :from => rate.CurrencyFrom,
      :to => rate.CurrencyTo,
      :rate => rate.Rate,
      :date => rate.SetUpDate}
  respond_to do |format|
    format.json { render :json => operation_result.as_json, status: :ok }
  end
end

def get_currency_rates(source_currency, destination_currency)
  newest_rate = ChangeRate.where("CurrencyTo = :to_currency AND CurrencyFrom = :from_currency ",
                   { to_currency: source_currency.Alpha3Code, from_currency:  destination_currency.Alpha3Code }).last
  return newest_rate
end

def social_friends_invite # пригласить друга
  invite_params=params.require(:invite)#.require(accountid: [])
  #result_array = Array.new
  operation_result = {:result => 0 }
  invite_params.each  { |invition|
    #result_array<<{
    #    :accountid=>invition[:accountid],
    #    :result=>
             FriendsHelper.invite_new_friend(@user,invition[:accountid])
    #}
  }

#  unless invite_params && invite_params[:accountid]
#   operation_result = {:result => 1 }
#  else
#     operation_result = {:result => FriendsHelper.invite_new_friend(@user,invite_params[:accountid])?0:1 }
#  end
  respond_to do |format|
    format.json { render :json => operation_result.as_json, status: :ok }
  end
end

def social_feed_viewed #пометить новость прочитанным
  feed_id=params.require(:feedid)
  getResult= FriendsHelper.mark_feed_as_viewed(@user, feed_id)?0:1
  operation_result = {:result => getResult }
  respond_to do |format|
    format.json { render :json => operation_result.as_json, status: :ok }
  end
end

def social_friends_request #добавить в друзья
  friend_id=params.require(:accountid)
  #todo отправка емейла
  friend = Profile.find_by_user_token(friend_id)
  @getResult={:created=> FriendsHelper.create_friendship_request(@user, friend), :friend=>friend_id} #todo -change message format
  respond_to do |format|
    format.json { render :json => @getResult.as_json, status: :ok }
  end
end

def social_friends_count #количество друзей
  @getResult={:count=> FriendsHelper.friends_count(@user)} #todo -change message format
  respond_to do |format|
    format.json { render :json => @getResult.as_json, status: :ok }
  end
end

def social_friends_accept #принять дружбу
  friend_id=params.require(:accountid) #account, чей запрос принять
  getResult= FriendsHelper.friendship_request_status(@user, friend_id,1)?0:1
  operation_result = {:result => getResult }
  respond_to do |format|
    format.json { render :json => operation_result.as_json, status: :ok }
  end
end

def social_friends_decline #отклонить дружбу
  friend_id=params.require(:accountid) #account, чей запрос принять
  getResult= FriendsHelper.friendship_request_status(@user, friend_id,2)?0:1
  operation_result = {:result => getResult }
  respond_to do |format|
    format.json { render :json => operation_result.as_json, status: :ok }
  end
end

def social_friends_list #получить список друзей
  #friend_id=params.require(:accountid) #
  friend_list= FriendsHelper.get_friends(@user)
  getResult={:list=> friend_list} #todo -change message format
  respond_to do |format|
    format.json { render :json => getResult.as_json, status: :ok }
  end
end

def social_friends_search
  friend_email=params.require(:search).permit(:email)
  founded=Profile.where("email like :email ",
                   { email: friend_email[:email].downcase+'%' }).all
  friend_list=Array.new
  if founded
    founded.each { |friend|
      friend_list<<
          {
              :accountid => friend.user_token,
              :pic =>  friend.avatar_url,
              :name => friend.name,
              :surname => friend.surname
          }}
  end
  getResult={:list=> friend_list}
  respond_to do |format|
    format.json { render :json => getResult.as_json, status: :ok }
  end
end

def get_profile
  @profile = Object
  @profile = ProfilesHelper::get_profile_format(@user)
  respond_to do |format|
    format.json { render :json => @profile.as_json, status: :ok }
  end
end

def save_profile
   profile =save_profile_params

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

   unless (@user.email || @user.confirm_type != 0) #в профиле не указан емэйл или он не подтвержден
     if profile[:email] #в параметрах был передан мэйл
       emailId = AccountValidators::get_email_match(profile[:email]) #проверка адреса
       if(emailId)
         #проверка, что указанный мэйл никем более не используется
         searchResult = Profile.where("user_token = :e_mail OR email = :e_mail",{e_mail: profile[:email]}).any?
         unless searchResult
           @user.reg_token = SecureRandom.hex;
           @user.email = profile[:email];
           link="http://test.chargebutton.com/confirm?token=#{@user.reg_token}"
           send_confirm_mail(@user, link)
         else
           decline_already_registered
           return;
         end
       else
         @result = {:result => 16,:message => "e-mail have incorrect format"}
         respond_to do |format|
           format.json { render :json => @result.as_json, status: :conflict }
         end
         return;
       end
     end
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

  unless newUser && (user_password == newUser.password) ||  newUser && newUser.temp_account #временному аккаунту нельзя давать логиниться
    @result = Object
    @result = {:result => 5 ,:message => "user not found or incorrect password"}
    respond_to do |format|
      format.json { render :json => @result.as_json, status: :unauthorized }
    end
    return;
  end
  @session=create_session(newUser);
  if newUser.email
    sendmail(newUser, "sign-in");
  end
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

  founded_profile = Profile.get_by_token(@sign_up.accountid); 
                   
  if founded_profile && founded_profile.temp_account   
    @newUser = founded_profile
    @newUser.temp_account = FALSE    
  else
    if founded_profile # обнаружен существующий аккаунт
      @log.info("not registered. accountId have incorrect format")
      @result = Object
      @result = {:result => 4,:message => "not registered. accountId have incorrect format"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :conflict }
      end
      return;
    end
    
    # временный профайл не найден
    @newUser = Profile.create(@sign_up.accountid);   
  end


  #todo вынести все это безобразие в отдельный модуль
  facebookId = AccountValidators::get_fbid_match(@sign_up.accountid)

  if(facebookId)
    @newUser.fb_token=facebookId[0]
    @log.info("facebookId:#{facebookId}")
  else
    emailId = AccountValidators::get_email_match(@sign_up.accountid)
    if(emailId)
      @newUser.email=emailId[0];
      @log.info("emailId:#{emailId}")
    else
      # phone =  AccountValidators::get_phone_match(@sign_up.accountid)
      # if(phone)
      #   @newUser.phone=@sign_up.accountid
      #   @log.info("phone:#{phone}")
      # else
      @log.info("not registered. accountId have incorrect format")
      @result = Object
      @result = {:result => 4,:message => "not registered. accountId have incorrect format"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :conflict }
      end
      return;
      # end
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
    
    Wallet.create_wallet(@newUser.user_token)
        
    return;
  end

  link="http://api.onlinepay.com/confirm?token=#{@newUser.reg_token}";
  @log.debug(link);
  #User was successfully created.
  if (@newUser.email)
    send_confirm_mail(@newUser, link);
  end

  return_session(create_session(@newUser));
end

def confirm
    @result = Object
    reg_token = params[:token];

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

def catalog
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

def union_get_stats_new

end

def stats_profile
  position=profile_stats_params

#todo добавить skip для position
  feeds= ProfilesHelper::get_feed_message_format(Feed.where(['privacy = 0']).includes(:from_profile, :to_profile).first(position))
  feed_container=
      {:stats=>
           {
               :friends=>0,
               :likes=>0, #number of likes for all user's payments,
               :history=>feeds
           }
      }
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
      parms=params.require(:sendMoney).permit(:accountid, :amount,:currency,:message,:global)
      social_money_send_internal(parms[:amount], parms[:message], parms[:global], parms[:accountid], parms[:currency])
end

def social_money_send_internal (amount, message, privacy, accountid, currency)

      @log = Logger.new(STDOUT)
      @log.level = Logger::INFO

      f_amount = amount.to_s.gsub(',', '.').to_f
      to_profile = Profile.get_by_token(accountid)
      request = PayRequest.create_pay_request(@user.id, to_profile.id, f_amount, message, privacy, currency)
      begin
        Emailer.email_receipt(request).deliver
        PushTokens.send_payment_push(request)
      rescue => e
        @log.error e.message
        e.backtrace.each { |line| @log.error line }
      end

      @result = {:result => 0,:message => "ok", :available=> @user.get_wallet.available, :holded=> @user.get_wallet.holded}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :ok }
      end
  end


  def already_payed_error
    #case 1 : юзер может подтверждать только свои запросы todo срочно! вынести все рендеринги ошибок в методы!
    result = {:result => 2, :message => "already paid"}
    respond_to do |format|
      format.json { render :json => result.as_json, status: :forbidden }
    end
  end

  def recieve_pay
    
    request_id=params[:requestId]
    privacy=params[:global]

    unless privacy
      privacy = 2
    end

    #находится запрос в кошельке текущего пользователя по ИД запроса
    #begin
      payment_request = PayRequest.where(:id => request_id).first!#.includes(:to_profile, :from_profile)
    #проверка, что этот запрос нашего юзера
    unless payment_request.status == 0
      already_payed_error
      return
    end
    
    #rescue
    #проверка, что этот запрос нашего юзера
    unless payment_request.to_profile_id == @user.id
     #case 1 : юзер может подтверждать только свои запросы todo срочно! вынести все рендеринги ошибок в методы!
      result = {:result => 100, :message => "you do not have rights for this action"}
      respond_to do |format|
        format.json { render :json => result.as_json, status: :forbidden }
      end
      return
    end

    payment_request.accept_pay_request(privacy)

    @result = {:result => 0,:message => "ok", :available=> payment_request.to_profile.get_wallet.available, :holded=> payment_request.to_profile.get_wallet.holded}
    respond_to do |format|
      format.json { render :json => @result.as_json, status: :ok }
    end
  end

  def accept_charge #/social/money/pay
    request_id=params[:requestId]
    privacy =params[:global]
    # акцепт чарджа
    # найти чардж
    charge_request = ChargeRequest.where(:id=>request_id).includes(:from_profile).first

    unless charge_request.status == 0
      already_payed_error
      return
    end

    # удостовериться, что чардж предназначен текущему пользователю
    unless charge_request.to_profile_id == @user.id
      result = {:result => 100, :message => "you do not have rights for this action"}
      respond_to do |format|
        format.json { render :json => result.as_json, status: :forbidden }
      end
      return
    end
    charge_request.accept_charge(privacy)

    @result = {:result => 0,:message => "ok", :available=> charge_request.to_profile.get_wallet.available, :holded=> charge_request.to_profile.get_wallet.holded}
    respond_to do |format|
      format.json { render :json => @result.as_json, status: :ok }
    end

  end

  def social_money_charge

    log = Logger.new(STDOUT)
    log.level = Logger::INFO

    prms = params.require(:chargeMoney)
    to_user_token = prms[:accountid]
    amount = prms[:amount]
    f_amount = amount.to_s.gsub(',', '.').to_f
    currency = prms[:currency]
    message = prms[:message]
    privacy = prms[:global]

    begin
      request = ChargeRequest::create_charge_request(@user.id, Profile::get_by_token(to_user_token).id, f_amount, message, privacy, currency)
      @result = {:result => 0, :message => "ok", :available => @user.get_wallet.available, :holded => @user.get_wallet.holded}
      PushTokens::send_charge_push(request)
      @status = :ok
    rescue NoMoney
      @result = {:result => 101, :message => 'no money for commission payment'}
      @status = :forbidden
    rescue => e
      log.error e.message
      e.backtrace.each { |line| log.error line }
    end

    respond_to do |format|
      format.json { render :json => @result.as_json, status: @status }
    end

  end

  def social_money_get
   #Gets unanswered money requests.
   requests = Feed.where("status = 0 and to_profile_id = :to_profile AND fType=3",{:to_profile => @user.id} ).includes(:from_profile, :to_profile).all
   respond_to do |format|
     format.json { render :json => requests, status: :ok }
   end
  end

#method /profile/new
def get_new_requests
  @gets = Object
  @gets =  {:new=>FriendsHelper.get_new_feeds_count(@user) }
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

    founded_profile = Profile.find_by_user_token(@sign_up.accountid)
    if founded_profile && !founded_profile.temp_account #пропускаем временные профайлы
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
    founded_profile = Profile.find_by_email(@sign_up.accountid)
    if  founded_profile && !founded_profile.temp_account #пропускаем временные профайлы
      decline_already_registered
      return;
    end
  end

  def profile_stats_params
    params.require(:position)
  end
  # Never trust parameters from the scary internet, only allow the white list through.
  def catalog_params
    params.require(:PathModel).permit(:path)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def save_profile_params
    params.require(:profile)
    .permit(:email,
      :birthday,
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


def social_friends_invite_params
  @social_friends_invite = params.require(:invite).permit(:friend_email)
end

end
