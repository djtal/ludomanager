Factory.define :account do |acc|
  acc.login "bob"
  acc.email  "bob@bob.com"
  acc.password "bob is the best"
  acc.password_confirmation "bob is the best"
end