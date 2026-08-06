class DrawingItemModel {
  final String id;
  final String title;
  final String size;
  final String status; // 'Pending Review', 'Approved', 'Revision Required'
  final String type; // 'drawing' or 'photo'
  final String uploadedBy;
  final String location;
  final String date;
  final String pebCode;

  DrawingItemModel({
    required this.id,
    required this.title,
    required this.size,
    required this.status,
    required this.type,
    this.uploadedBy = 'Rahul Sharma',
    this.location = 'Pune, Maharashtra',
    this.date = '25-April-2025',
    this.pebCode = 'PEB-1021',
  });
}
