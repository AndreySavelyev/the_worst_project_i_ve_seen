class PushTokens < ActiveRecord::Base

  belongs_to :Profile

  def self.get_by_token(token, platform, profile_id)
    PushTokens.where(profile_id: profile_id, token: token, platform: platform).first_or_create
  end

  def self.get_tokens(profile_id)
    PushTokens.where(profile_id: profile_id)
  end

  def self.send_payment_push(request)

    tokens = get_tokens(request.to_profile_id)

    begin
      tokens.each do |t|
        send_push(t.platform, t.token, "New money from: #{request.from_profile.surname} #{request.from_profile.name}", FeedsHelper::format_feed(request).as_json, 'PAY')
      end
    rescue ActiveRecord::RecordInvalid => e
      @log = Logger.new(STDOUT)
      @log.level = Logger::ERROR
      @log.error e.message
    end

  end

  def self.send_charge_push(request)

    tokens = get_tokens(request.to_profile_id)

    begin
      tokens.each do |t|
        send_push(t.platform, t.token, "New charge from: #{request.from_profile.surname} #{request.from_profile.name}", FeedsHelper::format_feed(request).as_json, 'CHARGE')
      end
    rescue ActiveRecord::RecordInvalid => e
      @log = Logger.new(STDOUT)
      @log.level = Logger::ERROR
      @log.error e.message
    end

  end

  def self.send_tissue_push(tissue)

    tokens = get_tokens(tissue.to_profile.id)

    begin
      tokens.each do |t|
        send_push(t.platform, t.token, "You have a new tissue from: #{tissue.from_profile.surname} #{tissue.from_profile.name}", ChatHelper::format_tissue(tissue).as_json, 'TISSUE')
      end

    rescue ActiveRecord::RecordInvalid => e
      @log = Logger.new(STDOUT)
      @log.level = Logger::ERROR
      @log.error e.message
    end

  end


  def self.send_friendship_push(request)

    tokens = get_tokens(request.to_profile_id)

    begin
      tokens.each do |t|
        send_push(t.platform, t.token, "#{request.from_profile.surname} #{request.from_profile.name} wants to be your friend.", FeedsHelper::format_feed(request).as_json, 'FRIEND')
      end
    rescue ActiveRecord::RecordInvalid => e
      @log = Logger.new(STDOUT)
      @log.level = Logger::ERROR
      @log.error e.message
    end
  end

  :private

  def self.send_push(platform, token, message, payload, category)
    case platform
      when 'ios'
        n = Rpush::Apns::Notification.new
        n.app = get_or_create_ios_app
        n.device_token = token
        n.alert = message
        n.data = payload
        n.category = category
        n.badge = 1
        n.save!
      when 'android'
        n = Rpush::Gcm::Notification.new
        n.app = get_or_create_android_app
        n.registration_ids = [token]
        n.data = { message: message, context: payload, category: category }
        n.save!
    end

  end

  def self.get_or_create_ios_app
    app = Rpush::Apns::App.find_by_name('ios_app')

    if app == nil
      app = Rpush::Apns::App.new
      app.name = 'ios_app'
      app.certificate = File.read('./certs/ios/push.pem')
      if Rails.env == 'production'
        app.environment = 'production' # APNs environment.
      else
        app.environment = 'sandbox' # APNs environment.
      end

      app.password = '123456'
      app.connections = 1
      app.save!
    end
    app
  end

  def self.get_or_create_android_app
    app = Rpush::Gcm::App.find_by_name('android_app')

    if app == nil
      app = Rpush::Gcm::App.new
      app.name = :android_app
      if Rails.env == 'production'
        app.auth_key = 'AIzaSyBLwnSCoxjA9NgmG5H2RrqRwQN_KlFug9M'
      else
        app.auth_key = 'AIzaSyBLwnSCoxjA9NgmG5H2RrqRwQN_KlFug9M'
      end
      app.connections = 1
      app.save!
    end

    app
  end

end