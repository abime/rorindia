class CompanyExtractorService
  def initialize(cache_dir: Rails.root.join("storage", "serpapi_cache", "jobs"))
    @cache_dir = cache_dir
  end

  def extract
    companies = {}

    SerpapiJobs::STATES.each do |state|
      file = @cache_dir.join("#{SerpapiJobs.state_slug(state)}.json")
      next unless File.exist?(file)

      data = JSON.parse(File.read(file), symbolize_names: true)

      Array(data[:jobs]).each do |job|
        add_job(companies, state, job)
      end
    end

    companies.values.sort_by { |c| -c[:job_count] }
  end

  private

  def add_job(companies, state, job)
    record = companies[job[:company_name]] ||= {
      company_name: job[:company_name],
      logo: nil,
      job_count: 0,
      states: [],
      locations: [],
      via_sources: [],
      job_ids: []
    }

    record[:logo] ||= job[:thumbnail]
    record[:job_count] += 1
    record[:states] = (record[:states] + [state]).uniq
    record[:locations] = (record[:locations] + [job[:location]]).uniq.compact
    record[:via_sources] = (record[:via_sources] + [job[:via]]).uniq.compact
    record[:job_ids] << job[:job_id]
  end
end
