class BookingRequest {
  const BookingRequest({
    required this.id,
    required this.serviceId,
    required this.providerName,
    required this.eventDate,
    required this.guests,
    required this.customerName,
    required this.contact,
    required this.notes,
    required this.createdAt,
    this.venueId,
    this.cancelled = false,
  });

  final String id;
  final String serviceId;
  final int? venueId;
  final String providerName;
  final DateTime eventDate;
  final int guests;
  final String customerName;
  final String contact;
  final String notes;
  final DateTime createdAt;
  final bool cancelled;

  BookingRequest cancel() => BookingRequest(
    id: id,
    serviceId: serviceId,
    providerName: providerName,
    venueId: venueId,
    eventDate: eventDate,
    guests: guests,
    customerName: customerName,
    contact: contact,
    notes: notes,
    createdAt: createdAt,
    cancelled: true,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'serviceId': serviceId,
    'venueId': venueId,
    'providerName': providerName,
    'eventDate': eventDate.toIso8601String(),
    'guests': guests,
    'customerName': customerName,
    'contact': contact,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'cancelled': cancelled,
  };

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    final guests = json['guests'] as int;
    final name = json['customerName'] as String;
    final provider = json['providerName'] as String;
    if (guests < 1 || name.trim().isEmpty || provider.trim().isEmpty) {
      throw const FormatException('Invalid booking request');
    }
    return BookingRequest(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      venueId: json['venueId'] as int?,
      providerName: provider,
      eventDate: DateTime.parse(json['eventDate'] as String),
      guests: guests,
      customerName: name,
      contact: json['contact'] as String,
      notes: json['notes'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      cancelled: json['cancelled'] as bool? ?? false,
    );
  }
}
