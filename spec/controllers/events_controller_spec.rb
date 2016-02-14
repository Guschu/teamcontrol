require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:race) { create :race, :started, :with_teams }

  describe 'GET index' do
    subject { get :index, race_id:race.slug }

    it 'assigns @events' do
      subject
      expect(assigns(:events)).to eq Kaminari.paginate_array(race.events).page(1)
    end

    it 'renders the index template' do
      expect(subject).to render_template 'index'
    end
  end
end
