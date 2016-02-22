# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  team_id    :integer
#  driver_id  :integer
#  mode       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_events_on_driver_id  (driver_id)
#  index_events_on_team_id    (team_id)
#
# Foreign Keys
#
#  fk_rails_74371719e9  (driver_id => drivers.id)
#  fk_rails_f62361cf64  (team_id => teams.id)
#

require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:race) { create :race, :started, :with_teams }

  describe 'GET index' do
    subject { get :index, race_id: race.slug }

    it 'assigns @events' do
      subject
      expect(assigns(:events)).to eq Kaminari.paginate_array(race.events).page(1)
    end

    it 'renders the index template' do
      expect(subject).to render_template 'index'
    end
  end
end
