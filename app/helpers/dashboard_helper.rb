module DashboardHelper
  
  def past?(month, year)
    date = DateTime.civil(year, month)
    date < @today.end_of_month
  end
  
end
