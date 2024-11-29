CREATE TABLE IF NOT EXISTS study_spaces (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  building TEXT NOT NULL,
  floor INTEGER NOT NULL,
  capacity INTEGER NOT NULL,
  noise_level TEXT CHECK(noise_level IN ('quiet', 'moderate', 'loud')),
  amenities TEXT,
  coordinates_lat REAL,
  coordinates_lng REAL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  role TEXT CHECK(role IN ('student', 'faculty', 'admin')),
  favorite_spaces TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);