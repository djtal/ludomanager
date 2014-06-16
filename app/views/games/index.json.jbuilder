json.array! @games do |game|
  json.extract! game, :id, :name, :min_player, :max_player
  json.extension game.extension?
  json.image game.box.url(:thumb)
  if game.extension?
    json.base_game do
      json.extract! game.base_game, :id, :name
    end
  end
end
