class Entry < ActiveRecord::Base

  OPERATION_CODES = {cashin: 3, payment: 1, hold: 2, commission: 4, cashout: 5}

  def self.create_cashin_entry(amount, token)

    r = WalletRequest.find_by_token(token)

    e = Entry.new
    e.payment_request_id = r.id
    e.credit_profile_id = r.targetWallet.profile.id
    e.debt_profile_id = r.sourceWallet.profile.id
    e.credit_wallet_id = r.targetWallet.id
    e.debit_wallet_id = r.sourceWallet.id
    e.amount = amount
    e.currency_id = r.sourceWallet.IsoCurrency.id
    e.operation_code = OPERATION_CODES[:cashin]
    e.save!

    e.rollover

    return e

  end

  def self.create_hold_entry(r, amount)

    e = Entry.new
    e.payment_request_id = r.id
    e.credit_profile_id = r.targetWallet.profile.id
    e.debt_profile_id = r.sourceWallet.profile.id
    e.credit_wallet_id = r.targetWallet.id
    e.debit_wallet_id = r.sourceWallet.id
    e.amount = amount
    e.currency_id = r.sourceWallet.IsoCurrency.id
    e.operation_code = OPERATION_CODES[:hold]
    e.save!

    e.rollover

    return e

  end

  def self.create_commission_entry(r, sys_wallet)

    e = Entry.new
    e.payment_request_id = r.id
    e.credit_profile_id = sys_wallet.profile.id
    e.debt_profile_id = r.wallet_request.sourceWallet.profile.id
    e.credit_wallet_id = sys_wallet.id
    e.debit_wallet_id = r.wallet_request.sourceWallet.id
    e.amount = r.conv_commission_amount.to_f + r.commission_amount.to_f
    e.currency_id = r.wallet_request.sourceWallet.IsoCurrency.id
    e.operation_code = OPERATION_CODES[:commission]
    e.save!

    e.rollover

    return e

  end

  def self.create_payment_entry(r)

    e = Entry.new
    e.payment_request_id = r.id
    e.credit_profile_id = r.wallet_request.targetWallet.profile.id
    e.debt_profile_id = r.wallet_request.sourceWallet.profile.id
    e.credit_wallet_id = r.wallet_request.targetWallet.id
    e.debit_wallet_id = r.wallet_request.sourceWallet.id
    e.amount = r.amount
    e.currency_id = r.wallet_request.sourceWallet.IsoCurrency.id
    e.operation_code = OPERATION_CODES[:payment]
    e.save!

    e.rollover

    return e

  end
  def self.create_payout_entry(r, amount)

    e = Entry.new
    e.payment_request_id = r.id
    e.credit_profile_id = r.targetWallet.profile.id
    e.debt_profile_id = r.sourceWallet.profile.id
    e.credit_wallet_id = r.targetWallet.id
    e.debit_wallet_id = r.sourceWallet.id
    e.amount = amount
    e.currency_id = r.sourceWallet.IsoCurrency.id
    e.operation_code = OPERATION_CODES[:cashout]
    e.save!

    e.rollover

  end


  def rollover()

    credit_wallet = Wallet.get_wallet_by_id(self.credit_wallet_id);
    debit_wallet = Wallet.get_wallet_by_id(self.debit_wallet_id);

    case self.operation_code
      when OPERATION_CODES[:cashin]
        credit_wallet.increment(:available, by = self.amount)
        credit_wallet.save!
      when OPERATION_CODES[:hold]
        debit_wallet.decrement(:available, by = self.amount)
        debit_wallet.increment(:holded, by = self.amount)
        debit_wallet.save!
      when OPERATION_CODES[:commission]
        credit_wallet.increment(:available, by = self.amount)
        debit_wallet.decrement(:available, by = self.amount)
        credit_wallet.save!
        debit_wallet.save!
      when OPERATION_CODES[:payment]
        credit_wallet.increment(:available, by = self.amount)
        debit_wallet.decrement(:holded, by = self.amount)
        credit_wallet.save!
        debit_wallet.save!
      when OPERATION_CODES[:cashout]
        debit_wallet.decrement(:holded, by = self.amount)
        debit_wallet.save!
      else
    end
  end

end
