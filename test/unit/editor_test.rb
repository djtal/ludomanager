require 'test_helper'

class EditorTest < ActiveSupport::TestCase
  context "an Editor" do
    should_validate_presence_of :name
    should_validate_uniqueness_of :name, :case_sensitive => true
    should_have_attached_file :logo
  end
end
