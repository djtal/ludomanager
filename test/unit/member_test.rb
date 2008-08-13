require File.dirname(__FILE__) + '/../test_helper'

class MembersTest < ActiveSupport::TestCase
  fixtures :all
  
  def test_truth
    assert true
  end

  def test_import_should_create_members_from_csv_data
    raw = "frodon;sacke;tt@tt.com
            dark;vador;ii@ii.com"
    res = []
    current_account = accounts(:quentin)
    assert_difference "current_account.members.count", 2 do
      res = current_account.members.import(raw)
    end
    assert res[0] == 2
  end
  
  def test_import_shold_skip_bad_formated_line
    raw = ";ee;tt@tt.com
            dark;vador;ii@ii.com"
    current_account = accounts(:quentin)
    total = 0
    errors = {}
    assert_difference "current_account.members.count", 1 do
      total, errors = current_account.members.import(raw)
    end
    assert total == 1
    assert_equal 1, errors.keys.first
  end
end
