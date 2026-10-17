class CampusZone {
  final String id;
  final String name;
  final String shortCode;
  final double latitude;
  final double longitude;
  final String description;

  const CampusZone({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.latitude,
    required this.longitude,
    required this.description,
  });
}

class CampusLocations {
  // Center of VIT Vellore campus
  static const double vitCenterLat = 12.9692;
  static const double vitCenterLng = 79.1559;

  static const List<CampusZone> zones = [
    CampusZone(
      id: 'tt',
      name: 'Technology Tower (TT)',
      shortCode: 'TT',
      latitude: 12.9708,
      longitude: 79.1594,
      description: 'Academic block housing CS & IT departments and computer labs',
    ),
    CampusZone(
      id: 'sjt',
      name: 'Silver Jubilee Tower (SJT)',
      shortCode: 'SJT',
      latitude: 12.9719,
      longitude: 79.1636,
      description: 'High-rise academic block, labs, and faculty cabins',
    ),
    CampusZone(
      id: 'library',
      name: 'Central Library (Periyar EVR)',
      shortCode: 'LIB',
      latitude: 12.9698,
      longitude: 79.1578,
      description: 'Multi-storey central library, reading halls, digital labs',
    ),
    CampusZone(
      id: 'mgr',
      name: 'Dr. MGR Block (Main Building)',
      shortCode: 'MB',
      latitude: 12.9689,
      longitude: 79.1558,
      description: 'Administrative offices, auditorium, and lecture halls',
    ),
    CampusZone(
      id: 'smv',
      name: 'SMV Block (Mech / Civil)',
      shortCode: 'SMV',
      latitude: 12.9695,
      longitude: 79.1610,
      description: 'Engineering workshops, manufacturing labs, lecture halls',
    ),
    CampusZone(
      id: 'gdn',
      name: 'GDN Block (Biotech / Science)',
      shortCode: 'GDN',
      latitude: 12.9701,
      longitude: 79.1565,
      description: 'Bio labs, classrooms, and seminar halls',
    ),
    CampusZone(
      id: 'foodys',
      name: 'Foodys & Gazebo Courtyard',
      shortCode: 'FOOD',
      latitude: 12.9704,
      longitude: 79.1601,
      description: 'Central cafeteria, food stalls, outdoor seating',
    ),
    CampusZone(
      id: 'mh',
      name: 'Mens Hostel Complex (Blocks A-T)',
      shortCode: 'MH',
      latitude: 12.9665,
      longitude: 79.1582,
      description: 'Residential hostels, mess facilities, indoor gym',
    ),
    CampusZone(
      id: 'lh',
      name: 'Ladies Hostel Complex',
      shortCode: 'LH',
      latitude: 12.9735,
      longitude: 79.1572,
      description: 'Residential ladies hostel blocks, dining halls, gardens',
    ),
    CampusZone(
      id: 'sports',
      name: 'Sports Complex & Outdoor Stadium',
      shortCode: 'SPORTS',
      latitude: 12.9680,
      longitude: 79.1630,
      description: 'Running track, basketball courts, swimming pool, grounds',
    ),
  ];

  static CampusZone getById(String id) {
    return zones.firstWhere(
      (z) => z.id.toLowerCase() == id.toLowerCase(),
      orElse: () => zones[0],
    );
  }
}
