module WalletHelper
<<<<<<< HEAD
  def self.check_iban_validation_code(code)
    if ((code =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/)!=nil)
      return true;
    else
      return false;
    end
=======
  def self.format_to_currency(amount)
    ActionController::Base.helpers.number_to_currency(amount, precision: 2, :unit => '')
>>>>>>> ece35b7a8cee99c7d6df8d75f62609b214eec0cb
  end
end
