# == Schema Information
#
# Table name: drivers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Driver, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:attendances).class_name('Attendance') }
  end
end
