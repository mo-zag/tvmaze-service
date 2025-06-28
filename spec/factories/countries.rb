FactoryBot.define do
  factory :country do
    sequence(:name) { |n| "Country #{n}" }
    sequence(:code) { |n| "C#{n.to_s.rjust(2, '0')}" }
    timezone { 'UTC' }
  end
end
