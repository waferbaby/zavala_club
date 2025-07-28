require "poefy/pg"

class ImportManifestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Restiny.api_key = Rails.application.credentials.destiny.api_key

    Rails.logger.info("Fetching latest manifests...")

    definitions = [
      Restiny::ManifestDefinition::INVENTORY_ITEM,
      Restiny::ManifestDefinition::LORE
    ]

    poefy = Poefy::Poem.new("destiny")
    lines = []

    Restiny.download_manifest_json(definitions: definitions).each do |key, path|
      source = key.gsub(/Destiny|Definition/, "").underscore.to_sym

      Rails.logger.info("Preparing #{source} data...")

      JSON.parse(File.read(path)).map do |key, entry|
        text = case source
        when :lore
                 entry.dig("displayProperties", "description")
        when :inventory_item
                 entry["flavorText"]
        end

        next if text.nil?

        text = text.gsub(/[^a-z\u00C0-\u024F\u1E00-\u1EFF.,'\s!?]/i, " ").gsub(/\s{2,}/, " ")

        text.split(/\n\n|\.|,|—|;/).each do |line|
          lines << line.strip.gsub(/^'|'$|^.+: /i, "") if line.length > 1
        end
      end
    end

    Rails.logger.info("Storing #{lines.count} lines...")

    poefy.make_database!(lines.compact.join("\n"))
    poefy.close

    Rails.logger.info("Done.")
  end
end
