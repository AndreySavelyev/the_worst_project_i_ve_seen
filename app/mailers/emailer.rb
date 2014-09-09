class Emailer < ActionMailer::Base
  default from: "noreply@chargebutton.com"
  def email_lead(form_email, subject)
    #@lead_email = form_email
    @log = Logger.new(STDOUT)
    @log.level = Logger::INFO
    @log.info("create email for #{form_email} #{subject}")
    mail(to: form_email, subject: subject)
  end
  def email_confirm(form_email, confirm_link)
    @confrimation_link  = confirm_link #переменная дл  шаблона
    mail(to: form_email, subject: 'Welcome to Onlinepay.com')
  end
  def email_friend_invite(to_email, who_invite_profile)
    @download_link  = GlobalSettings.find_by_settings_key('app_ios_download_link')
    unless @download_link #TODO сделать один синглтон с настройками
      settings_url= GlobalSettings.new;
      settings_url.settings_key='app_ios_download_link'
      settings_url.settings_value='please contact with support to get your download link'
      settings_url.save
      @download_link=settings_url.settings_value
    end
    mail(to: to_email, subject: "#{who_invite_profile.surname} #{who_invite_profile.name}invite you to Onlinepay.com")
  end
end