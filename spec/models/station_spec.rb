# == Schema Information
#
# Table name: stations
#
#  id         :integer          not null, primary key
#  token      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_stations_on_token  (token)
#

require 'rails_helper'

RSpec.describe Station, type: :model do
  it 'validates token' do
    station = create :station
    expect(station).to be_valid

    station.token = ''
    expect(station).not_to be_valid
    expect(station.errors[:token]).to eq [
      'muss ausgefüllt werden',
      'nur Hex',
      'hat die falsche Länge (muss genau 12 Zeichen haben)'
    ]
  end
end
