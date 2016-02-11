require 'rails_helper'

RSpec.describe API, type: :request do
  context 'without authentication' do
    it 'returns 401' do
      get '/api/v1/ping'
      expect(response.status).to eq 401
    end
  end

  context 'with authentication' do
    let(:station) { Station.where(token: '0123456789AB').first_or_create }

    it 'returns 200' do
      get '/api/v1/ping', nil, API::TOKEN_NAME => station.token
      expect(response.status).to eq 200
    end
  end
end
