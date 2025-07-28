class Poem < ApplicationRecord
  PREVIEW_OFFSET = 100

  has_one_attached :preview

  enum :form, %i[haiku limerick]

  after_create :generate_preview

  def self.generate(form: :haiku)
    options = { proper: false }

    case form
    when :haiku
      options[:indent] = "012"
    end

    options[:form] = form

    contents = Poefy::Poem.new("destiny").poem(options).join("\n").downcase
    return nil unless contents.length > 0

    digest = Digest::SHA256.hexdigest(contents)[0...16]

    match = Poem.find_by(digest: digest)
    return match if match.present?

    create!(digest: digest, form: form, contents: contents)
  end

  def to_s
    contents
  end

  def to_a
    contents.split("\n").each(&:strip!)
  end

  private

  def generate_preview
    text = Vips::Image.text(
      to_s,
      font: "alice",
      fontfile: Rails.root.join("app", "assets", "fonts", "alice.ttf").to_s,
      dpi: 300
    )

    return nil unless text.present?

    image = Vips::Image.black(text.width + PREVIEW_OFFSET, text.height + PREVIEW_OFFSET).cast("uchar").copy(interpretation: :rgb)
    return nil unless image.present?

    composite = image.composite(text, "over", x: PREVIEW_OFFSET / 2, y: PREVIEW_OFFSET / 2)
    return nil unless composite.present?

    buffer = StringIO.new(composite.write_to_buffer(".jpg"))
    preview.attach(io: buffer, filename: "#{digest}.jpg", content_type: "image/jpeg", identify: false)
  end
end
