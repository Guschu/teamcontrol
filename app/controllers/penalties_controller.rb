class PenaltiesController < ApplicationController
  before_action :set_race

  def index
    @q = @race.penalties.includes(:driver, :team).ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    page = (params[:page] || '1').to_i
    @penalties = @q.result.page(page)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_race
    @race = Race.friendly.find(params[:race_id])
  end
end
