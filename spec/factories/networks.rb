FactoryBot.define do
  factory :network do
    sequence(:tvmaze_id) { |n| n }
    sequence(:name) { |n| "Network #{n}" }
    official_site { "https://network#{n}.com" }
    timezone { 'UTC' }
    association :country
  end
end
