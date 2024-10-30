import React from 'react';
import { MenuIcon, XIcon, HomeIcon, MapIcon, StarIcon, UserIcon } from 'lucide-react';
import { useState } from 'react';
import {
  NavigationMenu,
  NavigationMenuList,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuTrigger,
  NavigationMenuContent
} from '@/components/ui/navigation-menu';

const navigation = [
  { name: 'Home', href: '/', icon: HomeIcon },
  { name: 'Map', href: '/map', icon: MapIcon },
  { name: 'Favorites', href: '/favorites', icon: StarIcon },
  { name: 'Profile', href: '/profile', icon: UserIcon },
];

const MainNav = () => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  return (
    <nav className="bg-[#222222] border-b border-[#BA0C2F]">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="flex h-16 justify-between">
          <div className="flex">
            <div className="flex flex-shrink-0 items-center">
              <a href="/" className="flex items-center space-x-2">
                <img
                  className="h-8 w-auto"
                  src="/carleton-logo.svg"
                  alt="Carleton"
                />
                <span className="text-white font-semibold text-lg">Roost</span>
              </a>
            </div>

            {/* Desktop Navigation using Radix UI NavigationMenu */}
            <div className="hidden sm:ml-6 sm:flex">
              <NavigationMenu>
                <NavigationMenuList>
                  {navigation.map((item) => (
                    <NavigationMenuItem key={item.name}>
                      <NavigationMenuLink 
                        href={item.href}
                        className="inline-flex items-center px-3 py-2 text-sm font-medium text-gray-300 hover:text-white"
                      >
                        <item.icon className="h-4 w-4 mr-2" />
                        {item.name}
                      </NavigationMenuLink>
                    </NavigationMenuItem>
                  ))}
                </NavigationMenuList>
              </NavigationMenu>
            </div>
          </div>

          {/* Keep the mobile menu as is */}
          <div className="flex items-center sm:hidden">
            {/* ... rest of your mobile menu code ... */}
          </div>
        </div>
      </div>

      {/* ... rest of your mobile menu code ... */}
    </nav>
  );
};

export default MainNav;