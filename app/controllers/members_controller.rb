class MembersController < ApplicationController
  layout "private"
  before_filter :login_required
  before_filter :load_resource, only: %i(edit update destroy)

  def index
    @members = current_account.members.active
    @members = @members.paginate(per_page: params[:per_page], page: params[:page])
    respond_with(@members)
  end

  def new
    @member = current_account.members.build
    respond_with(@member)
  end

  def create
    @member = current_account.members.create(member_params)
    respond_with @member
  end

  def edit
    respond_with(@member)
  end

  def update
    @member.update_attributes(member_params)
    respond_with @member
  end

  def destroy
    @member.destroy
    respond_with(@member)
  end

  protected

  def load_resource
    @member = current_account.members.find_by_id(params[:id])
  end

  def member_params
    params.require(:member).permit(:first_name, :last_name, :email, :active)
  end
end
