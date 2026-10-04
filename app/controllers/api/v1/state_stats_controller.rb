# Serves the state -> job count JSON built by `rake serpapi:fetch_map_feeder`
# (map_feeder.json) as-is; the map page matches state names to the SVG.
class Api::V1::StateStatsController < ApplicationController
  SOURCE = Rails.root.join("storage", "serpapi_cache", "map_feeder.json")

  def index
    path = ENV["STATE_STATS_FILE"].presence || SOURCE
    if File.exist?(path)
      render json: File.read(path)
    else
      render json: {}
    end
  end
end
