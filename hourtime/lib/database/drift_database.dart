import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hourtime/model/category_color.dart';
import 'package:path_provider/path_provider.dart';

import '../model/schedule.dart';
import 'package:path/path.dart' as p;

// part ''; -> import와 비슷한 느낌인데 import보다 넓게 적용
// import = private 값은 불러올 수 없다.
// part = private 값들까지 다 불러올 수 있다.
part 'drift_database.g.dart';

@DriftDatabase(
  tables: [
    Schedules, // ()없이 타입만 넣어준다.
    CategoryColors,
    // 위 두개의 클래스를 테이블로 사용한다 선언
  ],
)
class LocalDatabase extends _$LocalDatabase{
  LocalDatabase() : super(_openConnection());

  // insert
  Future<int> createSchedule(SchedulesCompanion data) => into(schedules).insert(data); // scheule을 저장할때 사용
  Future<int> createCategoryColor(CategoryColorsCompanion data) => into(categoryColors).insert(data); // color를 저장할때 사용

  // select
  Future<List<CategoryColor>> getCategoryColors() => select(categoryColors).get();

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection(){
  return LazyDatabase(()async{
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}