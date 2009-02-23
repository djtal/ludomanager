ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  
  
  # Add more helper methods to be used by all tests here...
  include AuthenticatedTestHelper
  
  
  # Check if model is valid for successive attribut value
  # Exemple
  # assume we have a Game model with a dificult attribut limited from 1 to 5
  # assert_valid Game.new, :dificulty, 0, 1, 2, 3, 4, 5
  #
  def assert_invalid(model, attribute, *values)
    if values.empty?
      assert ! model.valid?, "Object is valid with value: #{model.send(attribute)}"
      assert ! model.save, "Object saved."
      assert model.errors.invalid?(attribute.to_s), "#{attribute} has no attached error"
    else
      values.flatten.each do |value|
        obj = model.dup
        obj.send("#{attribute}=", value)
        assert_invalid obj, attribute
      end
    end
  end


  def assert_valid(model, attribute=nil, *values)
    if values.empty?
      unless attribute.nil?
        assert model.valid?, "Object is not valid with value: #{model.send(attribute)}"
      else
        assert model.valid?, model.errors.full_messages
      end
      assert model.errors.empty?, model.errors.full_messages
    else
      m = model.dup # the recursion was confusing mysql
      values.flatten.each do |value|
        obj = m.dup
        obj.send("#{attribute}=", value)
        assert_valid(obj, attribute)
      end
    end
  end
end
