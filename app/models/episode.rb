class Episode < ApplicationRecord
  belongs_to :show
  
  validates :tvmaze_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :season, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  
  scope :upcoming, -> { where('airdate >= ?', Date.current) }
  scope :by_date_range, ->(from_date, to_date) { where(airdate: from_date..to_date) }
  scope :ordered_by_airdate, -> { order(:airdate, :airtime) }
  
  def full_episode_number
    "S#{season.to_s.rjust(2, '0')}E#{number.to_s.rjust(2, '0')}"
  end
end 