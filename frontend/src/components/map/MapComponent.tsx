import React, { useEffect, useRef } from 'react';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

const MapComponent = () => {
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstance = useRef<L.Map | null>(null);

  useEffect(() => {
    // Fix Leaflet's default icon path issues
    delete (L.Icon.Default.prototype as any)._getIconUrl;
    L.Icon.Default.mergeOptions({
      iconRetinaUrl: '/marker-icon-2x.png',
      iconUrl: '/marker-icon.png',
      shadowUrl: '/marker-shadow.png',
    });

    if (typeof window !== 'undefined' && mapRef.current && !mapInstance.current) {
      // Carleton University coordinates
      const carletonCoords: L.LatLngTuple = [45.3850, -75.6972];
      
      // Create map instance
      mapInstance.current = L.map(mapRef.current).setView(carletonCoords, 16);

      // Add tile layer
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
      }).addTo(mapInstance.current);

      // Add example study spaces
      const studySpaces = [
        { name: 'MacOdrum Library', coords: [45.3832, -75.6982], availability: 'High' },
        { name: 'University Centre', coords: [45.3847, -75.6972], availability: 'Medium' },
        { name: 'Richcraft Hall', coords: [45.3855, -75.6963], availability: 'Low' },
      ];

      studySpaces.forEach(space => {
        L.marker([space.coords[0], space.coords[1]])
          .bindPopup(`
            <div class="space-info">
              <h3 class="font-bold">${space.name}</h3>
              <p>Availability: ${space.availability}</p>
              <button class="px-4 py-2 bg-blue-500 text-white rounded mt-2">
                View Details
              </button>
            </div>
          `)
          .addTo(mapInstance.current!);
      });
    }

    // Cleanup function
    return () => {
      if (mapInstance.current) {
        mapInstance.current.remove();
        mapInstance.current = null;
      }
    };
  }, []);

  return (
    <div ref={mapRef} className="h-[600px] w-full rounded-lg overflow-hidden" />
  );
};

export default MapComponent;