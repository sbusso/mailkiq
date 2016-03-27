class DomainsController < ApplicationController
  before_action :require_login

  def create
    @domain = current_user.domains.new domain_params
    @domain.identity_verify!
    respond_with @domain, flash_now: false do |format|
      format.html { redirect_to domains_settings_path }
    end
  end

  def destroy
    @domain = current_user.domains.find params[:id]
    @domain.identity_delete!
    respond_with @domain, flash_now: false, location: domains_settings_path
  end

  private

  def domain_params
    params.require(:domain).permit :name
  end
end
