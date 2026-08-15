import 'package:flutter_test/flutter_test.dart';
import 'package:steel_building_plant_panel/modules/bom_files_details/model/bom_document_mapper.dart';

void main() {
  test('maps one shared API BOM document without static fallbacks', () {
    final document = BomDocumentMapper.fromApi(
      projectId: 'project-1',
      response: {
        'projectDetail': {
          'projectName': 'API Project',
          'jobId': 'JOB-101',
          'client': {'firstName': 'Ada', 'lastName': 'Lovelace'},
        },
        'consolidatedBom': {
          'consolidatedBOM': {
            '_id': 'bom-1',
            'generatedAt': '2026-08-15T10:00:00.000Z',
            'fileUrl': 'https://example.com/bom.xlsx',
            'totalItems': 2,
            'totalWeight': 15.5,
            'totalPanelsArea': 20,
            'totalCost': 12.5,
            'groupedItems': {
              'ANGLES': [
                {
                  'category': 'ANGLES',
                  'partCode': 'A-1',
                  'description': 'Angle',
                  'qty': 1,
                  'weight': 10,
                  'totalCost': 0,
                },
              ],
              'PANELS': [
                {
                  'category': 'PANELS',
                  'partCode': 'P-1',
                  'description': 'Panel',
                  'qty': 1,
                  'weight': 5.5,
                  'totalCost': 12.5,
                },
              ],
            },
            'sentToVendors': [
              {'vendorId': 'vendor-1', 'sentAt': '2026-08-15T11:00:00Z'},
            ],
          },
        },
      },
    );

    expect(document.projectName, 'API Project');
    expect(document.customerName, 'Ada Lovelace');
    expect(document.bomId, 'bom-1');
    expect(document.sourceFileUrl, 'https://example.com/bom.xlsx');
    expect(document.items, hasLength(2));
    expect(document.items.first.category, 'ANGLES');
    expect(document.items.first.part, 'A-1');
    expect(document.items.first.amount, r'$0.00');
    expect(document.items.first.isMissing, isFalse);
    expect(document.summary.totalItems, 2);
    expect(document.summary.totalWeight, '15.5 lbs');
    expect(document.summary.totalPanelsArea, '20 sq ft');
    expect(document.summary.totalCost, r'$12.50');
    expect(document.sentToVendors.single['vendorId'], 'vendor-1');
  });
}
