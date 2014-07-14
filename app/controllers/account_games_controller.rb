# encoding: UTF-8
class AccountGamesController < ApplicationController
  layout "private"
  before_filter :login_required
  subnav :account_games

  def index
    scope = current_account.account_games.includes(:game, edition: :editor)
    scope = scope.order("games.name asc")
    scope = scope.recent if params[:kind] == 'recent'
    scope = scope.no_played if params[:kind] == 'never-played'

    if params[:kind] == 'extensions'
      scope = scope.merge(Game.extensions) if params[:kind] == 'extensions'
      scope = scope.paginate(per_page: params[:per_page], page: params[:page])
      @account_games = @paginated_account_game = scope
    else
      scope = scope.base_games
      scope = scope.paginate(per_page: params[:per_page], page: params[:page])
      @paginated_account_games = scope
      # add extensions right after their base games
      exts = current_account.account_games.game_extensions.where(games: { base_game_id: scope.pluck(:game_id)})
      @account_games = scope.inject([]) do |acc, ac_game|
        acc << ac_game
        loc_ext = exts.select { |ext| ext.game.base_game_id == ac_game.game_id }
        acc += loc_ext unless loc_ext.empty?
        acc
      end
    end
    respond_with(@account_games)
  end

  def export
    @account_games = current_account.games.group_by(&:target)
    respond_to do |format|
      format.csv { render layout: false }
    end
  end


  def new
    @title = t(".page_title")
    @new_games = 4.times.map { current_account.account_games.build }
  end

  def edit
    @account_game = current_account.account_games.find_id(params[:id])
    @editions = Edition.where(game_id: @account_game.game_id).order(:published_at)
  end

  def create
    acc_games = params[:account_games][:account_game].values.select{ |games| games["game_id"] != ""}
    acc_games.each { |ac| ac.delete(:game) }
    @new_games = current_account.account_games.create(acc_games)

    respond_to do |format|
      if @new_games.inject(true) { |acc, record| acc = acc && !record.new_record? }
        @account_games = current_account.account_games
        format.html { redirect_to account_games_url, notice:  "#{@new_games.count} jeux ont été ajoutés a votre ludotheque" }
        format.js do
          @account_game = @new_games.first
        end
      else
        format.html  do
          render action: :new
        end
      end
    end
  end

  def update
    @account_game = current_account.account_games.find_by_id(params[:id])
    #why this line
    params[:account_game] = params[:account_game][@account_game.id.to_s] if params[:account_game].size == 1
    respond_to do |format|
      if @account_game.update_attributes(params[:account_game])
        flash[:notice] = 'AccountGame was successfully created.'
        format.js { render json: @account_game }
        format.html { redirect_to account_games_url }
      else
        format.html { render action: :edit }
      end
    end
  end

  def delete_multiple
    acs = current_account.account_games.where(id: params[:delete_account_games][:ids].split(','))
    acs = acs.destroy_all
    redirect_to account_games_path, notice: "#{acs.size} jeu(x) supprimés de votre ludotheque"
  end

end
