Factory.define :edition do |e|
  e.association :editor
  e.association :game
  e.lang "fr"
end
