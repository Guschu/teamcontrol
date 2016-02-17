class EventsController < ApplicationController
  before_action :set_race

  def index
    page = (params[:page] || '1').to_i
    @events = @race.events.page(page)
  end

  def create
    attendance = @race.attendances.where(driver_id:event_params[:driver_id]).first
    @event = Event.new event_params.merge(team_id:attendance.team_id)

    respond_to do |format|
      if @event.save
        format.html { redirect_to [@race, :events], notice: 'Event wurde angelegt.' }
      else
        format.html { ap @event.errors; render :new }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_race
    @race = Race.friendly.find(params[:race_id])
  end

  def event_params
    params.require(:event).permit(:driver_id, :mode)
  end
end
