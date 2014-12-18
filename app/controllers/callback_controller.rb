require 'openssl'

class CallbackController < ApplicationController
  rescue_from ArgumentError, with: :argument_invalid

  def callback
    order = params[:orderXML]

    order_xml = Base64.decode64(order)
    ext_hash = params[:sha512]

    logger.debug "CallbackController :: New order received: #{order_xml} : with hash: #{ext_hash}"

    my_hash_old = calc_hash(order_xml,'cqgL1Fw82K3Y')
    my_hash_new_production = calc_hash(order_xml,'8vWJR3Xs0uw9')
    my_hash_new_staging = calc_hash(order_xml,'lLCo39SpYb15')

    logger.debug "CallbackController :: Hash calculated: old #{my_hash_old} : new_production: #{my_hash_new_production} : new_staging: #{my_hash_new_staging}"

    if my_hash_old == ext_hash || my_hash_new_production == ext_hash || my_hash_new_staging == ext_hash
      h = CallbackHelper.parse_callback(order_xml)

      token = Rails.env == 'development' ? '0d0e8674fc76aae2a587ba4c591ebd36' : h['order']['number']

      amount = h['order']['amount']

      Entry.create_cashin_entry(amount, token)

      logger.debug "CallbackController :: Entry created: amount #{amount} : token: #{token}"

    else
      logger.error 'CallbackController :: Hashes are not valid'
      raise ArgumentError.new('Hashes are not valid.')
    end

    respond_to do |format|
      format.text { render :text => 'OK', status: :ok }
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
