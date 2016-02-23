require 'rails_helper'

RSpec.describe Penalty, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:team).class_name('Team') }
    it { is_expected.to belong_to(:driver).class_name('Driver') }
  end
end
