require 'rails_helper'

RSpec.describe TeamsController, type: :controller do
  let(:race) { create :race, :started, :with_teams }

  describe 'GET index' do
    subject { get :index, race_id:race.slug }

    it 'assigns @teams' do
      subject
      expect(assigns(:teams)).to eq Kaminari.paginate_array(race.teams).page(1)
    end

    it 'renders the index template' do
      expect(subject).to render_template 'index'
    end
  end
end
