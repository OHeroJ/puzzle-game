import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/level_selection/jigsaw_service.dart';
import 'package:puzzle/src/level_selection/jigsaw_info.dart';

void main() {
  group('JigsawService', () {
    // 测试默认数据
    group('getDefaultJigsaws', () {
      test('should return default jigsaw list', () {
        final service = JigsawService(null); // 传入null，因为我们只测试默认数据
        
        // 测试公共方法
        final result = service.getDefaultJigsaws();
        
        expect(result, isA<List<JigsawInfo>>());
        expect(result.length, 2);
        expect(result[0].title, 'Mountain Landscape');
        expect(result[1].title, 'Forest Path');
      });
    });
  });
}