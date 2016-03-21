class CampaignsController < ApplicationController
  before_action :require_login
  before_action :find_campaign, except: [:index, :new, :create]

  has_scope :page, default: 1
  has_scope :sort

  def index
    @campaigns = apply_scopes current_user.campaigns
    @campaigns = @campaigns.recents unless current_scopes.key?(:sort)
  end

  def new
    @campaign = current_user.campaigns.new
  end

  def create
    @campaign = current_user.campaigns.create campaign_params
    respond_with @campaign, location: campaigns_path
  end

  def edit
  end

  def update
    @campaign.update campaign_params
    respond_with @campaign, location: campaigns_path
  end

  def destroy
    @campaign.destroy
    Sidekiq::Queue.new(@campaign.queue_name).clear
    respond_with @campaign, location: campaigns_path
  end

  def preview
    render layout: false
  end

  def duplicate
    @new_campaign = @campaign.duplicate
    @new_campaign.save
    respond_with @new_campaign, flash_now: false do |format|
      format.html { redirect_to campaigns_path }
    end
  end

  private

  def find_campaign
    @campaign = current_user.campaigns.find params[:id]
  end

  def campaign_params
    params.require(:campaign).permit :name, :subject, :from_name, :from_email,
                                     :html_text, :plain_text
  end
end
