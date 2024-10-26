import React from 'react';
import { Clock, Users, MapPin, ChevronRight } from 'lucide-react';

interface SpaceCardProps {
  space: {
    id: string;
    name: string;
    building: string;
    currentOccupancy: number;
    capacity: number;
    lastUpdated: string;
    isAvailable: boolean;
  };
}

const SpaceCard: React.FC<SpaceCardProps> = ({ space }) => {
  const occupancyPercentage = (space.currentOccupancy / space.capacity) * 100;
  
  const getStatusColor = () => {
    if (occupancyPercentage >= 90) return 'bg-[#BA0C2F]';
    if (occupancyPercentage >= 70) return 'bg-yellow-500';
    return 'bg-green-500';
  };

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden border-l-4 border-[#BA0C2F] hover:shadow-lg transition-shadow">
      <div className="p-6">
        <div className="flex justify-between items-start">
          <div>
            <h3 className="text-lg font-semibold text-[#222222]">{space.name}</h3>
            <div className="flex items-center text-[#767679] mt-1">
              <MapPin className="h-4 w-4 mr-1" />
              <span className="text-sm">{space.building}</span>
            </div>
          </div>
          <span
            className={`px-3 py-1 rounded-full text-white text-sm font-medium ${getStatusColor()}`}
          >
            {space.isAvailable ? 'Available' : 'Full'}
          </span>
        </div>

        <div className="mt-4">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-[#767679]">Occupancy</span>
            <span className="text-sm font-medium text-[#222222]">
              {space.currentOccupancy} / {space.capacity}
            </span>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div
              className={`h-2 rounded-full ${getStatusColor()}`}
              style={{ width: `${occupancyPercentage}%` }}
            />
          </div>
        </div>

        <div className="mt-4 flex justify-between items-center">
          <div className="flex items-center text-sm text-[#767679]">
            <Clock className="h-4 w-4 mr-1" />
            <span>Updated {space.lastUpdated}</span>
          </div>
          <a
            href={`/spaces/${space.id}`}
            className="inline-flex items-center text-[#BA0C2F] hover:text-[#8A0923] transition-colors"
          >
            View Details
            <ChevronRight className="h-4 w-4 ml-1" />
          </a>
        </div>
      </div>
    </div>
  );
};

export default SpaceCard;