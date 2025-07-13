class PostToBlueskyJob < ApplicationJob
  queue_as :default

  def perform(*args)
    if Yonder.create_session(username: ENV["BLUESKY_USERNAME"], password: ENV["BLUESKY_PASSWORD"])
      Yonder.create_post(user_did: Yonder.session.user_did, message: Poem.generate.contents)
    end
  rescue Yonder::Error => e
    Rails.logger.error("Failed to post to Bluesky: #{e}")
  end
end
