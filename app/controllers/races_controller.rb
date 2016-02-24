# == Schema Information
#
# Table name: races
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  duration       :integer
#  max_drive      :integer
#  max_turn       :integer
#  break_time     :integer
#  waiting_period :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  slug           :string(255)
#  state          :integer
#  mode           :integer
#  scheduled      :date
#  started_at     :datetime
#  finished_at    :datetime
#
# Indexes
#
#  index_races_on_mode  (mode)
#  index_races_on_slug  (slug)
#

class RacesController < ApplicationController
  include RacesHelper
  before_action :set_race, except: [:index, :current, :new, :create]
  skip_before_filter :authenticate_user!, only:[:current, :public_overview]

  # GET /races
  # GET /races.json
  def index
    @q = Race.ransack(params[:q])
    @q.sorts = 'state asc' if @q.sorts.empty?
    page = (params[:page] || '1').to_i
    @races = @q.result.page(page)
  end

  def current
    if c = current_race
      redirect_to c
      return
    end
    redirect_to races_path
  end

  # POST /races/1/start
  def start
    flash[:notice] = 'Das Rennen wurde gestartet' if @race.start && @race.save
    redirect_to settings_race_path(@race)
  end

  # POST /races/1/finish
  def finish
    flash[:notice] = 'Das Rennen wurde beendet' if @race.finish && @race.save
    redirect_to settings_race_path(@race)
  end

  # GET /races/1
  # GET /races/1.json
  def show
    session[:current_race] = @race.id
    redirect_to settings_race_path(@race)
  end

  # GET /races/1/overview
  def overview
  end

  # GET /races/1/public_overview
  def public_overview
    render layout:'public'
  end

  # GET /races/1/settings
  def settings
  end

  # GET /races/new
  def new
    @race = Race.new mode: :both, duration: 540, max_drive: 170, min_turn: 20, max_turn: 40, break_time: 45, waiting_period: 3
  end

  # GET /races/1/edit
  def edit
  end

  # POST /races
  # POST /races.json
  def create
    @race = Race.new(race_params)

    respond_to do |format|
      if @race.save
        format.html { redirect_to @race, notice: I18n.t(:create, scope: 'messages.crud', model: Race.model_name.human) }
        format.json { render :show, status: :created, location: @race }
      else
        format.html { render :new }
        format.json { render json: @race.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /races/1
  # PATCH/PUT /races/1.json
  def update
    respond_to do |format|
      if @race.update(race_params)
        format.html { redirect_to @race, notice: I18n.t(:update, scope: 'messages.crud', model: Race.model_name.human) }
        format.json { render :show, status: :ok, location: @race }
      else
        format.html { render :edit }
        format.json { render json: @race.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /races/1
  # DELETE /races/1.json
  def destroy
    @race.destroy
    respond_to do |format|
      format.html { redirect_to races_url, notice: I18n.t(:destroy, scope: 'messages.crud', model: Race.model_name.human) }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_race
    @race = Race.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def race_params
    params.require(:race).permit :name, :duration, :mode, :max_drive, :max_turn, :min_turn, :break_time, :waiting_period, :scheduled
  end
end
