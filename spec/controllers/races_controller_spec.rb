require 'rails_helper'

RSpec.describe RacesController, type: :controller do
  describe 'GET index' do
    it 'assigns @races' do
      race = create :race
      get :index
      expect(assigns(:races)).to eq Kaminari.paginate_array([race]).page(1)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template 'index'
    end
  end

  describe 'GET current' do
    it 'redirects to current race' do
      create :race, state: :active
      get :current
      expect(response).to redirect_to race_path(Race.current_race)
    end
  end

  describe 'GET show' do
    let(:race) { create :race }
    subject { get :show, id: race.slug }

    it 'assigns @race' do
      subject
      expect(assigns(:race)).to eq race
    end

    it 'renders the show template' do
      expect(subject).to render_template 'show'
    end
  end
end
