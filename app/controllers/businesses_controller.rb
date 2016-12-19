class BusinessesController < ApplicationController
  before_action :set_business, only: [:edit, :update]

  def edit
    @business.current_user.business
  end

  def update
    respond_to do |format|
      if @business.update(business_params)
        format.html { redirect_to @business, notice: 'Business was successfully updated.' }
        format.json { render :show, status: :ok, location: @business }
      else
        format.html { render :edit }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_business
    @business = current_user.business
  end

  def business_params
    params.require(:business).permit(:name, :contribution, :frequency)
  end

end
