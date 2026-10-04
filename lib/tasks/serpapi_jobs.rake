namespace :serpapi do
  desc "Fetch Ruby on Rails job postings per Indian state via SerpApi (google_jobs engine)"
  task fetch_jobs: :environment do
    cache_dir = Rails.root.join("storage", "serpapi_cache", "jobs")
    FileUtils.mkdir_p(cache_dir)

    client = SerpApi::Client.new(engine: SerpapiJobSearchService::ENGINE, api_key: ENV.fetch("SERPAPI_KEY"), persistent: true, timeout: 120)
    service = SerpapiJobSearchService.new(client: client)

    manifest = {}
    failures = []

    SerpapiJobs::STATES.each do |state|
      puts "[serpapi:fetch_jobs] Fetching #{state}..."
      begin
        result = service.search_state(state)
        slug = SerpapiJobs.state_slug(state)
        file = cache_dir.join("#{slug}.json")
        File.write(file, JSON.pretty_generate(result))

        manifest[state] = {
          count: result[:total_results],
          fetched_at: result[:fetched_at],
          cache_file: file.relative_path_from(Rails.root).to_s
        }
        puts "[serpapi:fetch_jobs] #{state}: #{result[:total_results]}/#{result[:total_fetched]} relevant jobs -> #{file}"
      rescue SerpApi::SerpApiError => e
        puts "[serpapi:fetch_jobs] FAILED for #{state}: #{e.message} (status=#{e.response_status}, serpapi_error=#{e.serpapi_error})"
        failures << { state: state, error: e.message }
      rescue StandardError => e
        puts "[serpapi:fetch_jobs] FAILED for #{state}: unexpected #{e.class}: #{e.message}"
        failures << { state: state, error: e.message }
      end
    end

    client.close

    manifest_file = cache_dir.join("manifest.json")
    File.write(manifest_file, JSON.pretty_generate(manifest))
    puts "[serpapi:fetch_jobs] Manifest written -> #{manifest_file}"

    puts "\n[serpapi:fetch_jobs] Done. #{SerpapiJobs::STATES.size - failures.size}/#{SerpapiJobs::STATES.size} states succeeded."
    if failures.any?
      puts "[serpapi:fetch_jobs] Failures:"
      failures.each { |f| puts "  - #{f[:state]}: #{f[:error]}" }
    end
  end
end
