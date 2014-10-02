require 'wallet_module.rb'
require 'friends_helper.rb'
class ProfilesController < ApplicationController

include WalletModule
include FriendsHelper

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
  newest_rate = ChangeRate.where("CurrencyTo = :to_currency AND CurrencyFrom = :from_curerncy ",
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
                   { email: friend_email[:email]+'%' }).all
  friend_list=Array.new
  if founded
    founded.each { |friend|
      friend_list<<
          {
              :accountid => friend.user_token,
              :pic =>  friend.pic_url,
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
  @profile =
      {
          :profile=>
              {
                  :accountid=>@user.user_token,
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
           link="https://api.onlinepay.com/confirm?token=#{@user.reg_token}";
           send_confirm_mail(@user, link);
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

  founded_profile= Profile.where("user_token = :accountid
                   OR email = :accountid OR fb_token = :accountid OR phone = :accountid",{accountid: @sign_up.accountid}).first
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
    @newUser = Profile.new
    @newUser.user_token = @sign_up.accountid;
  end


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

def feed
  #todo проверить списки (только для глобал одинаковые)
  queryPrivacy=params.require(:global)
  if queryPrivacy == "0"
    feeds = ProfilesHelper::get_feed_message_format(Feed.where("privacy = :privacy", {privacy: queryPrivacy})
                                                    .includes(:from_profile, :to_profile)
                                                    .order(:viewed).reverse_order
                                                    .order(feed_date: :desc)#.reverse_order
                                                    .first(10))
  else
    feeds = ProfilesHelper::get_feed_message_format(Feed.where("privacy = :privacy AND (to_profile_id = :to_user OR from_profile_id = :from_user) AND status=0",
                                                               {privacy: queryPrivacy, to_user: @user.id, from_user:  @user.id })
                                                    .includes(:from_profile, :to_profile)
                                                    .order(:viewed)#.reverse_order
                                                    .order(feed_date: :desc)#.reverse_order
                                                    .first(10))
  end
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
    begin
      parms=params.require(:sendMoney).permit(:accountid, :amount,:currency,:message,:global)
      #на исходном кошельке проверяется наличие необходимой суммы
      #создание pay_request
      send_request= PayRequest.new
      send_request.source_amount = parms[:amount]
      send_request.message = parms[:message]
      send_request.privacy = parms[:global]

      #TODO разъяснить момент с массивом получаетелей
      from_profile=  @user
      send_request.from_profile = from_profile
      to_profile= Profile.where(:user_token => parms[:accountid]).first!
      send_request.to_profile = to_profile
      send_request.status=0 #status:NEW
      send_request.fType = 4
      send_request.privacy = 2
    rescue
      @result = {:result => 1,:message => "reciever not found"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :error }
      end
      return
    end

    begin
      #Поиск валюты расчетов
      currency= IsoCurrency.find_by_Alpha3Code(parms[:currency].upcase)

      # если валюты кошельков различаются, то производится конвертация в валюту назначения. писать в фид, про комиссию за конвертацию.
      # фиксируется курс валют, на исходном кошельке фиксируется сумма в валюте источника.
      # запрос шлется в валюте кошелька стока.
      # комиссия берется в валюте кошелька источника. на исходном кошельке фиксируется сумма в валюте источника.
      send_request.trans_commission_id=#
          send_request.trans_commission_currency=currency.Alpha3Code#
      send_request.trans_commission_amount=0#
      send_request.conv_commission_id=get_conversation_commission_id#
      send_request.conv_commission_amount= get_conv_commiss(send_request.conv_commission_id, send_request.source_amount)#

      send_request.amount=send_request.source_amount #todo конвертация валют get_payment_amount( send_request.rate_id, send_request.source_amount) конечная сумма назначения
      send_request.currency= currency.Alpha3Code #TODO: for test purpose only UER #конечная валюта назначения
      send_request.source_currency = currency.Alpha3Code
      send_request.rate_id=get_currency_conversation_rate(send_request.source_currency, send_request.currency)#курс конвертации валют
        # рассылка уведомлений

        #проверка достаточности суммы к списанию на кошельке источнике
        #блокировка суммы к списанию

    rescue
      @result = {:result => 103,:message => "unknown currency"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :error }
      end
      return
    end

    begin

      payment_total_amount=  send_request.amount + send_request.trans_commission_amount + send_request.conv_commission_amount;
      from_profile.available = from_profile.available - payment_total_amount
      from_profile.holded = from_profile.holded + payment_total_amount


      if from_profile.available < 0
        @result = Object
        @result = {:result => 101, :message => "not enought money"}
        respond_to do |format|
          format.json { render :json => @result.as_json, status: :forbidden }
        end
        return
      end

      if  send_request.amount <= 0
        @result = Object
        @result = {:result => 102, :message => "zero payment summ"}
        respond_to do |format|
          format.json { render :json => @result.as_json, status: :forbidden }
        end
        return
      end

      ActiveRecord::Base.transaction do
        #пошла транзакция
        from_profile.save!
        send_request.save!
      end

    rescue
      @result = {:result => 104,:message => "transaction rolled back"}
      respond_to do |format|
        format.json { render :json => @result.as_json, status: :error }
      end
      return
    end
    @result = {:result => 0,:message => "ok", :available=> from_profile.available, :holded=> from_profile.holded}
    respond_to do |format|
      format.json { render :json => @result.as_json, status: :ok }
    end
  end

def get_transaction_commission_id

end

def wallet_get_commission_wallet
  #возвращает кошелек на котором аккамулируются комиссии
end

def get_conversation_commission_id
  #ID комиссии
end

def get_conv_commiss(conv_commission_id, source_amount)
  #расчет комиссии за конвертацию
  return 0
end

def get_currency_conversation_rate(source_currency, dest_currency)
  return 1
end

  def recieve_pay
    request_id=params[:requestId]
    #находится запрос в кошельке текущего пользователя по ИД запроса
    begin
      payment_request = PayRequest.where(:id => request_id, :status => 0).first!#.includes(:to_profile, :from_profile)
      from_profile= Profile.find(payment_request.from_profile_id)
      to_profile= Profile.find(payment_request.to_profile_id)
    rescue
    #todo срочно! вынести все рендеринги ошибок в методы!
        result = {:result => 20, :message => "not found"}
        respond_to do |format|
          format.json { render :json => result.as_json, status: :not_found }
        end
        return
    end
    #проверка, что этот запрос нашего юзера
    unless payment_request.to_profile_id == @user.id
     #case 1 : юзер может подтверждать только свои запросы todo срочно! вынести все рендеринги ошибок в методы!
      result = {:result => 100, :message => "you do not have rights for this action"}
      respond_to do |format|
        format.json { render :json => result.as_json, status: :forbidden }
      end
      return
    end
    #с исходнго кошелька списывается замороженная сумма
    comiss_wallet=Profile.where(:wallet_type =>  100, :iso_currency => payment_request.from_profile.iso_currency).first!
    unless comiss_wallet
      #todo срочно! вынести все рендеринги ошибок в методы!
      result = {:result => 111, :message => "system's wallet does not exist"}
      respond_to do |format|
        format.json { render :json => result.as_json, status: :internal_server_error }
      end
      return
    end
    #на кошелек комиссий производится зачисление средств за проведение операции (код операции 1)
    transaction_commission_entry=Entry.new
    transaction_commission_entry.payment_request_id = payment_request.id
    transaction_commission_entry.credit_profile_id = from_profile.id
    transaction_commission_entry.debt_profile_id = comiss_wallet.id
    transaction_commission_entry.amount = payment_request.trans_commission_amount
    transaction_commission_entry.currency_id = from_profile.iso_currency
    transaction_commission_entry.operation_code = 1 #списание комиссии
    #на кошелек комиссий производится зачисление средств за конвертацию (код операции 2)
    convertation_commission_entry=Entry.new
    convertation_commission_entry.payment_request_id = payment_request.id
    convertation_commission_entry.credit_profile_id = from_profile.id
    convertation_commission_entry.debt_profile_id = comiss_wallet.id
    convertation_commission_entry.amount = payment_request.conv_commission_amount
    convertation_commission_entry.currency_id = payment_request.from_profile.iso_currency
    convertation_commission_entry.operation_code = 2 #списание комиссии
    #на кошелек назначения эта сумма зачисляется
    transaction_entry=Entry.new
    transaction_entry.payment_request_id = payment_request.id
    transaction_entry.credit_profile_id = from_profile.id
    transaction_entry.debt_profile_id = to_profile.id
    transaction_entry.amount = payment_request.amount
    transaction_entry.currency_id = payment_request.to_profile.iso_currency
    transaction_entry.operation_code = 3 #пополнение кошелька

    unless comiss_wallet.iso_currency == payment_request.from_profile.iso_currency
      #todo срочно! вынести все рендеринги ошибок в методы!
      result = {:result => 112, :message => "currency convertation internal error"}
      respond_to do |format|
        format.json { render :json => result.as_json, status: :internal_server_error }
      end
      return
    end
    comiss_wallet.available = comiss_wallet.available + transaction_commission_entry.amount
    comiss_wallet.available = comiss_wallet.available + convertation_commission_entry.amount
    to_profile.available = to_profile.available + transaction_entry.amount
    from_profile.holded = from_profile.holded - payment_request.source_amount
    from_profile.holded = from_profile.holded - payment_request.conv_commission_amount
    from_profile.holded = from_profile.holded - payment_request.trans_commission_amount
    #запрос помечается как принятый
    payment_request.status = 1#статус запроса дружбы 0-new, 1-accepted, 2-declined, 3 -canceled

    #создаем новостные фиды:
    # 1-отправителю
    # 2-получателю
    #newsFeed=Feed.new
    #newsFeed.from_profile_id = payment_request.to_profile_id
    #newsFeed.to_profile_id = payment_request.from_profile_id
    #newsFeed.privacy = 2
    #newsFeed.amount = payment_request.source_amount
    #newsFeed.currency = payment_request.source_currency
    #newsFeed.message = "accepted"
    #newsFeed.fType = 2
    payment_request.fType = 2
    #рассылка уведомлений

    ActiveRecord::Base.transaction do
      #пошла транзакция
      from_profile.save!
      to_profile.save!
      payment_request.save!
      comiss_wallet.save!
      transaction_entry.save!
      convertation_commission_entry.save!
      transaction_commission_entry.save!
    end

  end

  def social_money_charge
    @like=Object.new
    @like={:result=>0}
    respond_to do |format|
      format.json { render :json => @like.as_json, status: :ok }
    end
  end

  def social_money_get

    testFriend = Profile
    .where(user_token: "vk100@onlinepay.com")
    .includes(:lovers, :patients).first #загружать связи из фрэндов

    #  @gets = Array.new
    #  @gets <<  {
    #      :id =>"salkjh234jhkjfh9432y",
    #      :fromID => "salkjh234jhkjfh9432y",
    #      :name => "John Smith",
    #      :pic =>  "url",
    #      :type =>  "charge", #charge request or money send request
    #      :amount => 100.00,
    #      :currency => "eur",
    #      :message => "Please send me some money for a new car."
    #  }
    #  @getResult=Object.new
    #  @getResult={:moneyRequest=>@gets}


    # feeed=Message.create( :status => 1)
    # feeed.save()

    newFriend = Profile.find_by_email('vk1002+2@onlinepay.com')
    FriendsHelper.create_friendship_request(@user, newFriend)


    #FriendsHelper.create_friendship(@user, newFriend)
    @getResult = Array.new
    testFriend.lovers.each { |feed|
      @getResult << {
          :id => FriendsHelper.get_friendship_requests(newFriend)
      }
    }

    respond_to do |format|
      format.json { render :json => @getResult.as_json, status: :ok }
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
