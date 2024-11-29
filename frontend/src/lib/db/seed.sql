-- Reset tables
DROP TABLE IF EXISTS study_spaces;
DROP TABLE IF EXISTS users;

-- Create tables with enhanced schemas
CREATE TABLE study_spaces (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  building TEXT NOT NULL,
  floor INTEGER NOT NULL,
  capacity INTEGER NOT NULL,
  noise_level TEXT CHECK(noise_level IN ('quiet', 'moderate', 'loud')),
  amenities TEXT,
  coordinates_lat REAL,
  coordinates_lng REAL,
  description TEXT,
  image_url TEXT,
  hours_open TEXT,
  hours_close TEXT,
  is_reservable BOOLEAN DEFAULT false,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  role TEXT CHECK(role IN ('student', 'faculty', 'admin')),
  favorite_spaces TEXT,
  last_login DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Seed study spaces with more detailed data
INSERT INTO study_spaces (
  id, name, building, floor, capacity, noise_level, 
  amenities, coordinates_lat, coordinates_lng, 
  description, hours_open, hours_close, is_reservable
) VALUES
-- Library Spaces
('lib-1', 'Silent Study Area', 'MacOdrum Library', 5, 50, 'quiet',
'power_outlets,wifi,individual_desks,natural_light', 45.3838, -75.6981,
'Silent study area with individual desks and natural lighting', '07:00', '23:00', false),

('lib-2', 'Group Study Room 2A', 'MacOdrum Library', 2, 8, 'moderate',
'whiteboard,power_outlets,wifi,large_table,projector', 45.3838, -75.6981,
'Reservable group study room with presentation equipment', '07:00', '23:00', true),

('lib-3', 'Discovery Centre', 'MacOdrum Library', 4, 40, 'moderate',
'computers,power_outlets,wifi,printing,scanner', 45.3838, -75.6981,
'Technology-equipped study space with printing services', '08:00', '22:00', false),

-- University Centre Spaces
('uc-1', 'Atrium Study Space', 'University Centre', 1, 30, 'loud',
'power_outlets,wifi,cafe_nearby,natural_light', 45.3841, -75.6962,
'Open concept study area near dining options', '07:00', '22:00', false),

('uc-2', 'Mezzanine Quiet Zone', 'University Centre', 2, 20, 'quiet',
'power_outlets,wifi,individual_desks', 45.3841, -75.6962,
'Quiet study space overlooking the atrium', '07:00', '22:00', false),

-- Richcraft Hall Spaces
('rich-1', 'Reading Room', 'Richcraft Hall', 3, 40, 'quiet',
'power_outlets,wifi,natural_light,individual_desks', 45.3847, -75.6969,
'Peaceful study space with river views', '08:00', '21:00', false),

('rich-2', 'Collaboration Hub', 'Richcraft Hall', 2, 25, 'moderate',
'whiteboard,power_outlets,wifi,group_tables', 45.3847, -75.6969,
'Modern space designed for group work', '08:00', '21:00', false),

-- Dunton Tower Spaces
('dt-1', 'Graduate Study Lounge', 'Dunton Tower', 20, 15, 'quiet',
'power_outlets,wifi,kitchenette,couch', 45.3833, -75.6976,
'Exclusive study space for graduate students', '07:00', '23:00', false),

('dt-2', 'Student Success Centre', 'Dunton Tower', 4, 35, 'moderate',
'computers,power_outlets,wifi,printing,tutoring', 45.3833, -75.6976,
'Study space with access to academic support', '09:00', '17:00', false);

-- Seed test users
INSERT INTO users (id, email, name, role, favorite_spaces) VALUES
('user-1', 'student@carleton.ca', 'Test Student', 'student', 'lib-1,uc-1'),
('user-2', 'faculty@carleton.ca', 'Test Faculty', 'faculty', 'dt-1'),
('user-3', 'admin@carleton.ca', 'Test Admin', 'admin', NULL);