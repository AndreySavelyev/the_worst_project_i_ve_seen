class NotOwner < StandardError

end

class PayRequest < Feed

  include GlobalConstants

 def self.create_pay_request(from_user_id, to_user_id, amount, message, privacy, currency)

    send_request = PayRequest.new
    send_request.source_amount = amount
    send_request.feed_date = Time.now
    send_request.message = message
    send_request.privacy = privacy
    send_request.from_profile_id = from_user_id
    send_request.to_profile_id = to_user_id
    send_request.status = 0 #status:NEW
    send_request.fType = GlobalConstants::REQUEST_TYPES[:pay]

    send_request.set_commission(currency)

    if send_request.check_balance && Limit::check(currency, send_request.from_profile)
      send_request.save!
      send_request.from_profile.get_wallet.hold(send_request)
    else
      raise Entry::NoMoney.new
    end

   return send_request

 end

  def decline_pay_request(owner_profile_id)
    if self.to_profile.id != owner_profile_id
        raise PayRequest::NotOwner.new
    end
    self.status = 2
    self.from_profile.get_wallet.cancel_hold(self)
    self.save!
  end

  def self.create_accepted_request(from_user_id, to_user_id, amount, message, privacy, currency)

    send_request = PayRequest.new
    send_request.source_amount = amount
    send_request.feed_date = Time.now
    send_request.message = message
    send_request.privacy = privacy
    send_request.from_profile_id = from_user_id
    send_request.to_profile_id = to_user_id
    send_request.status = 1 #status:ACCEPTED
    send_request.fType = GlobalConstants::REQUEST_TYPES[:pay]

    send_request.set_commission(currency)

    if send_request.check_balance && Limit::check(currency, send_request.from_profile)
      send_request.save!

      send_request.from_profile.get_wallet.hold(send_request)
      Entry.create_payment_entry(send_request)
      send_request.save!
    else
      raise Entry::NoMoney.new
    end
  end

 def accept_pay_request(privacy)
    if check_balance
      pay_commission
      Entry.create_payment_entry(self)
      self.status = 1
      set_privacy(privacy)
      self.save!
    else
      raise Entry::NoMoney.new
    end
  end
 
  
  def pay_commission
    sys_w = Profile.get_sys_profile(self.to_profile.iso_currency.upcase).get_wallet
    Entry.create_commission_entry(self, sys_w)
  end
  
 def set_privacy(privacy)
    if self.privacy == 0
      if privacy == 0
      self.privacy = 0
      elsif  privacy == 1
      self.privacy = 1
      else
      self.privacy = 2
      end
    elsif  self.privacy == 1
      if privacy == 0
      self.privacy = 1
      elsif  privacy == 1
      self.privacy = 1
      else
      self.privacy = 2
      end
    else
    self.privacy = 2
    end
  end

  def set_commission(currency)

    currency = IsoCurrency.find_by_Alpha3Code(currency.upcase)
    currency_dest = IsoCurrency.find_by_Alpha3Code(self.to_profile.iso_currency.upcase)

    self.commission_value = get_commission(self.status)
    self.commission_currency = currency.Alpha3Code
    self.commission_amount =  (self.commission_value.to_f * self.source_amount.to_f) / 100

    self.conv_commission_id = get_conversation_commission_id
    self.conv_commission_amount = get_conv_commission(self.conv_commission_id, self.source_amount)
    self.amount = self.source_amount #not convertible by currency rate
    self.currency = currency_dest.Alpha3Code
    self.source_currency = currency.id
    self.rate_id = IsoCurrency.get_currency_conversion_rate(self.source_currency, self.currency)

  end

  def get_conversation_commission_id
    0
  end

  def get_conv_commission(conv_commission_id, source_amount)
    0
  end

  def check_balance
    self.from_profile.wallet.available - self.commission_amount.to_f - self.conv_commission_amount - self.source_amount >= 0
  end

  def get_commission(status)

    if(status == 1)
      return 0
    end

    if (self.from_profile.wallet_type == GlobalConstants::ACCOUNT_TYPE[:personal] || self.from_profile.wallet_type == GlobalConstants::ACCOUNT_TYPE[:green]) &&
    (self.to_profile.wallet_type == GlobalConstants::ACCOUNT_TYPE[:personal] || self.to_profile.wallet_type == GlobalConstants::ACCOUNT_TYPE[:green])
        return GlobalConstants::COMMISSIONS[:personal_green]
    end

    GlobalConstants::COMMISSIONS[:personal_biz]

  end
  
  def self.get_by_id(id)
       PayRequest.where(:id => request_id).includes(:to_profile, :from_profile).first!
  end


end
