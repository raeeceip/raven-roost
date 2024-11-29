import { RoostDB } from "@/lib/db";
import type { APIRoute } from "astro";
import type { SpaceFilters, StudySpace, EnhancedStudySpace, ApiResponse } from "@/lib/db/types";

export const GET: APIRoute = async ({ request, locals }): Promise<Response> => {
  try {
    const db = new RoostDB(locals.runtime.env);
    const url = new URL(request.url);
    
    // Enhanced filtering options
    const filters: SpaceFilters = {
      building: url.searchParams.get('building') || undefined,
      noiseLevel: url.searchParams.get('noiseLevel') as SpaceFilters['noiseLevel'],
      minCapacity: url.searchParams.get('minCapacity') ? 
        parseInt(url.searchParams.get('minCapacity')!) : undefined,
      isReservable: url.searchParams.get('isReservable') === 'true',
      isOpen: url.searchParams.get('isOpen') === 'true',
      amenities: url.searchParams.get('amenities')?.split(',')
    };

    // Get current hour for checking if space is open
    const now = new Date();
    const currentHour = `${now.getHours().toString().padStart(2, '0')}:00`;
    
    // Build SQL query with all filters
    let query = `
      SELECT * FROM study_spaces 
      WHERE 1=1
      ${filters.building ? 'AND building = ?' : ''}
      ${filters.noiseLevel ? 'AND noise_level = ?' : ''}
      ${filters.minCapacity ? 'AND capacity >= ?' : ''}
      ${filters.isReservable ? 'AND is_reservable = true' : ''}
      ${filters.isOpen ? `AND time('${currentHour}') BETWEEN time(hours_open) AND time(hours_close)` : ''}
      ${filters.amenities?.length ? 'AND amenities LIKE ?' : ''}
    `;

    // Build parameters array
    const params = [];
    if (filters.building) params.push(filters.building);
    if (filters.noiseLevel) params.push(filters.noiseLevel);
    if (filters.minCapacity) params.push(filters.minCapacity);
    if (filters.amenities?.length) params.push(`%${filters.amenities[0]}%`);

    const { results } = await locals.runtime.env.DB.prepare(query).bind(...params).all();

    // Get real-time availability data from KV and enhance spaces
    const spaces = await Promise.all(
      (results as StudySpace[]).map(async (space) => {
        const availability = await db.getSpaceAvailability(space.id);
        const isCurrentlyOpen = currentHour >= space.hours_open && currentHour <= space.hours_close;

        const enhancedSpace: EnhancedStudySpace = {
          ...space,
          amenities: space.amenities?.split(',') as Amenity[] || [],
          isCurrentlyOpen,
          ...availability,
          lastUpdated: new Date().toISOString()
        };

        return enhancedSpace;
      })
    );

    const response: ApiResponse<EnhancedStudySpace[]> = {
      success: true,
      data: spaces
    };

    return new Response(JSON.stringify(response), {
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (error) {
    const errorResponse: ApiResponse<never> = {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error occurred'
    };

    return new Response(JSON.stringify(errorResponse), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
};