class Pet {
  final int petId;
  final int ownerId;
  final String species;
  final String name;
  final String description;
  final String photoUrl;
  final String status;
  final int? adoptedBy;
  final int? interestedCount;

  Pet({
    required this.petId,
    required this.ownerId,
    required this.species,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.status,
    this.adoptedBy,
    required this.interestedCount
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      petId: json['pet_id'] as int,
      ownerId: json['owner_id'] as int,
      species: json['species'],
      name: json['name'],
      description: json['description'],
      photoUrl: json['photo_url'],
      status: json['status'],
      adoptedBy: json['adopted_by'] != null ? json['adopted_by'] : null,
      interestedCount: json['interested_count'] != null ? json['interested_count'] : null
    );
  }
}