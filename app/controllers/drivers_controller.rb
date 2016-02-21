# == Schema Information
#
# Table name: drivers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DriversController < ApplicationController
  before_action :set_driver, only: [:show, :edit, :update, :destroy]

  # GET /drivers
  # GET /drivers.json
  def index
    @q = Driver.ransack(params[:q])
    @q.sorts = 'name asc' if @q.sorts.empty?
    page = (params[:page] || '1').to_i
    @drivers = @q.result.page(page)
  end

  # GET /drivers/1
  # GET /drivers/1.json
  def show
  end

  # GET /drivers/new
  def new
    @driver = Driver.new
  end

  # GET /drivers/1/edit
  def edit
  end

  # POST /drivers
  # POST /drivers.json
  def create
    @driver = Driver.new(driver_params)

    respond_to do |format|
      if @driver.save
        format.html { redirect_to @driver, notice: I18n.t(:create, scope:'messages.crud', model:Driver.model_name.human ) }
        format.json { render :show, status: :created, location: @driver }
      else
        format.html { render :new }
        format.json { render json: @driver.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /drivers/1
  # PATCH/PUT /drivers/1.json
  def update
    respond_to do |format|
      if @driver.update(driver_params)
        format.html { redirect_to @driver, notice: I18n.t(:update, scope:'messages.crud', model:Driver.model_name.human ) }
        format.json { render :show, status: :ok, location: @driver }
      else
        format.html { render :edit }
        format.json { render json: @driver.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /drivers/1
  # DELETE /drivers/1.json
  def destroy
    @driver.destroy
    respond_to do |format|
      format.html { redirect_to drivers_url, notice: I18n.t(:destroy, scope:'messages.crud', model:Driver.model_name.human ) }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_driver
    @driver = Driver.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def driver_params
    params.require(:driver).permit(:name)
  end
end
