FactoryBot.define do
  factory :episode do
    sequence(:tvmaze_id) { |n| n }
    association :show
    sequence(:name) { |n| "Episode #{n}" }
    season { 1 }
    sequence(:number) { |n| n }
    episode_type { 'regular' }
    airdate { Date.current }
    airtime { '20:00' }
    airstamp { Time.current }
    runtime { 60 }
    summary { "This is a test episode summary." }
    image_url { "https://example.com/episode#{n}.jpg" }
    rating { 8.0 }
  end
end
