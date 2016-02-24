# == Schema Information
#
# Table name: teams
#
#  id                :integer          not null, primary key
#  race_id           :integer
#  name              :string(255)
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :integer
#  logo_updated_at   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  team_token        :string(255)
#  position          :integer
#  team_lead         :string(255)
#  attendances_count :integer
#
# Indexes
#
#  index_teams_on_race_id     (race_id)
#  index_teams_on_team_token  (team_token)
#
# Foreign Keys
#
#  fk_rails_4a0c7e1679  (race_id => races.id)
#

require 'rails_helper'

RSpec.describe TeamsController, type: :controller do
  let(:race) { create :race, :started, :with_teams }
  let(:team) { race.teams.first }

  login_user

  describe 'GET index' do
    subject { get :index, race_id: race.slug }

    it 'assigns @teams' do
      subject
      expect(assigns(:teams)).to eq Kaminari.paginate_array(race.teams).page(1)
    end

    it_behaves_like 'a successful index request', 'team'
  end

  describe 'GET show' do
    it 'redirects if id is invalid' do
      get :show, race_id: race.slug, id: 4711
      expect(response).to be_redirect
    end

    it 'redirects if team_token is invalid' do
      get :show, race_id: race.slug, id: 'ABCDEFGH'
      expect(response).to be_redirect
    end

    context 'with internal id' do
      subject { get :show, race_id: race.slug, id: team.id }

      it 'assigns @team' do
        subject
        expect(assigns(:team)).to eq team
      end

      it_behaves_like 'a successful show request'
    end

    context 'with external token' do
      subject { get :show, race_id: race.slug, id: team.team_token }

      it 'assigns @team' do
        subject
        expect(assigns(:team)).to eq team
      end

      it 'returns an successful status code' do
        expect(subject).to be_success
      end

      it 'renders the score template' do
        expect(subject).to render_template 'score'
      end
    end
  end

  describe 'GET edit' do
    subject { get :edit, race_id: race.slug, id: team.id }

    it 'assigns @team' do
      subject
      expect(assigns(:team)).to eq team
    end

    it_behaves_like 'a successful edit request'
  end

  describe 'GET new' do
    subject { get :new, race_id: race.slug }

    it 'assigns @team' do
      subject
      new_team = assigns(:team)
      expect(new_team).to be_a Team
      expect(new_team).to be_new_record
    end

    it_behaves_like 'a successful new request'
  end

  describe 'POST import' do
    it 'accepts CSV data' do
      race = create :race
      post :import, race_id: race.slug, import_file: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/import.csv'), 'text/csv')
      expect(controller).to set_flash[:notice]
      expect(response).to be_redirect
      expect(race.teams.count).to be 3

      team1 = race.teams.first
      expect(team1.name).to eq 'Team A'
      expect(team1.team_lead).to eq 'Team Lead 1'
      expect(team1.drivers.count).to be 6
      expect(team1.drivers.first.name).to eq 'Driver 1'

      team2 = race.teams.second
      expect(team2.name).to eq 'Team B'
      expect(team2.team_lead).to eq 'Team Lead 2'
      expect(team2.drivers.count).to be 0

      team3 = race.teams.third
      expect(team3.name).to eq 'Team C'
      expect(team3.team_lead).to eq 'Team Lead 3'
      expect(team3.drivers.count).to be 1
      expect(team3.drivers.first.name).to eq 'Driver 7'
    end

    it 'sets error flash if no file uploaded' do
      race = create :race
      post :import, race_id: race.slug, import_file: nil
      expect(response).to be_redirect
      expect(controller).to set_flash[:error]
    end
  end

  describe 'POST create' do
    context 'with valid data' do
      subject { post :create, race_id: race.slug, team: attributes_for(:team).merge(batch_create_drivers:"Herr David\r\nHerr Christian") }
      
      it_behaves_like 'a successful create request'

      it 'created two drivers' do
        expect{ subject }.to change{ Driver.count }.by(2)
      end
    end

    context 'with invalid data' do
      subject { post :create, race_id: race.slug, foo: { bar: 'baz' } }

      it 'fails' do
        expect { subject }.to raise_error ActionController::ParameterMissing
      end
    end

    context 'with invalid batch data' do
      subject { post :create, race_id: race.slug, team: attributes_for(:team).merge(batch_create_drivers:"\r\n\r\nHerr David\r\nHerr Christian\r\n\r\nDummy User\r\n\r\n") }

      it_behaves_like 'a successful create request'

      it 'creates three drivers' do
        expect { subject }.to change{ Driver.count }.by(3)
      end
    end
  end
end
