require 'rails_helper'

RSpec.describe Events, type: :request do
  let(:station) { Station.where(token: '0123456789AB').first_or_create }
  let(:headers) { { API::TOKEN_NAME => station.token, 'Accept' => 'application/json' } }
  let(:allowed_response_keys) { %w(status title message) }

  context 'without a current race' do
    it 'fails with 404' do
      post '/api/v1/event', { id: 'foobar' }, headers
      expect(response.status).to eq 404

      data = JSON.parse(response.body)
      expect(data.keys).to eq allowed_response_keys
      expect(data['status']).to eq 'error'
      expect(data['title']).not_to be_blank
      expect(data['message']).not_to be_blank
    end
  end

  context 'for unregistered ids' do
    it 'assign the id when attendance is available' do
      race = create :race, state: :active
      team = create :team, race: race
      a = create :attendance, tag_id: nil, team: team

      post '/api/v1/event', { id: '000000000000' }, headers
      expect(response.status).to eq 201

      data = JSON.parse(response.body)
      expect(data.keys).to eq allowed_response_keys
      expect(data['status']).to eq 'success'
      expect(data['title']).not_to be_blank
      expect(data['message']).not_to be_blank

      a.reload
      expect(a.tag_id).to eq '000000000000'
    end

    it 'returns error if no attendance available' do
      race = create :race, state: :active
      team = create :team, race: race
      a = create :attendance, tag_id: '000000000000', team: team

      post '/api/v1/event', { id: '000000000001' }, headers
      expect(response.status).to eq 406

      data = JSON.parse(response.body)
      expect(data.keys).to eq allowed_response_keys
      expect(data['status']).to eq 'error'
      expect(data['title']).not_to be_blank
      expect(data['message']).not_to be_blank

      a.reload
      expect(a.tag_id).to eq '000000000000'
    end
  end

  context 'for registered ids' do
    context 'before race is started' do
      let(:team) { create :team, race: @race }
      let(:attendance) { create :attendance, tag_id: '000000000000', team: team }

      it 'creates event data if race mode is :both' do
        @race = create :race, mode: :both, prebooking_open: true
        post '/api/v1/event', { id: attendance.tag_id }, headers
        expect(response).to be_success

        data = JSON.parse(response.body)
        expect(data.keys).to eq allowed_response_keys
        expect(data['status']).to eq 'success'
        expect(data['title']).not_to be_blank
        expect(data['message']).not_to be_blank

        expect(team.events.count).to eq 1

        # wir schicken einen zweiten Event, der aber nicht zu einer zweiten Buchung führen darf
        Timecop.travel 5.seconds

        post '/api/v1/event', { id: attendance.tag_id }, headers
        expect(response.status).to eq 406

        data = JSON.parse(response.body)
        expect(data.keys).to eq allowed_response_keys
        expect(data['status']).to eq 'error'
        expect(data['title']).not_to be_blank
        expect(data['message']).not_to be_blank

        expect(team.events.count).to eq 1
      end

      it 'denies events if race mode is :both and booking is not allowed' do
        @race = create :race, mode: :both
        post '/api/v1/event', { id: attendance.tag_id }, headers
        expect(response).to_not be_success

        data = JSON.parse(response.body)
        expect(data.keys).to eq allowed_response_keys
        expect(data['status']).to eq 'error'
        expect(data['title']).not_to be_blank
        expect(data['message']).not_to be_blank
        expect(data['title']).to eq 'Das Rennen erlaubt noch keine Buchungen'
        expect(team.events.count).to eq 0
      end

      it 'denies events if race mode is :leaving' do
        @race = create :race, mode: :leaving
        post '/api/v1/event', { id: attendance.tag_id }, headers
        expect(response.status).to eq 406

        data = JSON.parse(response.body)
        expect(data.keys).to eq allowed_response_keys
        expect(data['status']).to eq 'error'
        expect(data['title']).not_to be_blank
        expect(data['message']).not_to be_blank
      end
    end

    context 'while race is active' do
      let(:race) { create :race, :started }
      let(:team) { create :team, race: race }
      let(:attendance) { create :attendance, tag_id: '000000000000', team: team }

      it 'creates event data' do
        post '/api/v1/event', { id: attendance.tag_id }, headers
        expect(response).to be_success
        data = JSON.parse(response.body)
        expect(data.keys).to eq allowed_response_keys
        expect(data['status']).to eq 'success'
        expect(data['title']).not_to be_blank
        expect(data['message']).not_to be_blank

        expect(team.events.count).to eq 1
        expect(team.to_stats.current_driver).to eq attendance.driver
      end
    end

    context 'after race is finished' do
      let(:race) { create :race, :finished }
      let(:team) { create :team, race: race }
      let(:attendance) { create :attendance, tag_id: '000000000000', team: team }

      it 'denies events' do
        post '/api/v1/event', { id: attendance.tag_id }, headers
        expect(response.status).to eq 404 # no current race

        data = JSON.parse(response.body)
        expect(data.keys).to eq allowed_response_keys
        expect(data['status']).to eq 'error'
        expect(data['title']).not_to be_blank
        expect(data['message']).not_to be_blank
      end
    end
  end
end
