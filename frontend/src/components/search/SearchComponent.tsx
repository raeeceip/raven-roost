import React, { useState, useEffect } from 'react';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Slider } from '@/components/ui/slider';
import { Search, Filter, Users, Volume2, Wifi } from 'lucide-react';
import type { EnhancedStudySpace, ApiResponse } from '@/lib/db/types';

interface SearchFilters {
  building?: string;
  noiseLevel?: string;
  minCapacity?: number;
  isReservable?: boolean;
  isOpen?: boolean;
}

export default function SearchComponent() {
  const [spaces, setSpaces] = useState<EnhancedStudySpace[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [filters, setFilters] = useState<SearchFilters>({});

  const fetchSpaces = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams();
      if (filters.building) params.append('building', filters.building);
      if (filters.noiseLevel) params.append('noiseLevel', filters.noiseLevel);
      if (filters.minCapacity) params.append('minCapacity', filters.minCapacity.toString());
      if (filters.isReservable) params.append('isReservable', 'true');
      if (filters.isOpen) params.append('isOpen', 'true');
      
      const response = await fetch(`/api/spaces?${params.toString()}`);
      if (!response.ok) throw new Error('Failed to fetch spaces');
      const result: ApiResponse<EnhancedStudySpace[]> = await response.json();
      if (!result.success) throw new Error(result.error || 'Failed to load spaces');
      setSpaces(result.data || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load spaces');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSpaces();
  }, [filters]);

  const filteredSpaces = spaces.filter(space => {
    if (!searchTerm) return true;
    const searchLower = searchTerm.toLowerCase();
    return (
      space.name.toLowerCase().includes(searchLower) ||
      space.building.toLowerCase().includes(searchLower) ||
      space.description?.toLowerCase().includes(searchLower)
    );
  });

  const resetFilters = () => {
    setFilters({});
    setSearchTerm('');
  };

  return (
    <div className="space-y-6">
      <Card>
        <CardContent className="p-6">
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
            {/* Search Input */}
            <div>
              <Label htmlFor="search">Search</Label>
              <div className="relative">
                <Search className="absolute left-2 top-2.5 h-4 w-4 text-gray-500" />
                <Input
                  id="search"
                  placeholder="Search spaces..."
                  className="pl-8"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
            </div>

            {/* Building Select */}
            <div>
              <Label htmlFor="building">Building</Label>
              <Select
                value={filters.building}
                onValueChange={(value) => setFilters({ ...filters, building: value })}
              >
                <SelectTrigger id="building">
                  <SelectValue placeholder="Select building" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="">All Buildings</SelectItem>
                  <SelectItem value="MacOdrum Library">MacOdrum Library</SelectItem>
                  <SelectItem value="University Centre">University Centre</SelectItem>
                  <SelectItem value="Richcraft Hall">Richcraft Hall</SelectItem>
                  <SelectItem value="Dunton Tower">Dunton Tower</SelectItem>
                  <SelectItem value="Tory Building">Tory Building</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Noise Level Select */}
            <div>
              <Label htmlFor="noiseLevel">Noise Level</Label>
              <Select
                value={filters.noiseLevel}
                onValueChange={(value) => setFilters({ ...filters, noiseLevel: value })}
              >
                <SelectTrigger id="noiseLevel">
                  <SelectValue placeholder="Select noise level" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="">Any Level</SelectItem>
                  <SelectItem value="quiet">Quiet</SelectItem>
                  <SelectItem value="moderate">Moderate</SelectItem>
                  <SelectItem value="loud">Loud</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Minimum Capacity Slider */}
            <div>
              <Label>Minimum Capacity: {filters.minCapacity || 0}</Label>
              <Slider
                value={[filters.minCapacity || 0]}
                min={0}
                max={100}
                step={5}
                onValueChange={(value) => setFilters({ ...filters, minCapacity: value[0] })}
                className="mt-2"
              />
            </div>
          </div>

          {/* Filter Actions */}
          <div className="flex justify-end mt-6 gap-2">
            <Button variant="outline" onClick={resetFilters}>
              Reset Filters
            </Button>
            <Button onClick={fetchSpaces}>
              <Filter className="mr-2 h-4 w-4" />
              Apply Filters
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Results Section */}
      {error ? (
        <div className="text-red-500 p-4 bg-red-50 rounded">{error}</div>
      ) : loading ? (
        <div className="flex items-center justify-center py-12">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900" />
        </div>
      ) : (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {filteredSpaces.map((space) => (
            <Card key={space.id} className="hover:shadow-lg transition-shadow">
              <CardContent className="p-6">
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900">{space.name}</h3>
                    <p className="text-sm text-gray-500">{space.building} - Floor {space.floor}</p>
                  </div>
                  <span className={`px-2 py-1 text-xs rounded-full ${
                    !space.isCurrentlyOpen ? 'bg-gray-100 text-gray-800' :
                    space.status === 'available' ? 'bg-green-100 text-green-800' :
                    space.status === 'limited' ? 'bg-yellow-100 text-yellow-800' :
                    'bg-red-100 text-red-800'
                  }`}>
                    {space.isCurrentlyOpen ? space.status : 'Closed'}
                  </span>
                </div>

                <div className="space-y-3">
                  <div className="flex items-center gap-2">
                    <Users className="h-4 w-4 text-gray-500" />
                    <span className="text-sm">
                      {space.currentOccupancy}/{space.capacity} seats taken
                    </span>
                  </div>

                  <div className="flex items-center gap-2">
                    <Volume2 className="h-4 w-4 text-gray-500" />
                    <span className="text-sm capitalize">{space.noise_level} noise level</span>
                  </div>

                  <div className="flex items-start gap-2">
                    <Wifi className="h-4 w-4 text-gray-500 mt-1" />
                    <div className="flex flex-wrap gap-1">
                      {space.amenities.map((amenity) => (
                        <span
                          key={amenity}
                          className="text-xs bg-gray-100 px-2 py-1 rounded"
                        >
                          {amenity.replace('_', ' ')}
                        </span>
                      ))}
                    </div>
                  </div>

                  <div className="text-sm text-gray-500">
                    Hours: {space.hours_open} - {space.hours_close}
                  </div>
                </div>

                <div className="mt-4 flex gap-2">
                  <Button
                    variant="outline"
                    className="flex-1"
                    onClick={() => window.location.href = `/spaces/${space.id}`}
                  >
                    View Details
                  </Button>
                  <Button
                    className="flex-1"
                    onClick={() => window.location.href = `/map?space=${space.id}`}
                  >
                    Show on Map
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}

          {filteredSpaces.length === 0 && (
            <div className="col-span-full text-center py-12 text-gray-500">
              No study spaces found matching your criteria
            </div>
          )}
        </div>
      )}
    </div>
  );
}