require 'rails_helper'

RSpec.describe RacesHelper, type: :helper do
  describe '#current_race' do
    it 'returns Race.current_race if session unset' do
      session.delete :current_race
      race = create :race, :started
      expect(helper.current_race).to eq race
    end

    it 'handles invalid session content' do
      session[:current_race] = 'foobar'
      race = create :race, :started
      expect(helper.current_race).to eq race
    end
  end

  describe '#minutes_to_time' do
    it 'returns a string w/ hours and minutes' do
      expect(helper.minutes_to_time(835)).to eq '13 Stunden 55 Minuten'
      expect(helper.minutes_to_time(130)).to eq '02 Stunden 10 Minuten'
    end

    it 'returns a string w/ minutes if hours is 0' do
      expect(helper.minutes_to_time(12)).to eq '12 Minuten'
    end
  end
end
