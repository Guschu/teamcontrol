namespace :db do
  desc 'Generate random example data for local development'
  task :examples do
    race = FactoryGirl.create :race, name: 'race4hospiz 2016'
    38.times do
      team = FactoryGirl.create :team, race: race
      (5 + rand(3)).times do
        driver = FactoryGirl.create :driver
        team.attendances.create driver: driver
      end
    end
  end
end
