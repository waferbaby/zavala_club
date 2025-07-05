class Poem < ApplicationRecord
  enum :form, [ :haiku, :limerick ]

  def self.generate(form = :haiku)
    options = { proper: false }

    case form
    when :haiku
      options[:indent] = "012"
    end

    options[:form] = form

    contents = Poefy::Poem.new(database_path, local: true).poem(options).join("\n")
    return nil unless contents.length > 0

    digest = Digest::SHA256.hexdigest(contents)[0...10]

    match = Poem.find_by(digest: digest)
    return match if match.present?

    create!(digest: digest, form: form, contents: contents)
  end

  def to_s
    contents.downcase
  end

  def self.database_path
    Rails.root.join("storage", "corpus.sqlite3")
  end
end
