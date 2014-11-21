module WalletHelper
  def self.format_to_currency(amount)
    ActionController::Base.helpers.number_to_currency(amount, precision: 2, :unit => '')
  end
end
