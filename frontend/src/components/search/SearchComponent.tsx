// src/components/search/SearchComponent.tsx
import React, { useState } from 'react';
import Fuse from 'fuse.js';
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Search } from 'lucide-react';

const dummySpaces = [
  {
    id: '1',
    name: 'Silent Study Area',
    building: 'MacOdrum Library',
    floor: '5th Floor',
    type: 'Silent',
    capacity: 30,
    amenities: ['Power Outlets', 'Wi-Fi', 'Natural Light']
  },
  // Add more dummy data
];

const fuseOptions = {
  keys: ['name', 'building', 'type', 'amenities'],
  threshold: 0.3
};

const fuse = new Fuse(dummySpaces, fuseOptions);

const SearchComponent = () => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState(dummySpaces);

  const handleSearch = (searchQuery: string) => {
    setQuery(searchQuery);
    if (!searchQuery) {
      setResults(dummySpaces);
      return;
    }
    const searchResults = fuse.search(searchQuery);
    setResults(searchResults.map(result => result.item));
  };

  return (
    <div>
      <div className="flex gap-4 mb-8">
        <Input
          type="text"
          placeholder="Search by name, building, or amenities..."
          value={query}
          onChange={(e) => handleSearch(e.target.value)}
          className="max-w-xl"
        />
        <Button>
          <Search className="w-4 h-4 mr-2" />
          Search
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {results.map((space) => (
          <Card key={space.id}>
            <CardContent className="p-6">
              <h3 className="font-semibold text-lg mb-2">{space.name}</h3>
              <p className="text-gray-600">{space.building} - {space.floor}</p>
              <div className="mt-4">
                <span className="text-sm font-medium text-gray-500">Amenities:</span>
                <div className="flex flex-wrap gap-2 mt-2">
                  {space.amenities.map((amenity) => (
                    <span
                      key={amenity}
                      className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-carleton-red/10 text-carleton-red"
                    >
                      {amenity}
                    </span>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default SearchComponent;