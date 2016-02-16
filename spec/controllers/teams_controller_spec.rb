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
end
