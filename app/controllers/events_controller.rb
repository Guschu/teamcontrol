class EventsController < ApplicationController
  before_action :set_race

  def index
    @q = @race.events.includes(:driver, :team).ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    page = (params[:page] || '1').to_i
    @events = @q.result.page(page)
  end

  def create
    @event = if event_params[:driver_id].present?
      attendance = @race.attendances.where(driver_id:event_params[:driver_id]).first
      Event.new event_params.merge(team_id:attendance.team_id)
    else
      Event.new
    end

    respond_to do |format|
      if @event.save
        format.html { redirect_to [@race, :events], notice: I18n.t(:create, scope:'messages.crud', model:Event.model_name.human ) }
      else
        format.html { redirect_to [@race, :events], alert:'Event konnte nicht angelegt werden' }
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
