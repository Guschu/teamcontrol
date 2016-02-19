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

  namespace :examples do
    desc 'Generate an active race'
    task :active do
      race = FactoryGirl.create :race, :started, name: 'race4hospiz 2016'
      teams = []
      16.times do
        teams << FactoryGirl.create(:team, race: race)
      end

      teams.each do |team|
        puts "Team #{team.name} angelegt"
        (2 + rand(2)).times do
          driver = FactoryGirl.create :driver
          team.attendances.create driver: driver, tag_id:('A'..'Z').to_a.sample(8)
          puts "  + Fahrer #{driver.name}"
        end

        attendances = team.attendances.to_a
        Timecop.travel race.started_at.to_time
        attendances.each_with_index do |att, idx|
          Timecop.travel(20.minutes + rand(180)-90) if idx > 0
          att.create_event
          if idx>0
            Timecop.travel(1.minutes + rand(60)-30)
            attendances[idx-1].create_event
          end
        end
        puts "Fahrerdaten erzeugt"
      end
    end
  end
end
