User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             affiliation: "管理者",
             password:              "foobar",
             password_confirmation: "foobar",
             uid: 1111,
             admin:     true,
             superior: false,
             workingtime: Time.new(Time.now.year,Time.now.month,Time.now.day,00,00,00),
             basictime: Time.new(Time.now.year,Time.now.month,Time.now.day,00,00,00) ,
             activated: true,
             activated_at: Time.zone.now)
             
User.create!(name:  "上長1",
            email: "example1@railstutorial.org",
            affiliation: "上長1",
            password:              "foobar",
            password_confirmation: "foobar",
            uid: 1234,
            admin:     false,
            superior: true,
            workingtime: Time.new(Time.now.year,Time.now.month,Time.now.day,00,00,00),
            basictime: Time.new(Time.now.year,Time.now.month,Time.now.day,00,00,00) ,
            activated: true,
            activated_at: Time.zone.now)

50.times do |n|
#   Faker::Config.locale = :ja
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
              email: email,
              affiliation: "一般",
              superior: false,
              password:              password,
              password_confirmation: password,
              uid: 2222,
              activated: true,
              activated_at: Time.zone.now)
end