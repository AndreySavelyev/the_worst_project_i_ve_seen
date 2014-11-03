class WalletController < ApplicationController

  before_action :set_user_from_session, only: [:cashin, :cashout, :complete_cashout]

  ERR_CODES = {no_err: 0,
               not_enough_money: 101,
               iban_not_verified: 201,
               iban_wrong_code: 202,
               general_err: 901}

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

      if iban_num.to_s.blank?
        raise
      end

      iban = Iban.get_iban($user, iban_num);

      cashout_result = {:result => 'No message.',
                        :request_id => '-1',
                        :err_code => ERR_CODES[:no_err]}
      request_status=:ok

      w = Wallet.get_wallet($user)

      if (amount.to_f > w.available)
        cashout_result[:result] =
            "Not enough money in wallet. Current wallet balance:#{w.available}."
        cashout_result[:err_code] = ERR_CODES[:not_enough_money]
        request_status=:internal_server_error
      else
        if (iban.verified == false)

          wr = WalletRequest.get_wallet_request_for_iban(iban, w)

          if (!WalletHelper.check_iban_validation_code(code.to_s))
            Emailer
            .email_unverified_iban('vk@onlinepay.com', $user, iban_num, amount, wr.id)
            .deliver

            cashout_result[:result] = "IBAN:#{iban.iban_num} is not verified."
            cashout_result[:request_id] = wr.id;
            cashout_result[:err_code] = ERR_CODES[:iban_not_verified]
            request_status = :internal_server_error

          elsif (iban.code==code.to_i)
            iban.verified = true
            iban.save!

            e = Entry.create_hold_entry(wr, amount)

            Emailer
            .email_verified_iban('vk@onlinepay.com', $user, iban_num, amount, wr.id)
            .deliver

            cashout_result[:result] =
                "IBAN:#{iban.iban_num} verified, cashout sum held:#{e.amount}"
            cashout_result[:request_id] = wr.id
            cashout_result[:err_code] = ERR_CODES[:no_err]
            request_status = :ok

          else

            cashout_result[:result] =
                "IBAN:#{iban.iban_num} has not been verified. Wrong verification code is entered: #{code}."
            cashout_result[:request_id] = wr.id
            cashout_result[:err_code] = ERR_CODES[:iban_wrong_code]
            request_status = :internal_server_error

          end

        elsif (iban.verified == true)
          wr = WalletRequest.get_wallet_request_for_iban(iban, w)
          e = Entry.create_hold_entry(wr, amount)

          cashout_result[:result] = "Cashout sum held:#{w.holded.to_f+e.amount}"
          cashout_result[:request_id] = wr.id
          cashout_result[:err_code] = ERR_CODES[:no_err]
          request_status = :ok
        end
      end

      respond_to do |format|
        format.json { render :json => cashout_result.as_json, status: request_status }
      end

    rescue
      bad_request= {:result => 'Internal server error is occurred!',
                    :request_id => -1,
                    :err_code => ERR_CODES[:general_err]}
      respond_to do |format|
        format.json { render :json => bad_request.as_json, status: :internal_server_error }
      end
    end
  end

  def complete_cashout
    begin
      cashout=params.require(:complete_cashout).permit(:request_id)

      wr = WalletRequest.find_by_id(cashout[:request_id])
      iban = Iban.find_by_wr_token(wr.token)

      cashout_complete_result = {:result => 'No message.',
                                 :request_id => '-1',
                                 :err_code => ERR_CODES[:no_err]}

      request_status = :ok

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
        cashout_complete_result[:result]="Cashout for IBAN:#{iban.iban_num} has been succesfull."
        cashout_complete_result[:request_id]=wr.id
        cashout_complete_result[:err_code]=ERR_CODES[:no_err]
        request_status=:ok
      else
        cashout_complete_result[:result]="IBAN:#{iban.iban_num} is not verified yet."
        cashout_complete_result[:request_id]=wr.id
        cashout_complete_result[:err_code]=ERR_CODES[:iban_not_verified]
        request_status=:internal_server_error
      end

      respond_to do |format|
        format.json { render :json => cashout_complete_result.as_json, status: request_status }
      end
    rescue
      bad_request={:result => 'Internal server error is occurred!',
                   :request_id => -1,
                   :err_code => ERR_CODES[:general_err]}
      respond_to do |format|
        format.json { render :json => bad_request.as_json, status: :internal_server_error }
      end
    end
  end

  def list

    begin
      list = Iban.find_ibans_by_id($user.id)
      ibans = Array.new

      list.each do |e|
        ibans << {:iban => e.iban_num, :default => e.is_default}
      end

      respond_to do |format|
        format.json { render :json => ibans.as_json, status: :ok }
      end
    rescue
      bad_request={:result => 'Internal server error is occurred!',
                   :request_id => -1,
                   :err_code => ERR_CODES[:general_err]}
      respond_to do |format|
        format.json { render :json => bad_request.as_json, status: :internal_server_error }
      end
    end
  end
end
