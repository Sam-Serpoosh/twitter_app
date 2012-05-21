Factory.define :user do |user|
  
  user.name "Masih Jesus"
  user.email "ssjesus287@gmail.com"
  user.password "foobar"
  user.password_confirmation "foobar"

end #when the tests run this will automatically create this user into the database

Factory.sequence :email do |n|

  "person-#{n}@example.com"

end

Factory.define :micropost do |micropost|

  micropost.content "foo bar"
  micropost.association :user

end
