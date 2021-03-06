class DomainsController < ApplicationController
  before_action :authenticate_account!

  def show
    @domain = current_account.domains.find params[:id]
  end

  def create
    @domain = current_account.domains.new domain_params
    @domain.identity_verify!
    respond_with @domain, flash_now: false do |format|
      format.html { redirect_to edit_settings_path }
    end
  end

  def destroy
    @domain = current_account.domains.find params[:id]
    @domain.identity_delete!
    respond_with @domain, flash_now: false, location: edit_settings_path
  end

  private

  def domain_params
    params.require(:domain).permit :name
  end
end
