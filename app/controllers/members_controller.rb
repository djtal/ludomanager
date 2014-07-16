class MembersController < ApplicationController
  layout "private"
  before_filter :login_required
  before_filter :load_resource, only: %i(edit update destroy)

  has_scope :active, type: :boolean, default: true, allow_blank: true

  def index
    @members = current_account.members
    @members = apply_scopes(@members)
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
