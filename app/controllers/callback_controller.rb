require 'openssl'

class CallbackController < ApplicationController
  rescue_from ArgumentError, with: :argument_invalid

  def callback
    order = params[:orderXML]

    order_xml = Base64.decode64(order)
    ext_hash = params[:sha512]

    my_hash_old = calc_hash(order_xml,'cqgL1Fw82K3Y')
    my_hash_new = calc_hash(order_xml,'8vWJR3Xs0uw9')

    p 'CallbackController : ext_hash : ' + ext_hash
    p 'CallbackController : my_hash_old : ' + my_hash_old
    p 'CallbackController : my_hash_new : ' + my_hash_new

    if my_hash_old == ext_hash || my_hash_new == ext_hash
      h = CallbackHelper.parse_callback(order_xml)

      puts 'CallbackController : env : ' + Rails.env

      token = Rails.env == 'development' ? '0d0e8674fc76aae2a587ba4c591ebd36' : h['order']['number']

      amount = h['order']['amount']

      puts 'CallbackController : order_xml : ' + order_xml

      Entry.create_cashin_entry(amount, token)
    else
      raise ArgumentError.new('Hashes are not valid.')
    end

    respond_to do |format|
      format.html { render :text => params , status: :ok }
      format.json { render :xml => params , status: :ok }
    end
  end

  def calc_hash(order_xml, secret)
    OpenSSL::Digest.hexdigest('SHA512', order_xml + secret).force_encoding('utf-8')
  end

  def argument_invalid(error)
    respond_to do |format|
      format.html { render :text => error.message , status: 400 }
    end
  end

end
