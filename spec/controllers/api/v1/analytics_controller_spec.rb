require 'rails_helper'

RSpec.describe Api::V1::AnalyticsController, type: :controller do
  before do
    # Set authentication credentials
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'password123')
  end

  describe 'GET #shows_with_episode_stats' do
    it 'returns shows with episode statistics' do
      get :shows_with_episode_stats
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end
  end

  describe 'GET #top_rated_by_genre' do
    it 'returns top rated shows by genre' do
      get :top_rated_by_genre
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end

    it 'accepts limit parameter' do
      get :top_rated_by_genre, params: { limit: 3 }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #network_performance' do
    it 'returns network performance analysis' do
      get :network_performance
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end
  end

  describe 'GET #monthly_trends' do
    it 'returns monthly episode trends' do
      get :monthly_trends
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end

    it 'accepts year parameter' do
      get :monthly_trends, params: { year: 2023 }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #country_distribution' do
    it 'returns country distribution' do
      get :country_distribution
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
    end
  end
end
