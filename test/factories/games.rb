Factory.define :game do |g|
  g.sequence(:name) {|n| "game_#{n}" }
  g.min_player 2
  g.max_player 4
  g.difficulty 2
  g.target 1
  g.time_category 1
end


Factory.define :game_seq, :class => Game do |g|
  g.sequence(:name) {|n| "game_#{n}" }
  g.min_player 2
  g.max_player 4
  g.difficulty 2
  g.target 1
  g.time_category 1
end


Factory.define :extension, :class => Game do |g|
  g.sequence(:name) {|n| "extension_#{n}" }
  g.min_player 2
  g.max_player 4
  g.association :base_game, :factory => :game
end

Factory.define :standalone, :parent => :extension do |g|
  g.sequence(:name) {|n| "standalone#{n}" }
  g.standalone true
end
