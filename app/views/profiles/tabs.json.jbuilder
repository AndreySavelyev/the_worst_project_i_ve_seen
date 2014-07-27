#json.extract! @tabs, :social, :services, :shopping
respond_to do |format|
  format.json { render :json => @tabs.as_json, status: :ok }
end
