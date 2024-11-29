// Amenity types for better type checking
export type Amenity = 
  | 'power_outlets'
  | 'wifi'
  | 'individual_desks'
  | 'whiteboard'
  | 'large_table'
  | 'cafe_nearby'
  | 'natural_light'
  | 'computers'
  | 'printing';

export type NoiseLevel = 'quiet' | 'moderate' | 'loud';
export type SpaceStatus = 'available' | 'limited' | 'full';
export type UserRole = 'student' | 'faculty' | 'admin';

export interface StudySpace {
  id: string;
  name: string;
  building: string;
  floor: number;
  capacity: number;
  noise_level: NoiseLevel;
  amenities: string; // Stored as comma-separated string in DB
  coordinates_lat: number;
  coordinates_lng: number;
  description?: string;
  hours_open: string;
  hours_close: string;
  is_reservable: boolean;
  created_at: string;
}

// Runtime-enhanced study space with additional properties
export interface EnhancedStudySpace extends Omit<StudySpace, 'amenities'> {
  currentOccupancy: number;
  status: SpaceStatus;
  lastUpdated: string;
  amenities: Amenity[];
  isCurrentlyOpen: boolean;
}

export interface User {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  favorite_spaces: string | null; // Stored as comma-separated string in DB
  created_at: string;
  last_login?: string;
}

// Database filter types
export interface SpaceFilters {
  building?: string;
  noiseLevel?: NoiseLevel;
  minCapacity?: number;
  amenities?: string[];
  isReservable?: boolean;
  isOpen?: boolean;
}

// API response types
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
}