User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin:     true,
             workingtime: (Time.zone.local(2018, 8, 30, 19,0) - Time.zone.local(2018, 8, 30, 10,0))/60/60 ,
             basictime: (Time.zone.local(2018, 8, 30, 19,0) - Time.zone.local(2018, 8, 30, 10,0))/60/60 ,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
#   Faker::Config.locale = :ja
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
              email: email,
              password:              password,
              password_confirmation: password,
              activated: true,
              activated_at: Time.zone.now)
end

# users = User.order(:created_at).take(6)
# 50.times do
#   Faker::Config.locale = :ja
#   content = Faker::Lorem.sentence(5)
#   users.each { |user| user.microposts.create!(content: content) }
# end

# # リレーションシップ
# users = User.all
# user  = users.first
# following = users[2..50]
# followers = users[3..40]
# following.each { |followed| user.follow(followed) }
# followers.each { |follower| follower.follow(user) }