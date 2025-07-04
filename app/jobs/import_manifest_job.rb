require "poefy/sqlite3"

class ImportManifestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Restiny.api_key = ENV["DESTINY_API_KEY"]

    Rails.logger.info("Fetching latest lore manifest...")

    manifest = Restiny.download_manifest_json(definitions: [ Restiny::ManifestDefinition::LORE ])
    path = manifest.values.first

    database_path = Rails.root.join("storage", "corpus.sqlite3")
    poefy = Poefy::Poem.new(database_path, local: true)
    lines = []

    Rails.logger.info("Preparing data...")

    JSON.parse(File.read(path)).map do |key, entry|
      description = entry.dig("displayProperties", "description").gsub(/[^a-z\u00C0-\u024F\u1E00-\u1EFF.,'\s\!\?]/i, " ").gsub(/\s{2,}/, " ")

      description.split(/\n\n|\.|,|—|;/).each do |line|
        lines << line.strip.gsub(/^'|'$|^.+\: /i, "") if line.length > 1
      end
    end.compact.join("\n")

    Rails.logger.info("Storing lines in #{database_path}...")

    poefy.make_database!(lines)
    poefy.close

    Rails.logger.info("Done.")
  end
end
