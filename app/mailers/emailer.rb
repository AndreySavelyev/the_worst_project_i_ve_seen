class Emailer < ActionMailer::Base

  include GlobalConstants

  default from: "noreply@chargebutton.com"

  def email_lead(email_profile)
    @log = Logger.new(STDOUT)
    @log.level = Logger::INFO
    @log.info("create email for #{email_profile[:email]} signin")
    @email_profile = email_profile
    mail(to: email_profile[:email], subject: "Sign in notification from onlinepay.com")
  end

  def email_recovery(request)
    @request = request
    mail(to: @request.sourceWallet.profile.email, subject: 'Password recovery request.')
  end

  def email_recovery_success(request)
    @request = request
    mail(to: @request.sourceWallet.profile.email, subject: 'Password recovery success.')
  end

  def email_confirm(form_email, confirm_link)
    @confirmation_link  = confirm_link #переменная дл  шаблона
    mail(to: form_email, subject: 'Welcome to onlinepay.com')
  end

  def email_friend_invite(to_email, who_invite_profile)
    @download_link  = GlobalSettings.find_by_settings_key('app_ios_download_link')
    unless @download_link #TODO сделать один синглтон с настройками
      settings_url= GlobalSettings.new
      settings_url.settings_key='app_ios_download_link'
      settings_url.settings_value='please contact with support to get your download link'
      settings_url.save
      @download_link=settings_url.settings_value
    end
    mail(to: to_email, subject: "#{who_invite_profile.surname} #{who_invite_profile.name}invite you to Onlinepay.com")
  end

  def email_unverified_iban(to_mail, profile, iban_num, amount, request_id)
    @profile_id = profile.id
    @iban_num = iban_num
    @amount = amount
    @request_id = request_id
    mail(to: to_mail, subject: 'Unverified IBAN')
  end

  def email_verified_iban(to_mail, profile, iban_num, amount, request_id)
    @profile_id = profile.id
    @iban_num = iban_num
    @amount = amount
    @request_id = request_id
    mail(to: to_mail, subject: 'IBAN verified')
  end

  def email_payout_success(to_mail, iban_num, amount, request_id)
    @iban_num = iban_num
    @amount = amount
    @request_id = request_id
    mail(to: to_mail, subject: 'Payout success')
  end

  def email_pay_request_new(request)
      @request = request
      mail(to: @request.to_profile.email, subject: "Receive money from #{@request.from_profile.name} #{@request.from_profile.surname}") do |format|
        format.text {render 'email_pay_request_new'}
      end
  end

  def email_pay_request_from(request)

  end

  def email_pay_request_to(request)

  end

  def email_charge_request_new(request)

  end

  def email_receipt(request)

    r_type = request.fType

    puts r_type
    puts request.status

    if r_type == GlobalConstants::REQUEST_TYPES[:pay] && request.status == 0
      email_pay_request_new(request)
    elsif r_type == GlobalConstants::REQUEST_TYPES[:pay] && request.status == 1
      email_pay_request_from(request)
      email_pay_request_to(request)
    elsif r_type == GlobalConstants::REQUEST_TYPES[:charge] && request.status == 0
      email_charge_request_new(request)
    else

    end


  end
end