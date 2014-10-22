class IsoCurrency < ActiveRecord::Base
  has_many :Wallet

  def self.get_currency_conversion_rate(source_currency, dest_currency)
    return 1
  end

end
