# == Schema Information
#
# Table name: races
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  duration       :integer
#  max_drive      :integer
#  max_turn       :integer
#  break_time     :integer
#  waiting_period :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  slug           :string(255)
#  state          :integer          default(0)
#  mode           :integer          default(0)
#  scheduled      :date
#  started_at     :datetime
#  finished_at    :datetime
#
# Indexes
#
#  index_races_on_mode  (mode)
#  index_races_on_slug  (slug)
#

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
      race = create :race, :started
      get :current
      expect(response).to redirect_to race_path(race)
    end

    it 'redirects to index if no active nor planned race' do
      race = create :race, :finished
      get :current
      expect(response).to redirect_to races_path

      race = create :race, scheduled:7.days.ago
      expect(response).to redirect_to races_path
    end
  end

  describe 'GET show' do
    let(:race) { create :race }

    it 'redirects to settings' do
      get :show, id: race.slug
      expect(response).to redirect_to settings_race_path(Race.current_race)
    end
  end

  describe 'GET overview' do
    let(:race) { create :race }

    it 'renders the overview template' do
      get :overview, id: race.slug
      expect(response).to render_template 'overview'
    end

    it 'assigns @race' do
      get :overview, id: race.slug
      expect(assigns(:race)).to eq race
    end
  end

  describe 'GET settings' do
    let(:race) { create :race }

    it 'renders the settings template' do
      get :settings, id: race.slug
      expect(response).to render_template 'settings'
    end

    it 'assigns @race' do
      get :settings, id: race.slug
      expect(assigns(:race)).to eq race
    end
  end
end
