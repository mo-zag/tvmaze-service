class Show < ApplicationRecord
  belongs_to :network, optional: true
  has_many :episodes, dependent: :destroy
  has_many :show_genres, dependent: :destroy
  has_many :genres, through: :show_genres
  
  validates :tvmaze_id, presence: true, uniqueness: true
  validates :name, presence: true
  
  scope :active, -> { where(status: 'Running') }
  scope :by_genre, ->(genre_name) { joins(:genres).where(genres: { name: genre_name }) }
  scope :by_network, ->(network_name) { joins(:network).where(networks: { name: network_name }) }
  scope :by_country, ->(country_code) { joins(network: :country).where(countries: { code: country_code }) }
  
  def rating_average
    rating&.to_f
  end
end 