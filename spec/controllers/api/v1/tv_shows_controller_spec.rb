require 'rails_helper'

RSpec.describe Api::V1::TvShowsController, type: :controller do
  let(:country) { Country.find_or_create_by(code: 'US') { |c| c.name = 'United States'; c.timezone = 'UTC' } }
  let(:network) { Network.find_or_create_by(tvmaze_id: 999999) { |n| n.name = 'Test Network'; n.country = country; n.official_site = 'https://test.com'; n.timezone = 'UTC' } }
  let(:show) { Show.find_or_create_by(tvmaze_id: 999999) { |s| s.name = 'Test Show'; s.network = network; s.show_type = 'Drama'; s.language = 'English'; s.status = 'Running'; s.runtime = 60; s.rating = 8.5 } }
  let(:episode) { Episode.find_or_create_by(tvmaze_id: 999999) { |e| e.show = show; e.name = 'Test Episode'; e.season = 1; e.number = 1; e.airdate = Date.today } }

  before do
    # Ensure all test data is created
    country
    network
    show
    episode
    # Set authentication credentials
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'password123')
  end

  describe 'GET #index' do
    it 'returns a list of TV shows' do
      get :index
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
      expect(json_response['meta']).to include('page', 'per_page', 'total_count', 'total_pages')
    end

    it 'filters by date range' do
      get :index, params: { date_from: Date.today.to_s, date_to: (Date.today + 7.days).to_s }
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to be > 0
    end

    it 'filters by country' do
      get :index, params: { country: 'US' }
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to be > 0
    end

    it 'filters by distributor' do
      # Ensure test data exists before filtering
      expect(network.name).to eq('Test Network')
      expect(show.network.name).to eq('Test Network')

      get :index, params: { distributor: 'Test Network' }
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to be > 0
    end

    it 'filters by rating' do
      show.update(rating: 8.5)
      get :index, params: { rating: 8.0 }
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to be > 0
    end

    it 'handles pagination' do
      get :index, params: { page: 1, per_page: 5 }
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['meta']['page']).to eq(1)
      expect(json_response['meta']['per_page']).to eq(5)
    end
  end

  describe 'GET #show' do
    it 'returns a specific TV show' do
      get :show, params: { id: show.id }
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['data']['name']).to eq('Test Show')
      expect(json_response['data']['network']['name']).to eq('Test Network')
    end

    it 'returns 404 for non-existent show' do
      get :show, params: { id: 99999 }
      expect(response).to have_http_status(:not_found)
    end
  end
end
