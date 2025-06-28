FactoryBot.define do
  factory :show do
    sequence(:tvmaze_id) { |n| n }
    sequence(:name) { |n| "Show #{n}" }
    show_type { 'Drama' }
    language { 'English' }
    status { 'Running' }
    runtime { 60 }
    premiered { Date.current - 1.year }
    ended { nil }
    official_site { "https://show#{n}.com" }
    summary { "This is a test show summary." }
    image_url { "https://example.com/show#{n}.jpg" }
    weight { 80 }
    rating { 8.5 }
    association :network
    tvmaze_updated_at { Time.current.to_i }
  end
end
