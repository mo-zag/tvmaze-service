class Country < ApplicationRecord
    has_many :networks, dependent: :restrict_with_error

    validates :name, presence: true, uniqueness: true
    validates :code, presence: true, uniqueness: true, length: { is: 2 }

    scope :ordered, -> { order(:name) }
end
