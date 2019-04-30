module WorksHelper
  def working_time
    if User.find(1).designated_work_start_time
        BigDecimal(((User.find(1).designated_work_start_time-User.find(1).designated_work_start_time.beginning_of_day)/60/60).to_s).round(3).to_f
    end
  end
  
  def basic_time
    if User.find(1).basic_work_time
        BigDecimal(((User.find(1).basic_work_time-User.find(1).basic_work_time.beginning_of_day)/60/60).to_s).round(3).to_f
    end
  end
end
