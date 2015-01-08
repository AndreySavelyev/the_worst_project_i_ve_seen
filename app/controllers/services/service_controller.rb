class Services::ServiceController < ApplicationController

  include GlobalConstants

  before_action :set_user_from_session, only:  [:new_service, :list, :change]

  def new_service

    service_params = params.require(:service).permit(:text, :meta, :name)

    if ($user != nil) && ($user.wallet_type == GlobalConstants::ACCOUNT_TYPE[:biz])
      service = Services::Service.create_service($user, service_params[:name], service_params[:text], service_params[:meta])
      result = {:result => 0, :offer => service.as_json, :message => 'ok'}
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

  def list
    services = Array.new

    Services::Service.get_all(params[:published]).take(100).collect do |service|
      services << {
          :id => service.id,
          :text => service.text,
          :meta => service.meta,
          :name => service.name
      }
    end

    result = {:result => 0, :services => services.as_json, :message => 'ok'}

    respond_to do |format|
      format.json { render :json => result.as_json, status: :ok }
    end
  end

  def change
    service_params = params.require(:service).permit(:id, :text, :meta, :name, :published)
    if ($user != nil) && ($user.wallet_type == GlobalConstants::ACCOUNT_TYPE[:biz])
      service = Services::Service.update_service(service_params[:id], $user.id, service_params[:published], service_params[:text], service_params[:name], service_params[:meta])
      result = {:result => 0, :offer => service.as_json, :message => 'ok'}
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

end
