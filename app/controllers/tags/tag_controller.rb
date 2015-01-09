class Tags::TagController < ApplicationController

  include GlobalConstants
  before_action :set_user_from_session, only:  [:tag_services, :get_services]

  def tag_services

    service_params = params.require(:service).permit(:id, :tags, :remove)

    if ($user != nil) && ($user.wallet_type == GlobalConstants::ACCOUNT_TYPE[:biz])
      service = Services::Service.get(service_params[:id], $user.id).set_tags(service_params[:tags], service_params[:remove])
      result = {:result => 0, :service => service.as_json, :message => 'ok'}
      respond_to do |format|
        format.json { render :json => result.as_json, status: :ok }
      end
    else
      result = {:result => -1, :message => 'forbidden'}
      respond_to do |format|
        format.json { render :json => result.as_json, status: :forbidden }
      end
    end

  end

  def get_services
    service_params = params.require(:tags).permit(:values)

    services = Array.new

    Services::Service.all_tags(service_params[:values].split(',').collect(&:strip).uniq).collect do |service|
      services << {
          :id => service.id,
          :text => service.text,
          :meta => service.meta,
          :name => service.name,
          :pic => service.avatar.url(:thumb)
      }
    end

    result = {:result => 0, :services => services.as_json, :message => 'ok'}

    respond_to do |format|
      format.json { render :json => result.as_json, status: :ok }
    end
  end
end
