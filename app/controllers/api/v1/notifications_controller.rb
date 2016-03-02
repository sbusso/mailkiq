module API::V1
  class NotificationsController < BaseController
    before_action :validate_amazon_headers
    before_action :authenticate!

    def create
      @message_body = request.body.read
      @verifier = Fog::AWS::SNS::MessageVerifier.new
      @verifier.authenticate! @message_body
      @sns = Fog::AWS::SNS::Notification.new JSON.parse(@message_body)

      if @sns.subscription_confirmation?
        sns = Fog::AWS::SNS.new(current_account.credentials)
        sns.confirm_subscription @sns.topic_arn, @sns.token
      elsif @sns.ses?
        message_id = find_message_uuid(@sns.message.mail.id)
        Notification.create! message_id: message_id,
                             type: @sns.message.type.downcase,
                             metadata: @sns.data.as_json

        current_account.subscribers.where(email: @sns.emails)
          .update_all state: Subscriber.states[@sns.state]
      end

      head :ok
    end

    private

    def find_message_uuid(uuid)
      Message.where(uuid: @sns.message.mail.id).pluck(:id).first
    end

    def sns?
      request.headers['X-Amz-Sns-Topic-Arn'].to_s.start_with?('arn:aws:sns')
    end

    def validate_amazon_headers
      render json: { message: 'Invalid Amazon SES notification.' },
             status: :unauthorized unless sns?
    end
  end
end
