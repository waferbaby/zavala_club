class PostToBlueskyJob < ApplicationJob
  queue_as :default

  def perform(poem_id: nil)
    session_data = Rails.cache.fetch(:zavala_club_bluesky_session) do
      Yonder.create_session(username: ENV["BLUESKY_USERNAME"], password: ENV["BLUESKY_PASSWORD"])
      Marshal.dump(Yonder.session)
    end

    session = Marshal.load(session_data)
    poem = poem_id ? Poem.find(poem_id) : Poem.generate

    begin
      Yonder.create_post(user_did: session.user_did, message: poem.contents)
    rescue Yonder::TokenExpiredError => e
      Rails.logger.warn("Auth token expired - requesting new tokens")

      if Yonder.renew_session(session[:refresh_token])
        Rails.cache.write(:zavala_club_bluesky_session, Marshal.dump(Yonder.session))
        self.perform_later(poem_id: poem.id)
      end
    end
  rescue Yonder::Error => e
    Rails.logger.error("Failed to post to Bluesky: #{e}")
  end
end
