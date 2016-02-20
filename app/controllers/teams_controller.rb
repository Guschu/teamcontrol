class TeamsController < ApplicationController
  before_action :set_race
  before_action :set_team, only: [:show, :edit, :update, :destroy]

  # GET /teams
  # GET /teams.json
  def index
    @q = @race.teams.ransack(params[:q])
    page = (params[:page] || '1').to_i
    @teams = @q.result.includes(:attendances).page(page)
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
  end

  # GET /teams/new
  def new
    @team = @race.teams.build
  end

  # GET /teams/1/edit
  def edit
  end

  # POST /teams
  # POST /teams.json
  def create
    @team = @race.teams.build team_params

    respond_to do |format|
      if @team.save
        format.html { redirect_to [@race, @team], notice: 'Team was successfully created.' }
        format.json { render :show, status: :created, location: @team }
      else
        format.html { ap @team.errors; render :new }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    # drivers = Driver.where(id: team_params[:drivers]).where.not(id: @team.attendances.pluck(:driver_id))
    # build_attendances(drivers)
    # @team.attendances.where.not(driver_id: drivers.map(&:id)).destroy_all

    respond_to do |format|
      if @team.update(team_params.except(:drivers))
        format.html { redirect_to [@race, @team], notice: 'Team was successfully updated.' }
        format.json { render :show, status: :ok, location: @team }
      else
        format.html { render :edit }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    @team.destroy
    respond_to do |format|
      format.html { redirect_to race_teams_url(@race), notice: 'Team was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /races/:race_id/:team_token
  def score
    @team = Team.find_by team_token: params[:team_token]
    redirect_to root_path unless @team
  end

  private

  def build_attendances(drivers)
    # Zerstöre alle Attendances, die übrigbleiben, wenn ich nach den drivern suche
    #
    drivers.each do |driver|
      @team.attendances.build driver: driver
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_race
    begin
      @race = Race.friendly.find(params[:race_id])
    rescue ActiveRecord::RecordNotFound => e
      redirect_to root_path
    end
  end

  def set_team
    @team = Team.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def team_params
    params.require(:team).permit(:name, :logo, :logo_delete, attendances_attributes:[ :id, :driver_id, :done, :_destroy ])
  end
end
