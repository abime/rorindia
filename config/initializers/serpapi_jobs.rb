module SerpapiJobs
  # Mix of states and cities on purpose: bare state names (e.g. "Maharashtra")
  # returned 0 relevant results from google_jobs in testing, while the same
  # query against a city within that state (e.g. "Pune") returned 10/10.
  # "Delhi NCR" is not a canonical Google location on its own, so it is
  # represented by its three main tech-hub cities instead (see
  # REGION_FOR_LOCATION below for how these roll back up for the map).
  STATES = ["Karnataka", "Pune", "Mumbai", "New Delhi", "Gurugram", "Noida", "Rajasthan", "Madhya Pradesh"].freeze

  # Google's location targeting expects "City, State, India" for cities, not
  # just "City, India" — override the default format for entries where that
  # matters (bare state names don't need an override).
  LOCATION_QUERY_OVERRIDES = {
    "New Delhi" => "New Delhi, Delhi, India",
    "Gurugram" => "Gurugram, Haryana, India",
    "Noida" => "Noida, Uttar Pradesh, India"
  }.freeze

  # How fetch-granularity locations roll up into the real state/region used
  # for the India map (most entries map to themselves).
  REGION_FOR_LOCATION = {
    "Pune" => "Maharashtra",
    "Mumbai" => "Maharashtra",
    "New Delhi" => "Delhi NCR",
    "Gurugram" => "Delhi NCR",
    "Noida" => "Delhi NCR"
  }.freeze

  JOB_TITLES = [
    "Software Engineer",
    "Senior Software Engineer"
  ].freeze

  SKILL = "Ruby on Rails".freeze

  def self.query_for(_state = nil)
    titles = JOB_TITLES.map { |t| "\"#{t}\"" }.join(" OR ")
    "(#{titles}) #{SKILL}"
  end

  def self.location_for(state)
    LOCATION_QUERY_OVERRIDES.fetch(state, "#{state}, India")
  end

  def self.region_for(state)
    REGION_FOR_LOCATION.fetch(state, state)
  end

  def self.state_slug(state)
    state.downcase.strip.gsub(/[^a-z0-9]+/, "_")
  end
end
