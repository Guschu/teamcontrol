class Events < Grape::API
  include Defaults
  include Authentication

  version 'v1', using: :path

  before do
    authenticate!
  end

  desc 'Create a race event for a given token.' do
    success ApiResponse::Entity
    failure [
      [401, 'Unauthorized'],
      [404, 'No current race', ApiResponse::Entity],
      [406, 'No activation', ApiResponse::Entity]
    ]
  end
  params do
    requires :id, type: String, desc: 'Tag ID, case insensitive'
  end
  post :event do
    race = Race.current_race
    unless race.present?
      logger.error "No current race"
      status 404
      present ApiResponse.error "Kein aktives Rennen vorhanden!"
      return
    end

    attendances = Attendance.where(team_id: race.teams.select(:id))
    if a = attendances.where(tag_id: params[:id]).first
      case race.aasm.current_state
      when :planned
        if race.both?
          existing_events = race.events.where(team_id:a.team_id)
          if existing_events.size == 0
            logger.info "Creating event for driver #{a.driver.name}"
            evt = a.create_event
            present ApiResponse.success "#{a.driver.name} #{I18n.t evt.mode, scope:'event.modes'}"
          else
            logger.warn "Pre-race event for #{a.team.name} already exists"
            status 406
            present ApiResponse.error "#{a.team.name} ist bereits gebucht"
          end
        else
          logger.warn "Race mode :leaving does not allow events before race is started"
          status 406
          present ApiResponse.error "Nicht möglich"
        end
      when :active
        logger.info "Creating event for driver #{a.driver.name}"
        evt = a.create_event
        present ApiResponse.success "#{a.driver.name} #{I18n.t evt.mode, scope:'event.modes'}"
      when :finished
        logger.warn "Can't create event, race is finished"
        status 406
        present ApiResponse.error "Rennen ist bereits beendet"
      else
        logger.error "Unexpected race state #{race.state}"
        status 500
        present ApiResponse.error "Unexpected race state #{race.state}"
      end
    else
      if a = attendances.unassigned.first
        logger.info "Assigning tag_id to driver #{a.driver.name}"
        if a.update_attributes tag_id: params[:id]
          present ApiResponse.success "#{a.driver.name} registriert"
        end
      else
        logger.warn "Can't assign attendance, no unassigned available"
        status 406
        present ApiResponse.error "Keine Aktivierung möglich"
      end
    end
  end
end
