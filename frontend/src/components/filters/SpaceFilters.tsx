import React from 'react';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Slider } from '@/components/ui/slider';
import { Search, Filter } from 'lucide-react';

interface FiltersProps {
  onSearch: (query: string) => void;
  onFilterChange: (filters: any) => void;
}

const SpaceFilters = ({ onSearch, onFilterChange }: FiltersProps) => {
  return (
    <div className="bg-white p-4 rounded-lg shadow space-y-4">
      <div className="flex gap-4">
        <div className="flex-1">
          <Label htmlFor="search">Search Spaces</Label>
          <div className="relative">
            <Search className="absolute left-2 top-2.5 h-4 w-4 text-gray-500" />
            <Input
              id="search"
              placeholder="Search by name or location..."
              className="pl-8"
              onChange={(e) => onSearch(e.target.value)}
            />
          </div>
        </div>
        
        <div className="w-48">
          <Label htmlFor="building">Building</Label>
          <Select onValueChange={(value) => onFilterChange({ building: value })}>
            <SelectTrigger id="building">
              <SelectValue placeholder="Select building" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="library">MacOdrum Library</SelectItem>
              <SelectItem value="uc">University Centre</SelectItem>
              <SelectItem value="richcraft">Richcraft Hall</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>
      
      <div className="space-y-2">
        <Label>Minimum Available Seats</Label>
        <Slider
          defaultValue={[0]}
          max={100}
          step={1}
          onValueChange={(value) => onFilterChange({ minSeats: value[0] })}
        />
      </div>
      
      <div className="flex justify-end space-x-2">
        <Button variant="outline" onClick={() => onFilterChange({})}>
          Reset Filters
        </Button>
        <Button>
          <Filter className="mr-2 h-4 w-4" />
          Apply Filters
        </Button>
      </div>
    </div>
  );
};

export { SpaceFilters };