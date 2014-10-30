module WalletHelper
  def self.check_iban_validation_code(code)
    if ((code =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/)!=nil)
      return true;
    else
      return false;
    end
  end
end
