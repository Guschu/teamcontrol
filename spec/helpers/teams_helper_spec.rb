require 'rails_helper'

RSpec.describe TeamsHelper, type: :helper do
  describe '#external_link_to' do
    it 'returns correct Link with team token' do
      team = create :team
      expect(helper.external_link_to(team)).to match team.team_token
    end
  end
end
