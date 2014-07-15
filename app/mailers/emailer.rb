class Emailer < ActionMailer::Base
  default from: "noreply@chargebutton.com"
  def email_lead(form_email, subject)
    #@lead_email = form_email
    @log = Logger.new(STDOUT)
    @log.level = Logger::INFO
    @log.info("create email for #{form_email} #{subject}")
    @lead_email  = form_email #переменная дл  шаблона
    mail(to:    'loskutnikov@inbox.ru',#'v.kovalevskiy@cardpay.com'
         subject: subject)
  end
end