Factory.define :account_game do |ac|
  ac.association :account
  ac.association :game, :factory => :game
  ac.parties_count 0 
end