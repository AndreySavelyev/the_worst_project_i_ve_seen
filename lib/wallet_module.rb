module WalletModule
  def brief
    @hotOffers = Object
    @hotOffers =
        { :brief =>
              {
                  :likes => '231',
                  :currency => 'usd',
                  :balance => '30.380',
                  :name => 'john smith',
                  :mood => 4,
                  :userpic => 'url'
              } }
    respond_to do |format|
      format.json { render :json => @hotOffers.as_json, status: :ok }
    end
  end

end