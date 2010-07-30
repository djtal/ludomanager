Factory.define :tag do |tag|
  tag.sequence(:name) {|n| "tag_#{n}" }
end