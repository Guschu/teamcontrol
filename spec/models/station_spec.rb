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

  it 'convert token to upper case and remove empty spaces' do
    station = create :station, token: '1a a2 2b 3f ff 0c'
    expect(station).to be_valid
    expect(station.token).to eq('1AA22B3FFF0C')
  end

  it 'only accepts token with hex values' do
    expect { create :station, token: '1a g2 2b 3f ff 0c' }.to raise_error ActiveRecord::RecordInvalid
  end
end
