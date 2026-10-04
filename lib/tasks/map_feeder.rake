namespace :serpapi do
  desc "Build state -> job count map feeder JSON from cached job data (does not call SerpApi)"
  task fetch_map_feeder: :environment do
    out_dir = Rails.root.join("storage", "serpapi_cache")
    FileUtils.mkdir_p(out_dir)

    counts = MapFeederService.new.build

    file = out_dir.join("map_feeder.json")
    File.write(file, JSON.pretty_generate(counts))

    puts "[serpapi:fetch_map_feeder] #{counts.size} states -> #{file}"
    counts.each { |state, count| puts "  #{state}: #{count}" }
  end
end
