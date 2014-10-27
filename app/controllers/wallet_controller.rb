class WalletController < ApplicationController
  
  before_action :set_user_from_session, only:  [:cashin, :payout, :complete_payout]
  
  def cashin
    w = Wallet::get_wallet($user)
      wr = WalletRequest.create_cash_in_wallet_request(w.id)
    respond_to do |format|
      format.json { render :json => wr.as_json, status: :ok }
    end
  end

  def payout
    begin
      payout=params.require(:payout).permit(:iban, :amount, :code);

      iban_num = payout[:iban];
      amount = payout[:amount];
      code = payout[:code];

      iban = Iban.get_iban($user, iban_num);
      payout_result = {:result => '0', :request_id => '-1'};

      w = Wallet.get_wallet($user);

      if (iban.verified == false)

        wr = WalletRequest.get_wallet_request_for_iban(iban, w);

        if (code==nil)
          Emailer
          .email_unverified_iban('vk@onlinepay.com', $user, iban_num, amount, wr.id)
          .deliver;

          payout_result[:result] = 'No verified';
          payout_result[:request_id] = wr.id;
        elsif (iban.code==code.to_i)

          iban.verified = true;
          iban.save!;

          e = Entry.create_hold_entry(wr, amount);

          Emailer
          .email_verified_iban('vk@onlinepay.com', $user, iban_num, amount, wr.id)
          .deliver;

          payout_result[:result] = "IBAN verified, payout sum held:#{e.amount}";
          payout_result[:request_id] = wr.id;
        else
          payout_result[:result] = 'IBAN didn\'t verified. Wrong code.';
          payout_result[:request_id] = wr.id;
        end
      elsif (iban.verified == true)

        wr = WalletRequest.get_wallet_request_for_iban(iban, w);

        e = Entry.create_hold_entry(wr, amount);

        payout_result[:result] = "Payout sum held:#{w.holded.to_f+e.amount}";
        payout_result[:request_id] = wr.id;

      end

      respond_to do |format|
        format.json { render :json => payout_result.as_json, status: :ok }
      end

    rescue
      @bad_request={:result => 'Internal Error!'}
      respond_to do |format|
        format.json { render :json => @bad_request.as_json, status: :internal_server_error }
      end
    end
  end

  def complete_payout
    begin
      payout=params.require(:complete_payout).permit(:request_id);
      wr = WalletRequest.where("id = :id", :id => payout[:request_id]).first;
      iban = Iban.where("wr_token = :wr_token", :wr_token => wr.token).first;

      entries = Entry.where("payment_request_id = :payment_request_id", :payment_request_id => wr.id).to_a;

      sum_payout = 0;

      entries.each do |e|
        sum_payout += e.amount;
      end

      ep = Entry.create_payout_entry(wr, sum_payout);

      iban.wr_token = nil;
      iban.save!;

      Emailer.email_payout_success($user.email, iban.iban_num, sum_payout, wr.id)
      .deliver;

      Emailer.email_payout_success('vk@onlinepay.com', iban.iban_num, sum_payout, wr.id)
      .deliver;

      respond_to do |format|
        format.json { render :json => {:result => 'Payout succesfull'}.as_json, status: :ok }
      end
    rescue
      @bad_request={:result => 'Internal Error!'}
      respond_to do |format|
        format.json { render :json => @bad_request.as_json, status: :internal_server_error }
      end
    end
  end
  
end
