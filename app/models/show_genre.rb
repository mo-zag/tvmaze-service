class ShowGenre < ApplicationRecord
  belongs_to :show
  belongs_to :genre
  
  validates :show_id, uniqueness: { scope: :genre_id }
end 