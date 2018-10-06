module UsersHelper

  # 渡されたユーザーのGravatar画像を返す
  def gravatar_for(user, options = { size: 80 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
  
  def note_from_boss
    if current_user.admin?
      @note_from_boss = "【所属長承認申請のお知らせ】"
    end
  end
  
  def note_attendance_change
    if current_user.admin?
      @note_attendance_change ="【勤怠変更のお知らせ】"
    end
  end
  
  def note_overtime_application
    if current_user.admin?
      @note_overtime_application ="【残業申請のお知らせ】"
    end
  end
end