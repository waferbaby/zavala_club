class PostToBlueskyJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Yonder.create_post(user_did: Yonder.session.user_did, message: Poem.generate.contents) if Yonder.create_session(username: ENV["BLUESKY_USERNAME"], password: ENV["BLUESKY_PASSWORD"])
  rescue Yonder::Error => e
    Rails.logger.error("Failed to post to Bluesky: #{e}")
  end
end
