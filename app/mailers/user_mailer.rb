
class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user
    mail to: user.email, subject: "アカウントを有効化する"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "パスワードのリセット"
  end
end