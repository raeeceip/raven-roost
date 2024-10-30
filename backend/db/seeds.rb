# db/seeds.rb
# Clear existing data
puts "Clearing existing data..."
Favorite.destroy_all
StudySpace.destroy_all
Building.destroy_all
User.destroy_all

puts "Creating buildings..."
begin
  library = Building.create!(
    name: 'MacOdrum Library',
    code: 'ML',
    latitude: 45.3832,
    longitude: -75.6982,
    description: 'Main university library'
  )
  puts "Created MacOdrum Library"

  uc = Building.create!(
    name: 'University Centre',
    code: 'UC',
    latitude: 45.3847,
    longitude: -75.6972,
    description: 'Student hub and services'
  )
  puts "Created University Centre"

  puts "Creating study spaces..."
  StudySpace.create!(
    name: 'Silent Study Area',
    building: library,
    capacity: 50,
    status: 'available',
    room_number: '2A',
    noise_level: 0,
    description: 'Silent study area on the second floor',
    amenities: { 'power_outlets' => true, 'wifi' => true, 'computers' => false }
  )
  puts "Created Silent Study Area"

  StudySpace.create!(
    name: 'Group Study Room',
    building: library,
    capacity: 8,
    status: 'available',
    room_number: '3B',
    noise_level: 2,
    description: 'Group study room with whiteboard',
    amenities: { 'power_outlets' => true, 'wifi' => true, 'whiteboard' => true }
  )
  puts "Created Group Study Room"

  StudySpace.create!(
    name: 'UC Study Lounge',
    building: uc,
    capacity: 30,
    status: 'available',
    room_number: '201',
    noise_level: 1,
    description: 'Open study area in University Centre',
    amenities: { 'power_outlets' => true, 'wifi' => true, 'food_allowed' => true }
  )
  puts "Created UC Study Lounge"

rescue => e
  puts "Error during seeding: #{e.message}"
  puts e.backtrace
  raise e
end

puts "Seeding completed successfully!"