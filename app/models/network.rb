class Network < ApplicationRecord
  # su=ometime they do not have country as its a youtube show and country is null.
  belongs_to :country, optional: true
  has_many :shows, dependent: :restrict_with_error
  
  validates :tvmaze_id, presence: true, uniqueness: true
  validates :name, presence: true
  
  scope :ordered, -> { order(:name) }
end 