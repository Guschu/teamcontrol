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
    render request_by_team_token? ? 'score' : 'show'
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
        format.html { redirect_to [@race, @team], notice: I18n.t(:create, scope:'messages.crud', model:Team.model_name.human )}
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
      if @team.update(team_params)
        format.html { redirect_to [@race, @team], notice: I18n.t(:update, scope:'messages.crud', model:Team.model_name.human ) }
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
      format.html { redirect_to race_teams_url(@race), notice: I18n.t(:destroy, scope:'messages.crud', model:Team.model_name.human ) }
      format.json { head :no_content }
    end
  end

  private

  def request_by_team_token?
    params[:id] =~ /\A[A-Z0-9]{8}\z/
  end

  def set_race
    begin
      @race = Race.friendly.find(params[:race_id])
    rescue ActiveRecord::RecordNotFound => e
      redirect_to root_path
    end
  end

  def set_team
    @team = if request_by_team_token?
      Team.find_by!(team_token:params[:id])
    else
      Team.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to race_teams_url(@race)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def team_params
    params.require(:team).permit(:name, :logo, :logo_delete, :batch_create_drivers, attendances_attributes:[ :id, :driver_id, :_destroy ])
  end
end
