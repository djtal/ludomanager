require 'test_helper'

class EditionTest < ActiveSupport::TestCase
  fixtures :all
  
  def test_should_limit_available_lang
    assert clean_edition.save
    assert clean_edition(:lang => "fr").save
    assert !clean_edition(:lang => "zz").save
  end


  def test_should_take_lang_from_editor_if_not_set
    a =  clean_edition
    assert_equal nil, a.lang
    assert a.save
    assert_equal a.lang, a.editor.lang
  end


  def clean_edition(overrides = {})
    opts = {
      :game_id => games(:agricola).id,
      :editor_id => editors(:ystari).id
    }.merge(overrides)
    Edition.new(opts)
  end
end
