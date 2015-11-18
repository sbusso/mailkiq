class SettingsController < ApplicationController
  before_action :require_login
  layout 'admin'

  def profile
    update profile_params if request.put?
  end

  def aws
    update aws_params if request.put?
  end

  private

  def update(account_params)
    current_user.update account_params
    respond_with current_user, flash_now: true
  end

  def profile_params
    params.require(:account).permit :name, :email, :password, :language,
                                    :time_zone
  end

  def aws_params
    params.require(:account).permit :aws_access_key_id, :aws_secret_access_key,
                                    :aws_region
  end
end
