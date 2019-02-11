# name: discourse-code-review-webhooks
# about: A plugin for connecting two Discourse instances for code review
# version: 0.1
# authors: ProCourse
# url: https://github.com/procourse/discourse-code-review-webhooks

enabled_site_setting :code_review_webhooks_enabled

after_initialize do
  PluginName = 'discourse-code-review-webhooks'
  module ::DiscourseCodeReviewWebhooks
    class Engine < ::Rails::Engine
      engine_name 'code-review-webhooks'
      isolate_namespace DiscourseCodeReviewWebhooks
    end

    DiscourseCodeReviewWebhooks::Engine.routes.draw do
      post '/review-post' => 'code_review_webhooks#review_post'
    end

    Discourse::Application.routes.append do
      mount ::DiscourseCodeReviewWebhooks::Engine, at: '/code-review-hooks'
    end
  end
  require File.expand_path("../app/controllers/code_review_webhooks/code_review_webhooks_controller.rb", __FILE__)
end
