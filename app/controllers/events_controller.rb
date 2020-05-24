class Adjust
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :new_timestamp

  def persisted?
    false
  end
end

class EventsController < ApplicationController
  before_action :set_race

  def index
    @q = @race.events.includes(:driver, :team, :penalty).ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    page = (params[:page] || '1').to_i
    @events = @q.result.page(page)
  end

  def create
    attendance = @race.attendances.where(driver_id: event_params[:driver_id]).first
    @event = Event.new event_params.merge(team_id:attendance.team_id)

    respond_to do |format|
      if @event.save
        format.html { redirect_to [@race, :events], notice: I18n.t(:create, scope: 'messages.crud', model: Event.model_name.human) }
      else
        format.html { redirect_to [@race, :events], alert: 'Event konnte nicht angelegt werden: ' << @event.errors.full_messages.to_sentence }
      end
    end
  end

  def details
    @event = @race.events.find(params[:id])
    @adjust = Adjust.new.tap do |a|
      a.new_timestamp = @event.created_at
    end
  end

  def adjust
    @event = @race.events.find(params[:id])
    new_time = params_to_date(adjust_params, :new_timestamp)
    if new_time<@event.created_at
      if @event.reduce_by(@event.created_at - new_time)
        flash[:notice] = 'Event wurde korrigiert'
      else
        flash[:error] = 'Korrektur nicht erfolgreich'
      end
    else
      flash[:notice] = 'Keine kleinere Korrekturzeit angegeben'
    end
    redirect_to details_race_event_path(@race, @event)
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    if @event.present?
      @event.destroy
    end
    respond_to do |format|
      format.html { redirect_to race_events_url(@race), notice: I18n.t(:destroy, scope: 'messages.crud', model: Event.model_name.human) }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_race
    @race = Race.friendly.find(params[:race_id])
  end

  def adjust_params
    params.require(:adjust).permit(:new_timestamp)
  end

  def event_params
    params.require(:event).permit(:driver_id, :mode)
  end

  def params_to_date(params, key)
    date_parts = params.select{ |k,v| k.to_s =~ /\A#{key}\([1-6]{1}i\)/ }.values.map(&:to_i)
    Time.zone.local *date_parts
  end
end
