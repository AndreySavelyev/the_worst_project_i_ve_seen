class PayRequest < Feed

  COMISSIONS = {personal_green: 1.9, personal_biz: 3}

 def self.create_pay_request(from_user_id, to_user_id, amount, message, privacy, currency)

    send_request = PayRequest.new
    send_request.source_amount = amount
    send_request.feed_date = Time.now
    send_request.message = message
    send_request.privacy = privacy
    send_request.from_profile_id = from_user_id
    send_request.to_profile_id = to_user_id
    send_request.status = 0 #status:NEW
    send_request.fType = 4

    send_request.set_comission(currency)

    if send_request.check_balance
     send_request.save!
     send_request.from_profile.get_wallet.hold(send_request)
    end

  end

 def accept_pay_request(to_profile, privacy)
    if check_balance
      pay_comission
      Entry.create_payment_entry(self)
      self.status = 1
      set_privacy(privacy)
    self.save!
    end
  end
 
  
  def pay_comission    
    sys_w = Profile.get_sys_profile(self.to_profile.iso_currency.upcase).get_wallet
    Entry.create_comission_entry(self, sys_w)    
  end
  
 def set_privacy(privacy)
    self.fType = 2  
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

  def set_comission(currency)

    currency = IsoCurrency.find_by_Alpha3Code(currency.upcase)
    currency_dest = IsoCurrency.find_by_Alpha3Code(self.to_profile.iso_currency.upcase)

    self.comission_value = get_comission
    self.trans_commission_currency = currency.Alpha3Code
    self.trans_commission_amount =  (self.comission_value.to_f / self.source_amount.to_f) * 100

    self.conv_commission_id = get_conversation_commission_id
    self.conv_commission_amount = get_conv_commission(self.conv_commission_id, self.source_amount)
    self.amount = self.source_amount #not convertible by currency rate
    self.currency = currency_dest
    self.source_currency = currency.Alpha3Code
    self.rate_id = IsoCurrency.get_currency_conversion_rate(self.source_currency, self.currency)

  end

  def get_conversation_commission_id
    return 0
  end

  def get_conv_commission(conv_commission_id, source_amount)
    #расчет комиссии за конвертацию
    return 0
  end

  def check_balance
    if self.from_profile.wallet.available - self.trans_commission_amount - self.conv_commission_amount - self.source_amount >= 0
    return true
    end
    return false
  end

  def get_comission()

    comission = 0

    if (self.from_profile.wallet_type == Profile::ACCOUNT_TYPE[:personal] || self.from_profile.wallet_type == Profile::ACCOUNT_TYPE[:green]) &&
    (self.to_profile.wallet_type == Profile::ACCOUNT_TYPE[:personal] || self.to_profile.wallet_type == Profile::ACCOUNT_TYPE[:green])
      comission = COMISSIONS[:personal_green]
    end

    if (self.from_profile.wallet_type == Profile::ACCOUNT_TYPE[:personal] || self.from_profile.wallet_type == Profile::ACCOUNT_TYPE[:green]) &&
    (self.to_profile.wallet_type == Profile::ACCOUNT_TYPE[:biz])
      comission = COMISSION[:personal_biz]
    end

    return comission
  end
  
  def self.get_by_id(id)
       PayRequest.where(:id => request_id).includes(:to_profile, :from_profile).first!
  end

end
