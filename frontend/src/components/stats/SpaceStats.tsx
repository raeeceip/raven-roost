import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Users, Clock, Building2, BrainCircuit } from 'lucide-react';

interface StatsCardProps {
  title: string;
  value: string | number;
  description: string;
  icon: React.ReactNode;
}

const StatsCard = ({ title, value, description, icon }: StatsCardProps) => (
  <Card>
    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
      <CardTitle className="text-sm font-medium">{title}</CardTitle>
      {icon}
    </CardHeader>
    <CardContent>
      <div className="text-2xl font-bold">{value}</div>
      <p className="text-xs text-muted-foreground">{description}</p>
    </CardContent>
  </Card>
);

const SpaceStats = () => {
  const stats = [
    {
      title: "Total Spaces",
      value: "156",
      description: "Across all buildings",
      icon: <Building2 className="h-4 w-4 text-muted-foreground" />
    },
    {
      title: "Current Users",
      value: "2,842",
      description: "Students studying now",
      icon: <Users className="h-4 w-4 text-muted-foreground" />
    },
    {
      title: "Peak Hours",
      value: "2-5 PM",
      description: "Most active period",
      icon: <Clock className="h-4 w-4 text-muted-foreground" />
    },
    {
      title: "Focus Score",
      value: "8.4",
      description: "Average quietness rating",
      icon: <BrainCircuit className="h-4 w-4 text-muted-foreground" />
    }
  ];

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      {stats.map((stat, index) => (
        <StatsCard key={index} {...stat} />
      ))}
    </div>
  );
};

export { SpaceStats };