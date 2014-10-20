require 'openssl'

class CallbackController < ApplicationController

  #rescue_from ArgumentError, with: :argument_invalid
  def callback
    order = params[:orderXML]

    order_xml = Base64.decode64(order)
    ext_hash = params[:sha512]

    secret = 'cqgL1Fw82K3Y';

    my_order = order_xml + secret;
    my_hash = OpenSSL::Digest.hexdigest("SHA512", my_order).force_encoding('utf-8');

    p my_hash
    p ext_hash

    if my_hash == ext_hash
      h = CallbackHelper.parse_callback(order_xml)      
      token = h["order"]["number"]      
      amount = h["order"]["amount"]     
      puts order_xml     
      Entry.create_cashin_entry(amount, token)            
    else
      raise ArgumentError.new('Hashes are not valid.');
    end

    respond_to do |format|
      format.html { render :text => params , status: :ok }
      format.json { render :xml => params , status: :ok }
    end
  end

  def argument_invalid(error)
    respond_to do |format|
      format.html { render :text => error.message , status: 400 }
    end
  end
   
end
