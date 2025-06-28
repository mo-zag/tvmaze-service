class Genre < ApplicationRecord
  has_many :show_genres, dependent: :destroy
  has_many :shows, through: :show_genres
  
  validates :name, presence: true, uniqueness: true
  
  scope :ordered, -> { order(:name) }
end 