require 'csv'

class TeamsController < ApplicationController
  before_action :set_race
  before_action :set_team, only: [:show, :edit, :move_up, :move_down, :update, :destroy]
  skip_before_filter :authenticate_user!, only: :handle_team_login
  skip_before_filter :authenticate_user!, only: :show, if: :request_by_team_token?

  # GET /teams
  # GET /teams.json
  def index
    @q = @race.teams.ransack(params[:q])
    @q.sorts = 'position asc' if @q.sorts.empty?
    page = (params[:page] || '1').to_i
    @teams = @q.result.includes(:attendances).page(page)
  end

  def set_registrating
    @race.update({:registrating_team_id => params[:id]})
    flash[:notice] = 'Registrierung wurde gestartet'
    redirect_to race_teams_url(@race)
  end

  # POST /teams/handle_team_login
  def handle_team_login
    token = params.require(:team).permit(:team_token)[:team_token]
    if token.present?
      team = @race.teams.find_by(team_token:token)
      if team
        redirect_to race_team_url(@race, team.team_token)
        return
      end
    end
    redirect_to root_url
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    @penalties = @team.penalties.includes(:driver)
    headers['Refresh'] = "30"
    render request_by_team_token? ? 'score' : 'show'
  end

  # GET /teams/new
  def new
    @team = @race.teams.build
  end

  # GET /teams/1/edit
  def edit
  end

  def move_up
    if @team.move_higher
      flash[:notice] = 'Team wurde hoch sortiert'
    end
    redirect_to race_teams_url(@race)
  end

  def move_down
    if @team.move_lower
      flash[:notice] = 'Team wurde tief sortiert'
    end
    redirect_to race_teams_url(@race)
  end

  # POST /teams/import
  def import
    file = params[:import_file]

    if file.present?
      teams = drivers = 0
      CSV.foreach(file.path, encoding: 'windows-1252:utf-8', headers: true, col_sep: ';', skip_blanks: true) do |row|
        team = Team.where(race: @race).find_or_create_by(name: row[0]) do |t|
          t.team_lead = row[1]
          teams += 1
        end
        unless row[2].blank?
          driver = Driver.find_or_create_by(name: row[2]) do |_driver|
            drivers += 1
          end
          team.attendances.create(driver: driver)
        end
      end
      flash[:notice] = "#{teams} Teams und #{drivers} Fahrer neu angelegt"
    else
      flash[:error] = 'Keine Importdatei angegeben'
    end

    redirect_to race_teams_url(@race)
  end

  # POST /teams
  # POST /teams.json
  def create
    @team = @race.teams.build team_params

    respond_to do |format|
      if @team.save
        format.html { redirect_to [@race, @team], notice: I18n.t(:create, scope: 'messages.crud', model: Team.model_name.human) }
        format.json { render :show, status: :created, location: @team }
      else
        format.html { render :new }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    respond_to do |format|
      if @team.update(team_params)
        format.html { redirect_to [@race, @team], notice: I18n.t(:update, scope: 'messages.crud', model: Team.model_name.human) }
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
      format.html { redirect_to race_teams_url(@race), notice: I18n.t(:destroy, scope: 'messages.crud', model: Team.model_name.human) }
      format.json { head :no_content }
    end
  end

  private

  def request_by_team_token?
    params[:id] =~ /\A[A-Z0-9]{8}\z/
  end

  def set_race
    @race = Race.friendly.find(params[:race_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  def set_team
    @team = if request_by_team_token?
              Team.find_by!(team_token: params[:id])
            else
              Team.find(params[:id])
            end
  rescue ActiveRecord::RecordNotFound
    redirect_to race_teams_url(@race)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def team_params
    params.require(:team).permit(:name, :logo, :logo_delete, :team_lead, :batch_create_drivers, attendances_attributes: [:id, :driver_id, :_destroy])
  end
end
