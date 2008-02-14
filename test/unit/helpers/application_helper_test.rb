require File.dirname(__FILE__) + '/../../test_helper'
require File.expand_path(File.dirname(__FILE__) + '/../../helper_testcase')

class ApplicationHelperTest < HelperTestCase

  include ApplicationHelper

  fixtures :games

  def setup
    super
  end
  
end
