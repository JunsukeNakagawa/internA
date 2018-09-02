module WorksHelper
  def working_time
    if User.find(1).workingtime
        BigDecimal(((User.find(1).workingtime-User.find(1).workingtime.beginning_of_day)/60/60).to_s).round(3).to_f
    end
  end
  
  def basic_time
    if User.find(1).basictime
        BigDecimal(((User.find(1).basictime-User.find(1).basictime.beginning_of_day)/60/60).to_s).round(3).to_f
    end
  end
end
