Factory.define :member do |m|
  m.sequence(:name) {|n| "member#{n}" }
  m.nickname "bob"
  m.association :account
end