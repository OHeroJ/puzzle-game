import 'package:supabase/supabase.dart' as supabase;

class MockSupabaseClient {
  MockSupabaseClient();

  MockFrom from(String table) {
    return MockFrom();
  }
}

class MockFrom {
  MockFrom();

  MockSelect select([String columns = '*', bool head = false, int? count]) {
    return MockSelect();
  }

  Future<List<Map<String, dynamic>>> insert(List<Map<String, dynamic>> data,
      [bool upsert = false,
      List<String>? returning,
      List<String>? defaultToNull]) async {
    // 模拟插入数据成功
    return data.map((item) => {'id': '123', ...item}).toList();
  }
}

class MockSelect {
  MockSelect();

  MockOrder order(String column, {bool ascending = true}) {
    return MockOrder();
  }
}

class MockOrder {
  MockOrder();

  MockLimit limit(int limit) {
    return MockLimit();
  }
}

class MockLimit {
  MockLimit();

  Future<List<Map<String, dynamic>>> execute() async {
    // 返回模拟的排行榜数据
    return [
      {
        'id': '1',
        'user_id': 'user1',
        'username': 'Player One',
        'score': 2000,
        'created_at': '2023-01-01T00:00:00.000',
        'avatar_url': null,
      },
      {
        'id': '2',
        'user_id': 'user2',
        'username': 'Player Two',
        'score': 1500,
        'created_at': '2023-01-02T00:00:00.000',
        'avatar_url': null,
      },
      {
        'id': '3',
        'user_id': 'user3',
        'username': 'Player Three',
        'score': 1000,
        'created_at': '2023-01-03T00:00:00.000',
        'avatar_url': null,
      },
    ];
  }
}