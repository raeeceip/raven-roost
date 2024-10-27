require 'faker'

# Clear existing data
Space.destroy_all
User.destroy_all

# Create users
users = 10.times.map do
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    password: 'password',
    role: %w[admin staff user].sample
  )
end

# Create spaces with unique names
spaces = 20.times.map do
  Space.create!(
    name: Faker::Company.unique.name,
    building: Faker::Address.community,
    capacity: rand(10..100),
    current_occupancy: rand(0..100),
    status: %w[available busy full closed].sample
  )
end

# Index spaces in Elasticsearch
spaces.each do |space|
  space.__elasticsearch__.index_document
end


puts "Seeded #{User.count} users, #{Space.count} spaces, "