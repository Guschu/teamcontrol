require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#time_format' do
    it 'formats time as a string' do
      t = Time.now.change(hour: 10, min: 47, sec: 51)
      expect(helper.time_format(t)).to eq '10:47:51'
    end

    it 'returns nil if time is nil' do
      expect(helper.time_format(nil)).to be_nil
    end
  end

  describe '#seconds_format' do
    it 'formats seconds as a string' do
      expect(helper.seconds_format(17)).to eq '00:00:17'
      expect(helper.seconds_format(67)).to eq '00:01:07'
      expect(helper.seconds_format(23 * 60 * 60 + 17 * 60 + 23)).to eq '23:17:23'
    end

    it 'returns nil if seconds is nil' do
      expect(helper.seconds_format(nil)).to be_nil
    end
  end

  describe '#destroy_link_to' do
    it 'generates a link' do
      driver = create :driver
      url = driver_url(driver)
      expect(helper.destroy_link_to(url)).to match(/data-method="delete"/)
      expect(helper.destroy_link_to(url)).to match(/data-confirm="*"/)
    end
  end
end
