window.AccountGames = angular.module('AccountGames', [])

AccountGamesController = ($scope) ->
  $scope.selectedAccountGames = []
  $scope.toggleModel = (item) ->
    if _.find($scope.selectedAccountGames, (i) ->  i.id == item.id)
      $scope.selectedAccountGames = _.filter $scope.selectedAccountGames, (i) ->
        i.id != item.id
    else
      $scope.selectedAccountGames.push item
  Object.defineProperty $scope, 'selected_ids',
    get:  ->
      _.map($scope.selectedAccountGames, (ac) -> ac.id).join ','
  Object.defineProperty $scope, 'selected',
    get:  ->
      if $scope.selectedAccountGames.length > 0
        "#{$scope.selectedAccountGames.length} jeu(x)..."
      else
        ''
  Object.defineProperty $scope, 'delete_disabled',
    get:  ->
      $scope.selectedAccountGames.length == 0

window.AccountGames.controller 'AccountGamesController', AccountGamesController

$ ->
  $(".parties_count").tooltip()
  $(".game-preview").tooltip()
