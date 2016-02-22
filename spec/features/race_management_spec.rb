require 'rails_helper'

RSpec.feature 'Widget management', type: :feature do
  scenario 'User creates a new race' do
    a = attributes_for :race
    visit new_race_path

    fill_in 'race_name', with: a[:name]
    click_button I18n.t(:create, scope: 'helpers.submit', model: Race.model_name.human)

    expect(page).to have_text I18n.t(:create, scope: 'messages.crud', model: Race.model_name.human)
  end

  scenario 'User edits a race' do
    race = create :race
    visit edit_race_path(race.slug)

    fill_in 'race_name', with: race.name + 'XXX'
    click_button I18n.t(:update, scope: 'helpers.submit', model: Race.model_name.human)

    expect(page).to have_text I18n.t(:update, scope: 'messages.crud', model: Race.model_name.human)
  end
end
