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

class Station < ActiveRecord::Base
  validates :token, presence: true, format: { with: /\A\h+\z/, message: 'nur Hex' }, length: { is: 12 }, uniqueness: true
end
