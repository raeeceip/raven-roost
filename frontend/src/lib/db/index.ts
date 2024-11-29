// src/lib/db/index.ts
// src/lib/db/index.ts
import type { StudySpace, User } from "./types";
import type { KVNamespace, D1Database } from '@cloudflare/workers-types';

export class RoostDB {
  constructor(
    private readonly env: {
      SPACES_KV: KVNamespace;
      USERS_KV: KVNamespace;
      DB: D1Database;
    }
  ) {}

  // Real-time space availability methods
  async getSpaceAvailability(spaceId: string): Promise<Pick<StudySpace, 'currentOccupancy' | 'status'>> {
    try {
      // Try KV first for real-time data
      const kvData = await this.env.SPACES_KV.get(spaceId, 'json');
      if (kvData) {
        return kvData as Pick<StudySpace, 'currentOccupancy' | 'status'>;
      }

      // Fallback to default values if no real-time data exists
      return { currentOccupancy: 0, status: 'available' };
    } catch (error) {
      console.error('Error getting space availability:', error);
      return { currentOccupancy: 0, status: 'available' };
    }
  }

  async updateSpaceAvailability(
    spaceId: string, 
    data: Pick<StudySpace, 'currentOccupancy' | 'status'>
  ): Promise<void> {
    const updateData = {
      ...data,
      lastUpdated: new Date().toISOString()
    };

    // Store real-time data in KV
    await this.env.SPACES_KV.put(spaceId, JSON.stringify(updateData));
  }

  async getSpaces(filters?: {
    building?: string;
    noiseLevel?: StudySpace['noiseLevel'];
    minCapacity?: number;
  }): Promise<StudySpace[]> {
    let query = 'SELECT * FROM study_spaces WHERE 1=1';
    const params: any[] = [];

    if (filters) {
      if (filters.building) {
        query += ' AND building = ?';
        params.push(filters.building);
      }
      if (filters.noiseLevel) {
        query += ' AND noise_level = ?';
        params.push(filters.noiseLevel);
      }
      if (filters.minCapacity) {
        query += ' AND capacity >= ?';
        params.push(filters.minCapacity);
      }
    }

    const { results } = await this.env.DB.prepare(query).bind(...params).all();
    
    // Transform database results to match StudySpace type
    const spaces = results.map((row: any) => ({
      id: row.id,
      name: row.name,
      building: row.building,
      floor: row.floor,
      capacity: row.capacity,
      noiseLevel: row.noise_level,
      amenities: row.amenities ? row.amenities.split(',') : [],
      lat: row.coordinates_lat,
      lng: row.coordinates_lng,
      currentOccupancy: 0, // Will be updated with real-time data
      status: 'available', // Will be updated with real-time data
      lastUpdated: new Date().toISOString()
    }));

    // Enhance with real-time data from KV
    const spacesWithAvailability = await Promise.all(
      spaces.map(async (space) => {
        const availability = await this.getSpaceAvailability(space.id);
        return { ...space, ...availability };
      })
    );

    return spacesWithAvailability;
  }

  // User management methods
  async getUser(userId: string): Promise<User | null> {
    const { results } = await this.env.DB
      .prepare('SELECT * FROM users WHERE id = ?')
      .bind(userId)
      .all();
    
    if (!results.length) return null;

    const row = results[0] as unknown as User;
    return {
      id: row.id,
      email: row.email,
      name: row.name,
      role: row.role,
      favoriteSpaces: row.favoriteSpaces || [],
      createdAt: row.createdAt,
      lastLogin: row.lastLogin
    };
  }

  async getUserSession(sessionId: string): Promise<string | null> {
    return await this.env.USERS_KV.get(sessionId);
  }

  async setUserSession(sessionId: string, userId: string): Promise<void> {
    await this.env.USERS_KV.put(sessionId, userId, { expirationTtl: 86400 });
  }
}