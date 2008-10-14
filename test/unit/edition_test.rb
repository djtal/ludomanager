require 'test_helper'

class EditionTest < ActiveSupport::TestCase
  fixtures :all
  
  def test_should_limit_available_lang
    assert clean_edition.save
    assert clean_edition(:lang => "fr").save
    assert !clean_edition(:lang => "zz").save
  end


  def clean_edition(overrides = {})
    opts = {
      :game_id => games(:agricola).id,
      :editor_id => editors(:ystari).id
    }.merge(overrides)
    Edition.new(opts)
  end
end
