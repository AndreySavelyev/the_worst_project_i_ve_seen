class WalletController < ApplicationController

  include GlobalConstants

  before_action :set_user_from_session, only: [:cashin, :cashout, :complete_cashout, :list, :decline_pay_request]

  def cashin
    w = Wallet::get_wallet($user)
    wr = WalletRequest.create_cash_in_wallet_request(w.id)
    respond_to do |format|
      format.json { render :json => wr.as_json, status: :ok }
    end
  end

  def cashout

    begin

      cashout = params.require(:cashout).permit(:iban, :amount, :code)

      iban_num = cashout[:iban]
      amount = cashout[:amount]
      code = cashout[:code]

      iban = Iban.get_iban($user, iban_num)
      cashout_result = {:result => '0', :request_id => '-1', :code => 200}

      w = Wallet.get_wallet($user)

      if amount.to_f > w.available
        no_money_error = GlobalConstants::RESULT_CODES[:no_money]
        cashout_result[:result] = no_money_error[:result]
        cashout_result[:message] = no_money_error[:message]
        cashout_result[:code] = no_money_error[:code]
      else
        if iban.verified == false

          wr = WalletRequest.get_wallet_request_for_iban(iban, w)

          if !WalletHelper.check_iban_validation_code(code.to_s)
            Emailer
            .email_unverified_iban('vk@onlinepay.com', $user, iban_num, amount, wr.id)
            .deliver

            not_verified = GlobalConstants::RESULT_CODES[:not_verified]

            cashout_result[:result] = not_verified[:result]
            cashout_result[:message] = not_verified[:message]
            cashout_result[:code] = not_verified[:code]
            cashout_result[:request_id] = wr.id

          elsif !code.to_s.empty? && iban.code == code.to_i

            iban.verified = true
            iban.save!

            e = Entry.create_hold_entry(wr, amount)

            Emailer
            .email_verified_iban('vk@onlinepay.com', $user, iban_num, amount, wr.id)
            .deliver

            verified = GlobalConstants::RESULT_CODES[:verified]

            cashout_result[:result] = verified[:result]
            cashout_result[:message] = "IBAN verified, cashout sum held:#{e.amount}"
            cashout_result[:code] = verified[:code]
            cashout_result[:request_id] = wr.id
          else

            not_match = GlobalConstants::RESULT_CODES[:not_match]

            cashout_result[:result] = not_match[:result]
            cashout_result[:message] = not_match[:message]
            cashout_result[:code] = not_match[:code]

            cashout_result[:request_id] = wr.id
          end
        elsif iban.verified == true

          wr = WalletRequest.get_wallet_request_for_iban(iban, w)
          e = Entry.create_hold_entry(wr, amount)

          hold_ok = GlobalConstants::RESULT_CODES[:hold_complete]

          cashout_result[:result] = hold_ok[:result]
          cashout_result[:message] = "Cashout sum held:#{w.holded.to_f+e.amount}"
          cashout_result[:code] = hold_ok[:code]

          cashout_result[:request_id] = wr.id

        end
      end

      respond_to do |format|
        format.json { render :json => cashout_result.as_json, status: cashout_result[:result] }
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

      if iban.verified

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

  def decline_pay_request

    request_id = params[:requestId]
    pr = PayRequest.find(request_id)

    begin
      pr.decline_pay_request($user.id)
      result = {:result => 0, :message => 'payment canceled by user', code: 200}
    rescue PaymentRequest::NotOwner
      result = {:result => 401, :message => 'not an owner', code: 401}
    end

    respond_to do |format|
      format.json { render :json => result.as_json, status: result[:code] }
    end

  end

end
