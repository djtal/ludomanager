Factory.define :party do |p|
  p.association :account
  p.association :game
end