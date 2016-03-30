class QuotaPresenter < SimpleDelegator
  attr_reader :account

  def initialize(account, view_context)
    @account = account
    __setobj__(view_context)
  end

  delegate :max_24_hour_send, :max_send_rate, :sent_last_24_hours, to: :quota

  def quota
    @quota ||= Aws::SES::Types::GetSendQuotaResponse.new(
      cache(:quota) { ses.get_send_quota.as_json }
    )
  end

  def sandbox?
    max_24_hour_send == 200
  end

  def human_send_rate
    t 'dashboard.show.send_rate', rate: pluralize(max_send_rate.to_i, 'email')
  end

  def human_sending_limits
    t 'dashboard.show.sending_limits',
      count: number_with_delimiter(sent_last_24_hours),
      remaining: number_with_delimiter(max_24_hour_send)
  end

  def sandbox_badge_tag
    content_tag :span, t('dashboard.show.sandbox'), class: 'label label-default'
  end

  def send_statistics
    cache :send_statistics do
      values = ses.get_send_statistics.send_data_points
      values.group_by { |data| data.timestamp.to_date }.map do |k, v|
        {
          Timestamp: k,
          Complaints: v.map(&:complaints).inject(:+),
          Rejects: v.map(&:rejects).inject(:+),
          Bounces: v.map(&:bounces).inject(:+),
          DeliveryAttempts: v.map(&:delivery_attempts).inject(:+)
        }
      end
    end
  end

  private

  def ses
    @ses ||= Aws::SES::Client.new(account.credentials)
  end

  def cache(name, &block)
    Rails.cache.fetch("#{account.cache_key}/#{name}", &block)
  end
end
