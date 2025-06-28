class Api::V1::AnalyticsController < ApplicationController
  def shows_with_episode_stats
    @shows = Show.shows_with_episode_stats
    add_cache_headers(@shows)
    render json: { data: @shows }
  end

  def top_rated_by_genre
    limit = params[:limit]&.to_i || 5
    @shows = Show.top_rated_by_genre(limit: limit)
    add_cache_headers(@shows)
    render json: { data: @shows.as_json(except: [:id]) }
  end

  def network_performance
    @networks = Show.network_performance_analysis
    add_cache_headers(@networks)
    render json: { data: @networks.as_json(except: [:id]) }
  end

  def monthly_trends
    year = params[:year]&.to_i || Date.current.year
    @trends = Show.monthly_episode_trends(year: year)
    add_cache_headers(@trends)
    render json: { data: @trends.as_json(except: [:id]) }
  end

  def country_distribution
    @distribution = Show.country_distribution
    add_cache_headers(@distribution)
    render json: { data: @distribution.as_json(except: [:id]) }
  end

  private

  def add_cache_headers(data)
    response.headers['Cache-Control'] = 'public, max-age=300' # 5 minutes cache
    response.headers['ETag'] = Digest::MD5.hexdigest(data.to_json + params.to_json)
  end
end 