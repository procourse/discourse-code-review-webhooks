module DiscourseCodeReviewWebhooks
    class CodeReviewWebhooksController < ::ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :redirect_to_login_if_required
      skip_before_action :check_xhr

      def review_post
        byebug
        post = params[:post]
        post_number = post['post_number']
        topic_title = post['topic_title']
        review_topic_id = post['topic_id']
        team_topic_id = topic_title[/[(.*?)]/m,1].to_i
        review_link_text = "#{SiteSetting.code_review_webhooks_review_site_url}/t/#{review_topic_id}"
        cooked = post['cooked']

        post_text = "#{review_link_text}\n\n#{cooked}"

        # if not the first post, return
        render plain: '"ok"' if post['id'].to_i != 1
        post_user = User.find_by(username: SiteSetting.code_review_webhooks_post_user)
        manager = NewPostManager.new(post_user, cooked: post_text, topic_id: team_topic_id)

        render plain: '"ok"'
      end
    end
end
