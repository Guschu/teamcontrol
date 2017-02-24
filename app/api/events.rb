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
      logger.error 'No current race'
      status 404
      present ApiResponse.error 'Kein aktives Rennen', "Verarbeitung nicht möglich"
      return
    end

    attendances = Attendance.where(team_id: race.teams.select(:id)).order(team_id: :asc, id: :asc)

    if a = attendances.where(tag_id: params[:id]).first
      evt = Event.create driver_id: a.driver_id, team_id: a.team_id
      if evt.errors.empty?
        status 200
        present ApiResponse.success 'Buchung angelegt', "#{a.driver.name} #{I18n.t evt.mode, scope: 'event.modes'}"
      else
        logger.info evt.errors.full_messages.to_sentence
        status 406
        present ApiResponse.error evt.errors.full_messages.to_sentence, "#{a.team.name} / #{a.driver.name}"
      end

    else
      if a = attendances.unassigned.first
        logger.info "Assigning tag_id to driver #{a.driver.name}"
        if a.update_attributes tag_id: params[:id]
          present ApiResponse.success 'Karte/Tag registriert', a.driver.name
        end
      else
        logger.warn "Can't assign attendance, no unassigned available"
        status 406
        present ApiResponse.error 'Keine ausstehende Registrierung', "Nicht möglich"
      end
    end
  end
end
