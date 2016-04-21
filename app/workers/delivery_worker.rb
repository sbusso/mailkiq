class DeliveryWorker
  @queue = :deliveries

  def self.perform(campaign_id, tagged_with, not_tagged_with)
    campaign = Campaign.find campaign_id
    delivery = Delivery.new campaign: campaign,
                            tagged_with: tagged_with,
                            not_tagged_with: not_tagged_with

    jobs = delivery.jobs

    campaign.queue.push_bulk(jobs)
    campaign.update_columns recipients_count: jobs.size, sent_at: Time.now
  end
end
