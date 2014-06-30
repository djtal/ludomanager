class Public::LibrariesController < ApplicationController
  layout 'library'

  def show
    @account = Account.find_by_id(params[:id])

    @games = @account.games
    @games = @games.order("games.name asc")
    @games = @games.paginate(per_page: params[:per_page] || 25, page: params[:page])

  end
end
