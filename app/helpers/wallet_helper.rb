module WalletHelper
  def self.check_iban_validation_code(code)
    if ((code =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/)!=nil)
      return true;
    else
      return false;
    end
  end
  def self.format_to_currency(amount)
    ActionController::Base.helpers.number_to_currency(amount, precision: 2, :unit => '')
  end
end
