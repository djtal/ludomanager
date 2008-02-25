module DashboardHelper
  def trends_for(data1, data2)
    if data1 < data2
        tag = image_tag("up_g.gif")    
    end
    
    if data1 > data2
      tag = image_tag("down_r.gif")
    end
    tag
  end
end
