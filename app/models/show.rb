class Show < ApplicationRecord
  belongs_to :network, optional: true
  has_many :episodes, dependent: :destroy
  has_many :show_genres, dependent: :destroy
  has_many :genres, through: :show_genres

  validates :tvmaze_id, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { where(status: "Running") }
  scope :by_genre, ->(genre_name) { joins(:genres).where(genres: { name: genre_name }) }
  scope :by_network, ->(network_name) { joins(:network).where(networks: { name: network_name }) }
  scope :by_country, ->(country_code) { joins(network: :country).where(countries: { code: country_code }) }

  def rating_average
    rating&.to_f
  end

  # Analytical Query 1: Shows with their episode counts and average ratings using CTE
  def self.shows_with_episode_stats
    with(episode_stats: Show.joins(:episodes)
                           .select("shows.id, COUNT(episodes.id) as episode_count, AVG(episodes.rating) as avg_episode_rating")
                           .group("shows.id"))
      .joins("JOIN episode_stats ON shows.id = episode_stats.id")
      .select("shows.*, episode_stats.episode_count, episode_stats.avg_episode_rating")
  end

  # Analytical Query 2: Top rated shows by genre using window functions
  def self.top_rated_by_genre(limit: 5)
    ranked_shows = joins(:genres)
                   .select("shows.*, genres.name as genre_name, ROW_NUMBER() OVER (PARTITION BY genres.name ORDER BY shows.rating DESC) as rank_in_genre")
                   .where("shows.rating IS NOT NULL")

    # Use a subquery to filter by rank
    Show.from("(#{ranked_shows.to_sql}) as shows")
        .where("rank_in_genre <= ?", limit)
  end

  # Analytical Query 3: Network performance analysis with aggregates
  def self.network_performance_analysis
    joins(:network)
      .select('networks.name as network_name,
               COUNT(shows.id) as total_shows,
               AVG(shows.rating) as avg_show_rating,
               COUNT(CASE WHEN shows.status = \'Running\' THEN 1 END) as active_shows,
               COUNT(CASE WHEN shows.status = \'Ended\' THEN 1 END) as ended_shows')
      .group("networks.id, networks.name")
      .order("avg_show_rating DESC NULLS LAST")
  end

  # Analytical Query 4: Monthly episode release trends
  def self.monthly_episode_trends(year: Date.current.year)
    joins(:episodes)
      .where("EXTRACT(YEAR FROM episodes.airdate) = ?", year)
      .select('EXTRACT(MONTH FROM episodes.airdate) as month,
               COUNT(episodes.id) as episode_count,
               COUNT(DISTINCT shows.id) as unique_shows')
      .group("EXTRACT(MONTH FROM episodes.airdate)")
      .order("month")
  end

  # Analytical Query 5: Country distribution with percentage
  def self.country_distribution
    joins(network: :country)
      .select('countries.name as country_name,
               COUNT(shows.id) as show_count,
               ROUND(COUNT(shows.id) * 100.0 / (SELECT COUNT(*) FROM shows), 2) as percentage')
      .group("countries.id, countries.name")
      .order("show_count DESC")
  end
end
