class ChargeRequest < Feed

  include GlobalConstants

def self.create_charge_request(from_user_id, to_user_id, amount, message, privacy, currency)

  charge_request = ChargeRequest.new
  charge_request.feed_date = Time.now
  charge_request.status = 0
  charge_request.fType = GlobalConstants::REQUEST_TYPES[:charge]
  charge_request.source_amount = amount.to_f
  charge_request.amount = amount.to_f
  charge_request.currency = IsoCurrency.find_by_Alpha3Code(currency).Alpha3Code
  charge_request.privacy = privacy
  charge_request.message = message

  charge_request.from_profile_id = from_user_id
  charge_request.to_profile_id = to_user_id
  charge_request.set_commission(charge_request.currency)
  if charge_request.check_balance
    charge_request.save!
    return charge_request
  else
    raise Entry::NoMoney.new
  end

end

def check_balance
  self.from_profile.wallet.available - self.commission_amount.to_f - self.conv_commission_amount.to_f >= 0
end

def set_commission(currency)

  currency = IsoCurrency.find_by_Alpha3Code(currency.upcase)

  self.commission_value = get_commission

  self.commission_currency = currency.id
  self.commission_amount = (self.commission_value.to_f / self.source_amount.to_f) * 100

  self.conv_commission_id = get_conversation_commission_id
  self.conv_commission_amount = get_conv_commission(self.conv_commission_id, self.source_amount)
  self.amount = self.source_amount #not convertible by currency rate
  self.source_currency = currency.id
  self.rate_id = IsoCurrency.get_currency_conversion_rate(self.source_currency, self.currency)

end

def get_conversation_commission_id
  0
end

def get_conv_commission(conv_commission_id, source_amount)
  0
end


def get_commission

  if (self.from_profile.wallet_type == GlobalConstants::ACCOUNT_TYPE[:personal] || self.from_profile.wallet_type == GlobalConstants::ACCOUNT_TYPE[:green]) &&
      (self.to_profile.wallet_type == GlobalConstants::ACCOUNT_TYPE[:personal] || self.to_profile.wallet_type == GlobalConstants::ACCOUNT_TYPE[:green])
    return GlobalConstants::COMMISSIONS[:personal_green]
  end

  if (self.from_profile.wallet_type == GlobalConstants::ACCOUNT_TYPE[:personal] || self.from_profile.wallet_type == GlobalConstants::ACCOUNT_TYPE[:green]) &&
      (self.to_profile.wallet_type == GlobalConstants::ACCOUNT_TYPE[:biz])
    GlobalConstants::COMMISSIONS[:personal_biz]
  end

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


def pay_commission
  sys_w = Profile.get_sys_profile(self.to_profile.iso_currency.upcase).get_wallet
  self.wallet_request = WalletRequest.create_send_money_wallet_request(self)
  Entry.create_commission_entry(self, sys_w)
end

def accept_charge(privacy)
  set_privacy(privacy)
  currency_object = IsoCurrency.find_by_Alpha3Code(self.currency)
  PayRequest::create_accepted_request(self.to_profile_id, self.from_profile_id, self.amount, self.message, self.privacy, currency_object.Alpha3Code)

  if check_balance
    pay_commission
    self.status = 1 #accepted charge
    self.save!
  end
end
  
end