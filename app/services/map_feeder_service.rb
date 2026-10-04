class MapFeederService
  def initialize(cache_dir: Rails.root.join("storage", "serpapi_cache", "jobs"))
    @cache_dir = cache_dir
  end

  def build
    counts = Hash.new(0)

    SerpapiJobs::STATES.each do |location|
      file = @cache_dir.join("#{SerpapiJobs.state_slug(location)}.json")
      next unless File.exist?(file)

      data = JSON.parse(File.read(file), symbolize_names: true)
      region = SerpapiJobs.region_for(location)
      counts[region] += data[:total_results].to_i
    end

    counts
  end
end
