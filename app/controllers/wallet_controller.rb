class WalletController < ApplicationController

  before_action :set_user_from_session, only: [:cashin, :cashout, :complete_cashout, :list]

  def cashin
    w = Wallet::get_wallet($user)
    wr = WalletRequest.create_cash_in_wallet_request(w.id)
    respond_to do |format|
      format.json { render :json => wr.as_json, status: :ok }
    end
  end

  def cashout
    begin
      cashout=params.require(:cashout).permit(:iban, :amount, :code)

      iban_num = cashout[:iban]
      amount = cashout[:amount]
      code = cashout[:code]

      iban = Iban.get_iban($user, iban_num)
      cashout_result = {:result => '0', :request_id => '-1'}

      w = Wallet.get_wallet($user)

      status=nil

      if (amount.to_f > w.available)
        status=:internal_server_error
        cashout_result[:result] = 'Not enough money in wallet.'
      else
        if (iban.verified == false)

          wr = WalletRequest.get_wallet_request_for_iban(iban, w)

          if (!WalletHelper.check_iban_validation_code(code.to_s))
            Emailer
            .email_unverified_iban('vk@onlinepay.com', $user, iban_num, amount, wr.id)
            .deliver

            cashout_result[:result] = 'No verified'
            cashout_result[:request_id] = wr.id;
          elsif (iban.code==code.to_i)

            iban.verified = true
            iban.save!

            e = Entry.create_hold_entry(wr, amount)

            Emailer
            .email_verified_iban('vk@onlinepay.com', $user, iban_num, amount, wr.id)
            .deliver

            cashout_result[:result] = "IBAN verified, cashout sum held:#{e.amount}"
            cashout_result[:request_id] = wr.id
          else
            cashout_result[:result] = 'IBAN didn\'t verified. Wrong code.'
            cashout_result[:request_id] = wr.id
          end
        elsif (iban.verified == true)

          wr = WalletRequest.get_wallet_request_for_iban(iban, w)
          e = Entry.create_hold_entry(wr, amount)

          cashout_result[:result] = "Cashout sum held:#{w.holded.to_f+e.amount}"
          cashout_result[:request_id] = wr.id

        end
      end

      respond_to do |format|
        format.json { render :json => cashout_result.as_json, status: :ok }
      end

    rescue
      @bad_request={:result => 'Internal Error!'}
      respond_to do |format|
        format.json { render :json => @bad_request.as_json, status: :internal_server_error }
      end
    end
  end

  def complete_cashout
    begin
      cashout=params.require(:complete_cashout).permit(:request_id)

      wr = WalletRequest.find_by_id(cashout[:request_id])
      iban = Iban.find_by_wr_token(wr.token)

      status = nil
      result = nil

      if (iban.verified)

        entries = Entry.find_by_payment_req_id(wr.id)
        sum_cashout = 0

        entries.each do |e|
          sum_cashout += e.amount;
        end

        Entry.create_payout_entry(wr, sum_cashout)

        iban.wr_token = nil
        iban.save!

        Emailer.email_payout_success($user.email, iban.iban_num, sum_cashout, wr.id)
        .deliver

        Emailer.email_payout_success('vk@onlinepay.com', iban.iban_num, sum_cashout, wr.id)
        .deliver
        result='Cashout succesfull'
        status=:ok
      else
        result='Iban is not verified yet'
        status=:internal_server_error
      end

      respond_to do |format|
        format.json { render :json => {:result => result}.as_json, status: status }
      end
    rescue
      @bad_request={:result => 'Internal Error!'}
      respond_to do |format|
        format.json { render :json => @bad_request.as_json, status: :internal_server_error }
      end
    end
  end

  def list
    list = Iban.find_ibans_by_id($user.id)
    ibans = Array.new

    list.each do |e|
      ibans << {:iban => e.iban_num, :default => e.is_default, :verified => e.verified}
    end

    respond_to do |format|
      format.json { render :json => ibans.as_json, status: :ok }
    end
  end
end
