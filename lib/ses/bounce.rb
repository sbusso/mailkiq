module SES
  class Bounce < Fog::Model
    identity :id, aliases: 'feedbackId'
    attribute :bounce_sub_type, aliases: 'bounceSubType'
    attribute :bounce_type, aliases: 'bounceType'
    attribute :reporting_mta, aliases: 'reportingMTA'
    attribute :bounced_recipients, aliases: 'bouncedRecipients'
    attribute :timestamp, type: :timestamp

    def bounced_recipients=(json)
      attributes[:bounced_recipients] = SES::BouncedRecipients.new.load(json)
    end
  end
end