Factory.define :game do |g|
  g.name 'Bombay'
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
  g.name "test"
end

