require 'rails_helper'

RSpec.describe Events, type: :request do
  let(:station) { Station.where(token:'0123456789AB').first_or_create }
  let(:headers) { {API::TOKEN_NAME=>station.token, 'Accept'=>'application/json'}}

  context 'for unregistered ids' do
    it 'assign the id when attendance is available' do
      race = create :race, state: :active
      team = create :team, race:race
      a = create :attendance, tag_id:nil, team:team

      post '/api/v1/event', { id:'000000000000' }, headers
      expect(response.status).to eq 201

      data = JSON.parse(response.body)
      expect(data.keys).to eq %w(status message)
      expect(data['status']).to eq 'success'

      a.reload
      expect(a.tag_id).to eq '000000000000'
    end

    it 'returns error if no attendance available' do
      race = create :race, state: :active
      team = create :team, race:race
      a = create :attendance, tag_id:'000000000000', team:team

      post '/api/v1/event', { id:'000000000001' }, headers
      expect(response.status).to eq 406

      data = JSON.parse(response.body)
      expect(data.keys).to eq %w(status message)
      expect(data['status']).to eq 'error'

      a.reload
      expect(a.tag_id).to eq '000000000000'
    end
  end

  # it "returns 200" do
  #   post '/api/v1/ping', nil, { API::TOKEN_NAME => station.token }
  #   expect(response.status).to eq 200
  # end
end
