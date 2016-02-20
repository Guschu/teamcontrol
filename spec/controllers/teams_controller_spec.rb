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

  describe 'GET index' do
    subject { get :index, race_id:race.slug }

    it 'assigns @teams' do
      subject
      expect(assigns(:teams)).to eq Kaminari.paginate_array(race.teams).page(1)
    end

    it_behaves_like 'a successful index request', 'team'
  end

  describe 'GET edit' do
    subject { get :edit, race_id:race.slug, id:team.id }

    it 'assigns @team' do
      subject
      expect(assigns(:team)).to eq team
    end

    it_behaves_like 'a successful edit request'
  end

  describe 'GET new' do
    subject { get :new, race_id:race.slug }

    it 'assigns @team' do
      subject
      new_team = assigns(:team)
      expect(new_team).to be_a Team
      expect(new_team).to be_new_record
    end

    it_behaves_like 'a successful new request'
  end

  describe 'POST create' do
    context 'with valid data' do
      subject { post :create, race_id:race.slug, team:attributes_for(:team) }

      it_behaves_like 'a successful create request'
    end

    context 'with invalid data' do
      subject { post :create, race_id:race.slug, foo:{ bar:'baz' } }

      it 'fails' do
        expect { subject }.to raise_error ActionController::ParameterMissing
      end
    end
  end

  describe 'GET :race_team_score' do
    let(:team) { create :team }

    it 'renders score template with valid team_token' do
      get :score, race_id: team.race.slug, team_token: team.team_token
      expect(response).to render_template 'score'
    end

    it 'redirects to root with invalid team_token' do
      get :score, race_id: team.race.slug, team_token: 'fjjif'
      expect(response).to redirect_to root_path
    end

    it 'redirects to root with invalid race' do
      get :score, race_id: 'zz', team_token: team.team_token
      expect(response).to redirect_to root_path
    end
  end
end
