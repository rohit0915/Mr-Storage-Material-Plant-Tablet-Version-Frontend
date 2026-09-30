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
  final String fileUrl;

  DrawingItemModel({
    required this.id,
    required this.title,
    required this.size,
    required this.status,
    required this.type,
    this.uploadedBy = '—',
    this.location = '—',
    this.date = '—',
    this.pebCode = '—',
    this.fileUrl = '',
  });
}
