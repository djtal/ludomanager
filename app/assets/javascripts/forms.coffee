game_typeahead_template = _.template(
  """
  <div class='clearfix'>
    <img src="<%= image %>" class="pull-left tt-image" width="35" height="35">
    <%= name %>
    <% if (extension == true) { %>
      <br/>
      <span class='small text-muted'><i class='fa fa-chain'></i><%= base_game.name %></span>
    <% } %>
  </div>
  """
)

bindGamesTypehead = ->
  games = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    limit: 10,
    prefetch:
      url: '/games.json'
  )

  games.initialize()
  window.gamesSuggester = games

  _.each $('.game-typeahead'), (elt) ->
    $(elt).typeahead(
      null,
        name: 'games',
        displayKey: 'name',
        source: games.ttAdapter()
        templates:
          suggestion: game_typeahead_template
    )

  $("#account-games-form").on "typeahead:selected", (ev, suggest, ds) ->
    $($(ev.target).closest(".row").find(".game-typeahead-id")).val(suggest.id)

 $ ->
   bindGamesTypehead()
   _.each $('.date-time-picker'), (elt) ->
     $(elt).datetimepicker pickTime: false, language: 'fr', icons:
              time: "fa fa-clock-o",
              date: "fa fa-calendar",
              up: "fa fa-arrow-up",
              down: "fa fa-arrow-down"
