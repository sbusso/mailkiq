class LeadsController < ApplicationController
  before_action :set_account

  def create
    @subscriber = @account.subscribers.find_or_create_by lead_params
    respond_with @subscriber, flash_now: false do |format|
      format.html { redirect_to root_path }
    end
  end

  private

  def lead_params
    params.require(:lead).permit :email
  end

  def set_account
    @account = Account.find_by email: 'rainerborene@gmail.com'
  end
end
