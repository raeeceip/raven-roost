import React, { useEffect, useRef, useState } from 'react';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

const MapComponent = ({ spaces }) => {
  const mapRef = useRef(null);
  const [map, setMap] = useState(null);

  useEffect(() => {
    if (typeof window !== 'undefined' && !map) {
      const newMap = L.map(mapRef.current).setView([45.3850, -75.6972], 15);
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
      }).addTo(newMap);
      setMap(newMap);
    }

    return () => map?.remove();
  }, []);

  useEffect(() => {
    if (map && spaces.length > 0) {
      spaces.forEach(space => {
        const marker = L.marker([space.lat, space.lng])
          .addTo(map)
          .bindPopup(`
            <h3>${space.name}</h3>
            <p>${space.building} - Floor ${space.floor}</p>
            <a href="/spaces/${space.id}" class="text-blue-500 hover:underline">View Details</a>
          `);

        marker.on('click', () => {
          map.setView([space.lat, space.lng], 18);
        });
      });
    }
  }, [map, spaces]);

  const focusOnBuilding = (buildingName) => {
    const space = spaces.find(s => s.building === buildingName);
    if (space && map) {
      map.setView([space.lat, space.lng], 18);
    }
  };

  return (
    <div>
      <div ref={mapRef} style={{ height: '500px' }} />
      <div className="mt-4">
        {spaces.map(space => (
          <button
            key={space.id}
            onClick={() => focusOnBuilding(space.building)}
            className="mr-2 mb-2 px-3 py-1 bg-blue-500 text-white rounded hover:bg-blue-600"
          >
            {space.building}
          </button>
        ))}
      </div>
    </div>
  );
};

export default MapComponent;