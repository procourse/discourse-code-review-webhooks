require 'json'
module DiscourseCodeReviewWebhooks
    class CodeReviewWebhooksController < ::ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :redirect_to_login_if_required
      skip_before_action :check_xhr

      def review_post
        payload = JSON.parse(request.body.read)
        post = payload['post']

        # Check if topic id in brackets exists
        topic_title = post['topic_title']
        team_topic_id = topic_title[/\[\d*\]/] || nil

        if post['post_number'].to_i == 1 && team_topic_id != nil # if not first post or doesn't have topic id in brackets, skip
          post_number = post['post_number']
          review_user = post['username']
          team_topic_id = team_topic_id.tr('[]','').to_i 
          review_topic_id = post['topic_id']
          review_link_text = "<a href='#{SiteSetting.code_review_webhooks_review_site_url}/t/#{review_topic_id}'>#{post['topic_title']}</a>"

          topic = Topic.find_by(id: team_topic_id)
          poster = User.find_by(id: SiteSetting.code_review_webhooks_post_user)
          action_user = User.find_by(username: review_user) || poster # check if there's a matching username on the receiving site from the webhook, default to discobot (-2) if not

          topic.add_moderator_post(
            poster,
            review_link_text,
            bump: true,
            post_type: Post.types[:small_action],
            action_code: "commit",
            custom_fields: { "action_code_who" => action_user.username }
          )
        end

        render plain: '"ok"'
      end
    end
end
