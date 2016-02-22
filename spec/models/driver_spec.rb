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

  describe 'create a new Driver' do
    it 'without name should fail' do
      expect { create :driver, name:"" }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe 'edit a Driver' do
    it 'remove name should fail' do
      driver = create :driver, name:'Dagobert Duck'
      driver.name = ''
      expect(driver).not_to be_valid
    end
  end
end
