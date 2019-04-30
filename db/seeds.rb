User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             affiliation: "管理者",
             password:              "foobar",
             password_confirmation: "foobar",
             employee_number: 1111,
             admin:     true,
             superior: false,
             designated_work_start_time: Time.new(Time.now.year,Time.now.month,Time.now.day,00,00,00),
             designated_work_end_time: Time.new(Time.now.year,Time.now.month,Time.now.day,10,00,00),
             basic_work_time: Time.new(Time.now.year,Time.now.month,Time.now.day,00,00,00) ,
             activated: true,
             activated_at: Time.zone.now)
             
User.create!(name:  "上長1",
            email: "example1@railstutorial.org",
            affiliation: "上長1",
            password:              "foobar",
            password_confirmation: "foobar",
            employee_number: 1234,
            admin:     false,
            superior: true,
            designated_work_start_time: Time.new(Time.now.year,Time.now.month,Time.now.day,00,00,00),
            designated_work_end_time: Time.new(Time.now.year,Time.now.month,Time.now.day,10,00,00) ,
            basic_work_time: Time.new(Time.now.year,Time.now.month,Time.now.day,00,00,00) ,
            activated: true,
            activated_at: Time.zone.now)
            
User.create!(name:  "上長2",
            email: "example2@railstutorial.org",
            affiliation: "上長2",
            password:              "foobar",
            password_confirmation: "foobar",
            employee_number: 1235,
            admin:     false,
            superior: true,
            designated_work_start_time: Time.new(Time.now.year,Time.now.month,Time.now.day,00,00,00),
            designated_work_end_time: Time.new(Time.now.year,Time.now.month,Time.now.day,10,00,00),
            basic_work_time: Time.new(Time.now.year,Time.now.month,Time.now.day,00,00,00) ,
            activated: true,
            activated_at: Time.zone.now)

User.create!(name:  "上長3",
            email: "example3@railstutorial.org",
            affiliation: "上長3",
            password:              "foobar",
            password_confirmation: "foobar",
            employee_number: 1236,
            admin:     false,
            superior: true,
            designated_work_start_time: Time.new(Time.now.year,Time.now.month,Time.now.day,00,00,00),
            designated_work_end_time: Time.new(Time.now.year,Time.now.month,Time.now.day,10,00,00),
            basic_work_time: Time.new(Time.now.year,Time.now.month,Time.now.day,00,00,00) ,
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
              employee_number: 2222,
              activated: true,
              activated_at: Time.zone.now)
end