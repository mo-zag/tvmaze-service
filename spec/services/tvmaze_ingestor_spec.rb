require 'rails_helper'
require 'webmock/rspec'

RSpec.describe TvmazeIngestor do
  let(:date) { '2025-08-27' }
  let(:api_url) { "#{TvmazeIngestor::API_URL}?date=#{date}" }

  let(:api_response) do
    [
      {
        "id" => 123456,
        "name" => "Episode Title",
        "season" => 1,
        "number" => 1,
        "type" => "regular",
        "airdate" => "2025-08-27",
        "airtime" => "20:00",
        "airstamp" => "2025-08-27T20:00:00+00:00",
        "runtime" => 60,
        "rating" => { "average" => 8.2 },
        "summary" => "<p>Episode summary</p>",
        "image" => { "original" => "https://example.com/episode.jpg" },
        "_embedded" => {
          "show" => {
            "id" => 999,
            "name" => "Test Show",
            "type" => "Drama",
            "language" => "English",
            "status" => "Running",
            "runtime" => 60,
            "premiered" => "2020-01-01",
            "ended" => nil,
            "officialSite" => "https://example.com/show",
            "summary" => "<p>Show summary</p>",
            "image" => { "original" => "https://example.com/show.jpg" },
            "weight" => 80,
            "rating" => { "average" => 9.1 },
            "updated" => 1717171717,
            "network" => {
              "id" => 42,
              "name" => "Test Network",
              "officialSite" => "https://network.example.com",
              "timezone" => "UTC",
              "country" => {
                "name" => "Testland",
                "code" => "TL",
                "timezone" => "UTC"
              }
            },
            "genres" => [ "Sci-Fi", "Thriller" ]
          }
        }
      }
    ].to_json
  end

  before do
    stub_request(:get, api_url)
      .to_return(status: 200, body: api_response, headers: { 'Content-Type' => 'application/json' })
  end

  describe '.run' do
    it 'creates country, network, show, genres, show_genres, and episode' do
      expect {
        described_class.run(date: date)
      }.to change(Country, :count).by(1)
       .and change(Show, :count).by(1)
       .and change(ShowGenre, :count).by(2)
       .and change(Episode, :count).by(1)

      country = Country.last
      network = Network.last
      show = Show.last
      episode = Episode.last

      expect(country.name).to eq("Testland")
      expect(show.name).to eq("Test Show")
      expect(show.show_type).to eq("Drama")
      expect(episode.name).to eq("Episode Title")
      expect(episode.rating).to eq(8.2)
    end
  end
end
