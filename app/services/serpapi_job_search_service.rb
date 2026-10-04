require "serpapi"

class SerpapiJobSearchService
  ENGINE = "google_jobs".freeze
  RELEVANCE_PATTERN = /ruby/i

  def initialize(client: nil, api_key: ENV.fetch("SERPAPI_KEY"))
    @client = client || SerpApi::Client.new(engine: ENGINE, api_key: api_key, persistent: true, timeout: 120)
  end

  def search_state(state)
    query = SerpapiJobs.query_for(state)
    location = SerpapiJobs.location_for(state)

    raw = @client.search(q: query, location: location, gl: "in", hl: "en")
    fetched = Array(raw[:jobs_results]).map { |job| normalize_job(job) }
    jobs = fetched.select { |job| relevant?(job) }

    {
      state: state,
      query: query,
      location: location,
      fetched_at: Time.now.utc.iso8601,
      total_fetched: fetched.size,
      total_results: jobs.size,
      jobs: jobs
    }
  end

  private

  # Google Jobs treats `location` as a soft bias, not a hard filter, and will
  # backfill with loosely-related postings (wrong skill, wrong state) when it
  # can't find enough real matches — so we filter for actual relevance here
  # rather than trusting the query/location alone.
  def relevant?(job)
    RELEVANCE_PATTERN.match?("#{job[:title]} #{job[:description]}")
  end

  def normalize_job(job)
    {
      title: job[:title],
      company_name: job[:company_name],
      location: job[:location],
      via: job[:via],
      description: job[:description],
      job_id: job[:job_id],
      detected_extensions: job[:detected_extensions],
      extensions: job[:extensions],
      apply_options: job[:apply_options],
      thumbnail: job[:thumbnail]
    }
  end
end
