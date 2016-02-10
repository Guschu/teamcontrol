class Events < Grape::API
  include Defaults
  include Authentication

  version 'v1', using: :path

  before do
    authenticate!
  end

  desc 'Create a race event for a given token.'
  params do
    requires :id, type:String, desc:'Tag ID, case insensitive'
  end
  post :event do
    race = Race.current_race
    error!('No active race') unless race

    result = {}
    attendances = Attendance.where(team_id:race.teams.select(:id))
    if a = attendances.where(tag_id:params[:id]).first
      logger.info "Creating event for driver #{a.driver.name}"
    else
      if a = attendances.unassigned.first
        logger.info "Assigning tag_id to driver #{a.driver.name}"
        if a.update_attributes tag_id:params[:id]
          result = { status:'success', message:"Fahrer #{a.driver.name} aktiviert" }
        end
      else
        status 406
        result = { status:'error', message:"Keine Aktivierung möglich" }
      end
    end

    present result
  end
end
