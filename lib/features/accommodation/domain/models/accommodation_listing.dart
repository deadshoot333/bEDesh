/// Accommodation listing model
class AccommodationListing {
  final String id;
  final String title;
  final String description;
  final String location;
  final String city;
  final String country;
  final double rent;
  final String rentPeriod; // monthly, weekly
  final String propertyType; // apartment, house, room, studio
  final int bedrooms;
  final int bathrooms;
  final List<String> amenities;
  final List<String> images;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final DateTime availableFrom;
  final DateTime? availableTo;
  final bool isRoommateRequest;
  final String postedBy;
  final bool isVerified;
  final DateTime postedAt;
  final double? latitude;
  final double? longitude;
  final List<String> nearbyUniversities;
  final String gender; // male, female, any
  final bool petsAllowed;
  final bool smokingAllowed;

  const AccommodationListing({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.city,
    required this.country,
    required this.rent,
    required this.rentPeriod,
    required this.propertyType,
    required this.bedrooms,
    required this.bathrooms,
    required this.amenities,
    required this.images,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    required this.availableFrom,
    this.availableTo,
    required this.isRoommateRequest,
    required this.postedBy,
    required this.isVerified,
    required this.postedAt,
    this.latitude,
    this.longitude,
    required this.nearbyUniversities,
    required this.gender,
    required this.petsAllowed,
    required this.smokingAllowed,
  });
}
