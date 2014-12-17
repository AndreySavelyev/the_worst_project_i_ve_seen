class Limit < ActiveRecord::Base

  class LimitNotFound < StandardError

  end

  class LimitReached < StandardError

  end

  def self.get(currency, wallet_type)

    limits = Rails.cache.fetch('limit', expires_in: 1.hour) do
      Limit.all
    end

    limits.each do |limit|
      if limit.currency == currency && limit.wallet_type == wallet_type
        return limit
      end
    end

    raise LimitNotFound.new

  end

  def check_amount(amount)
   if amount >= self.value
     raise LimitReached.new
   end
  end

  def self.check(currency, profile)
    limit_val = Limit.get(currency, profile.wallet_type)
    limit_val.check_amount(profile.get_wallet.get_revenue)
    true
  end


end
