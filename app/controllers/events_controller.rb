class EventsController < ApplicationController
  before_action :set_race

  def index
    page = (params[:page] || '1').to_i
    @events = @race.events.page(page)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_race
    @race = Race.friendly.find(params[:race_id])
  end
end
