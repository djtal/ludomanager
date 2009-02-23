# Include your application configuration below
# DateTiem extra format see http://hittingthebuffers.com/2006/08/11/date-formats/ for more info

Date::DATE_FORMATS[:month] = "%m/%Y"
Date::DATE_FORMATS[:date_time_fr] = "%d/%m/%Y - %H:%M"
Date::DATE_FORMATS[:date_fr] = "%d/%m/%Y"



ActionView::Helpers::AssetTagHelper.register_javascript_include_default "behavior"

module ActiveSupport::CoreExtensions::Time::Calculations
  def end_of_year
    change(:month => 12,:day => 31,:hour => 23, :min => 59, :sec => 59, :usec => 0)
  end
end

require "csv"
require "countries"