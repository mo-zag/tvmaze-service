class Api::V1::TvShowsController < ApplicationController
  before_action :set_pagination_params

  def index
    @shows = Show.includes(:network, :genres, :episodes)
                 .joins(:episodes)
                 .where(episodes: { airdate: date_range })
                 .distinct

    # Apply filters
    @shows = apply_filters(@shows)

    # Apply pagination
    @shows = @shows.page(@page).per(@per_page)

    # Add cache headers for deterministic responses
    response.headers['Cache-Control'] = 'public, max-age=300' # 5 minutes cache
    response.headers['ETag'] = generate_etag(@shows)

    render json: {
      data: @shows.map { |show| show_serializer(show) },
      meta: {
        page: @page,
        per_page: @per_page,
        total_count: @shows.total_count,
        total_pages: @shows.total_pages,
        filters: {
          date_from: params[:date_from] || Date.today.to_s,
          date_to: params[:date_to] || (Date.today + 90.days).to_s,
          country: params[:country],
          distributor: params[:distributor],
          rating: params[:rating],
          genre: params[:genre]
        }
      }
    }
  end

  def show
    @show = Show.includes(:network, :genres, :episodes).find(params[:id])
    
    # Add cache headers
    response.headers['Cache-Control'] = 'public, max-age=300'
    response.headers['ETag'] = generate_etag(@show)
    
    render json: { data: show_serializer(@show) }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Show not found' }, status: :not_found
  end

  private

  def set_pagination_params
    @page = (params[:page] || 1).to_i
    @per_page = [(params[:per_page] || 20).to_i, 100].min # Cap at 100 per page
  end

  def date_range
    date_from = params[:date_from] ? Date.parse(params[:date_from]) : Date.today
    date_to = params[:date_to] ? Date.parse(params[:date_to]) : (Date.today + 90.days)
    
    date_from..date_to
  rescue Date::Error
    # Default to next 90 days if invalid date format
    Date.today..(Date.today + 90.days)
  end

  def apply_filters(shows)
    shows = shows.joins(network: :country).where(countries: { code: params[:country] }) if params[:country].present?
    shows = shows.joins(:network).where(networks: { name: params[:distributor] }) if params[:distributor].present?
    shows = shows.where('shows.rating >= ?', params[:rating]) if params[:rating].present?
    shows = shows.joins(:genres).where(genres: { name: params[:genre] }) if params[:genre].present?
    
    shows
  end

  def generate_etag(data)
    # Generate deterministic ETag for caching
    Digest::MD5.hexdigest(data.to_json + params.to_json)
  end

  def show_serializer(show)
    {
      id: show.id,
      tvmaze_id: show.tvmaze_id,
      name: show.name,
      show_type: show.show_type,
      language: show.language,
      status: show.status,
      runtime: show.runtime,
      premiered: show.premiered,
      ended: show.ended,
      official_site: show.official_site,
      summary: show.summary,
      image_url: show.image_url,
      weight: show.weight,
      rating: show.rating,
      network: show.network ? {
        tvmaze_id: show.network.tvmaze_id,
        name: show.network.name,
        official_site: show.network.official_site,
        timezone: show.network.timezone,
        country: show.network.country ? {
          name: show.network.country.name,
          code: show.network.country.code,
          timezone: show.network.country.timezone
        } : nil
      } : nil,
      genres: show.genres.map { |genre| { name: genre.name } },
      episodes: show.episodes.map { |episode| {
        tvmaze_id: episode.tvmaze_id,
        name: episode.name,
        season: episode.season,
        number: episode.number,
        episode_type: episode.episode_type,
        airdate: episode.airdate,
        airtime: episode.airtime,
        airstamp: episode.airstamp,
        runtime: episode.runtime,
        summary: episode.summary,
        image_url: episode.image_url,
        rating: episode.rating
      }},
      created_at: show.created_at,
      updated_at: show.updated_at
    }
  end
end 