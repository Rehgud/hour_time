import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hourtime/component/schedule_bottom_sheet.dart';
import 'package:hourtime/component/schedule_card.dart';
import 'package:hourtime/model/schedule_width_color.dart';
import 'package:table_calendar/table_calendar.dart';

import '../component/calendar.dart';
import '../component/today_banner.dart';
import '../const/colors.dart';
import '../database/drift_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDay =
      DateTime.utc(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day
      );
  DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: renderFloatingActionButton(),
      body: SafeArea(
        child: Column(
          children: [
            Calendar(
              selectedDay: selectedDay,
              focusedDay: focusedDay,
              onDaySelected: onDaySelected,
            ),
            const SizedBox(height: 8.0),
            TodayBanner(
              selectedDay: selectedDay,
              scheduleCount: 3,
            ),
            SizedBox(height: 8.0),
            _SchedulList(
              selectedDate: selectedDay,
            ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton renderFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_){
            return ScheduleBottomSheet(
              selectedDate: selectedDay,
            );
          },
        );
      },
      backgroundColor: PRIMARY_COLOR,
      child: Icon(
        Icons.add,
      ),
    );
  }

  onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // 특정 날짜를 선택하면 색이들어옴
    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = selectedDay;
    });
  }
}

class _SchedulList extends StatelessWidget {
  final DateTime selectedDate;

  const _SchedulList({required this.selectedDate, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StreamBuilder<List<ScheduleWithColor>>(
          stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator());
            }
            if(snapshot.hasData && snapshot.data!.isEmpty){
              return Center(
                child: Text('스케줄이 없습니다.'),
              );
            }

            return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) {
                  return SizedBox(height: 8.0);
                },
                itemBuilder: (context, index) {
                  final scheduleWithColor = snapshot.data![index];

                  return ScheduleCard(
                      startTime: scheduleWithColor.schedule.startTime,
                      endTime: scheduleWithColor.schedule.endTime,
                      content: scheduleWithColor.schedule.content,
                    color: Color(
                      int.parse('FF${scheduleWithColor.categoryColor.hexCode}',
                      radix: 16,
                      ),
                    )
                  );
                });
          }
        ),
      ),
    );
  }
}
