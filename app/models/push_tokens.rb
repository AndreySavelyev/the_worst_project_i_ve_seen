class PushTokens < ActiveRecord::Base

  belongs_to :Profile

  def self.get_by_token(token, profile_id)
    PushTokens.where(profile_id: profile_id, token: token).first_or_create
  end

  def self.get_tokens(profile_id)
    PushTokens.where(profile_id: profile_id)
  end

  def self.send_payment_push(request)

    tokens = get_tokens(request.to_profile_id)
    app = init_application

    begin
      tokens.each do |t|
        n = Rpush::Apns::Notification.new
        n.app = app
        n.device_token = t.token
        n.alert = "New money from: #{request.from_profile.surname} #{request.from_profile.name}"
        n.data = FeedsHelper::format_feed(request).as_json
        n.category = 'PAY'
        n.badge = 1
        n.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      @log = Logger.new(STDOUT)
      @log.level = Logger::ERROR
      @log.error e.message
    end
  end

  def self.send_charge_push(request)

    tokens = get_tokens(request.to_profile_id)

    app = init_application
    begin
      tokens.each do |t|
        n = Rpush::Apns::Notification.new
        n.app = app
        n.device_token = t.token
        n.alert = "New charge from: #{request.from_profile.surname} #{request.from_profile.name}"
        n.data = FeedsHelper::format_feed(request).as_json
        n.category = 'CHARGE'
        n.badge = 1
        n.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      @log = Logger.new(STDOUT)
      @log.level = Logger::ERROR
      @log.error e.message
    end


  end

  def self.send_tissue_push(tissue)

    tokens = get_tokens(tissue.to_profile.id)
    app = init_application

    begin
      tokens.each do |t|
        n = Rpush::Apns::Notification.new
        n.app = app
        n.device_token = t.token
        n.alert = "You have a new tissue from: #{tissue.from_profile.surname} #{tissue.from_profile.name}"
        n.data = ChatHelper::format_tissue(tissue).as_json
        n.category = 'TISSUE'
        n.badge = 1
        n.save!
      end

    rescue ActiveRecord::RecordInvalid => e
      @log = Logger.new(STDOUT)
      @log.level = Logger::ERROR
      @log.error e.message
    end

  end


  def self.send_friendship_push(request)

    tokens = get_tokens(request.to_profile_id)
    app = init_application

    begin
      tokens.each do |t|
        n = Rpush::Apns::Notification.new
        n.app = app
        n.device_token = t.token
        n.alert = "#{request.from_profile.surname} #{request.from_profile.name} wants to be your friend."
        n.data = FeedsHelper::format_feed(request).as_json
        n.category = 'FRIEND'
        n.badge = 1
        n.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      @log = Logger.new(STDOUT)
      @log.level = Logger::ERROR
      @log.error e.message
    end
  end

  :private

  def self.init_application
    app = Rpush::Apns::App.find_by_name("ios_app")

    if app == nil
      app = Rpush::Apns::App.new
      app.name = "ios_app"
      app.certificate = File.read("./certs/ios/push.pem")
      if Rails.env == 'production'
        app.environment = "production" # APNs environment.
      else
        app.environment = "sandbox" # APNs environment.
      end

      app.password = "123456"
      app.connections = 1
      app.save!
    end

    app
  end



end

