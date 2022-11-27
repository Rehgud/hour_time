import 'package:drift/drift.dart';
// drift가 원래 SQL을 사용해야하는 걸 편리하게 해줌

class Schedules extends Table{
  // ()(); 마지막에 괄호를 한번 더 쓰는 이유는 이 컬럼을 만드는 끝났다는 것을 표현한다.
  // 무조건 마지막에만 ();을 더 쓴다.

  // id column = PRIMARY KEY
  // 1
  // 2
  // 3
  // 계속해서 커짐
  IntColumn get id => integer().autoIncrement()();
  // autoIncrement() = 자동으로 숫자를 늘린다.

  // 내용
  TextColumn get content => text()();

  // 일정 날짜
  DateTimeColumn get date => dateTime()();

  // 시작 시간
  IntColumn get startTime => integer()();

  // 끝 시간
  IntColumn get endTime => integer()();

  // Category color Table ID
  IntColumn get colorId => integer()();

  // 생성 날짜
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  // DateTime.now()를 해줌으로써 자동으로 생성한 날짜를 입력받을 수 있다.
}