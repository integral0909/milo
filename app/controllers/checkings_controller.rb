class CheckingsController < ApplicationController
  before_action :set_checking, only: [:show, :edit, :update, :destroy]

  # GET /checkings
  # GET /checkings.json
  def index
    @checkings = Checking.all
  end

  # GET /checkings/1
  # GET /checkings/1.json
  def show
  end

  # GET /checkings/new
  def new
    @checking = Checking.new
  end

  # GET /checkings/1/edit
  def edit
    @select_account = Account.where(user_id: current_user.id).all.map{ |a| [ a.name, a.plaid_acct_id ] }
  end

  # POST /checkings
  # POST /checkings.json
  def create
    @checking = Checking.new(checking_params)

    respond_to do |format|
      if @checking.save
        Dwolla.connect_funding_source(@user)
        # TODO:send email about connecting the funding source
        
        format.html { redirect_to root_path, notice: 'Checking was successfully created.' } #@checking
        format.json { render :show, status: :created, location: @checking }
      else
        format.html { render :new }
        format.json { render json: @checking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /checkings/1
  # PATCH/PUT /checkings/1.json
  def update
    respond_to do |format|
      if @checking.update(checking_params)
        format.html { redirect_to @checking, notice: 'Checking was successfully updated.' }
        format.json { render :show, status: :ok, location: @checking }
      else
        format.html { render :edit }
        format.json { render json: @checking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checkings/1
  # DELETE /checkings/1.json
  def destroy
    @checking.destroy
    respond_to do |format|
      format.html { redirect_to checkings_url, notice: 'Checking was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_checking
    @checking = Checking.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def checking_params
    params.require(:checking).permit(:user_id, :plaid_acct_id)
  end

end
