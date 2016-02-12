require 'rails_helper'

RSpec.describe RacesHelper, type: :helper do
  describe '#current_race' do
    it 'returns Race.current_race if session unset' do
      session.delete :current_race
      race = create :race, :started
      expect(helper.current_race).to eq race
    end
  end
end
