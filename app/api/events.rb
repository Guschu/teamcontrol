class Events < Grape::API
  include Defaults
  include Authentication

  version 'v1', using: :path

  before do
    authenticate!
  end

  desc 'Create a race event for a given token.'
  params do
    requires :id, type: String, desc: 'Tag ID, case insensitive'
  end
  post :event do
    race = Race.current_race
    unless race
      status 404
      present ApiResponse.error "Kein aktuelles Rennen vorhanden!"
    end

    attendances = Attendance.where(team_id: race.teams.select(:id))
    if a = attendances.where(tag_id: params[:id]).first
      logger.info "Creating event for driver #{a.driver.name}"
      evt = a.create_event
      present ApiResponse.success "Fahrer #{a.driver.name} #{evt}"
    else
      if a = attendances.unassigned.first
        logger.info "Assigning tag_id to driver #{a.driver.name}"
        if a.update_attributes tag_id: params[:id]
          present ApiResponse.success "Fahrer #{a.driver.name} aktiviert"
        end
      else
        status 406
        present ApiResponse.error "Keine Aktivierung möglich"
      end
    end
  end
end
