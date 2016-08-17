class ContactsController < ApplicationController
  layout "market"

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(params[:contact])
    @contact.request = request
    if @contact.deliver
      flash.now[:error] = nil
    else
      flash.now[:error] = "Can't send message."
      render :new
    end
  end
end
