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
    #@lead_email = form_email
   # @log = Logger.new(STDOUT)
   # @log.level = Logger::INFO
   # @log.info("create email for #{form_email} #{subject}")
    @confrimation_link  = confirm_link #переменная дл  шаблона
    mail(to: form_email, subject: "Confirm your registration")
  end
end