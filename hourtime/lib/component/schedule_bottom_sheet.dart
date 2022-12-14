import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hourtime/component/custom_text_field.dart';
import 'package:hourtime/model/category_color.dart';
import 'package:hourtime/database/drift_database.dart';
import 'package:path/path.dart';

import '../const/colors.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;

  const ScheduleBottomSheet({required this.selectedDate, Key? key}) : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();

  int? startTime;
  int? endTime;
  String? content;
  int? selectedColorId;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery
        .of(context)
        .viewInsets
        .bottom; // system UI(키보드)가 차지하는 화면만큼을 알아서 가져

    return GestureDetector( // bottomsheet의 어디든 누르면 스마트폰의 키보드가 내려가는 기능을 만듬
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SafeArea(
        child: Container(
            color: Colors.white,
            height: MediaQuery
                .of(context)
                .size
                .height / 2 + bottomInset,
             child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
                child: Form(
                  key: formKey,
                  child: Column( // Column은 기본적으로 가운데 정렬을 해준다.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Time(
                        onStartSaved: (String? val){
                          startTime = int.parse(val!);
                        },
                        onEndSaved: (String? val){
                          endTime = int.parse(val!);
                        },
                      ),
                      SizedBox(height: 16.0), // 여백 만들어주기
                      _Content(
                        onSaved: (String? val){
                          content = val;
                        },
                      ),
                      SizedBox(height: 16.0), // 여백 만들어주기
                        FutureBuilder<List<CategoryColor>>(
                          future: GetIt.I<LocalDatabase>().getCategoryColors(),
                          builder: (content, snapshot){
                            if(snapshot.hasData &&
                              selectedColorId == null &&
                              snapshot.data!.isNotEmpty){
                              selectedColorId = snapshot.data![0].id;
                            }

                            return _ColorPicker(
                              colors: snapshot.hasData
                                  ? snapshot.data!
                                 : [],
                              selectedColorId: selectedColorId,
                              colorIdSetter: (int id){
                                setState((){
                                  selectedColorId = id;
                                });
                              },
                            );
                          },
                        ),
                       SizedBox(height: 8.0), // 여백
                      _SaveButton(
                        onPressed: onSavePressed,
                      ),
                    ],
                  ),
                ),
              ),
            )
        ),
      ),
    );
  }

  void onSavePressed() async {
    // formKey는 생성했는데 Form 위젯과 결합을 안했을때
    if(formKey.currentState == null){
      return;
    }

    if(formKey.currentState!.validate()){
      formKey.currentState!.save();

      final key = await GetIt.I<LocalDatabase>().createSchedule(
        SchedulesCompanion(
          date: Value(widget.selectedDate),
          startTime: Value(startTime!),
          endTime: Value(endTime!),
          content: Value(content!),
          colorId: Value(selectedColorId!),
        ),
      );

      // Navigator.of(context).pop();
    }else{
      print('에러가 있습니다.');
    }
  }
}

class _Time extends StatelessWidget {
  final FormFieldSetter<String> onStartSaved;
  final FormFieldSetter<String> onEndSaved;

  const _Time({
    required this.onStartSaved,
    required this.onEndSaved,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: CustomTextField(
          label: '시작 시간',
          isTime: true,
          onSaved: onStartSaved,
        )),
        // 그냥 CustomTextField(), 만 사용하면 얼마나 공간을 차지해야하는지 모르기 때문에 오류가 난다.
        SizedBox(width: 16.0),
        Expanded(child: CustomTextField(
          label: '마감 시간',
          isTime: true,
          onSaved: onEndSaved,
        )),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  const _Content({required this.onSaved, Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        label: '일정 내용',
        isTime: false,
        onSaved: onSaved,
      ),
    );
  }
}

typedef ColorIdSetter = void Function(int id);

class _ColorPicker extends StatelessWidget {
  final List<CategoryColor> colors;
  final int? selectedColorId;
  final ColorIdSetter colorIdSetter;

  const _ColorPicker({
    required this.colors,
    required this.selectedColorId,
    required this.colorIdSetter,
    Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // 양옆의 간격을 정해준다.
      runSpacing: 10.0, // 위 아래의 간격을 정해준다.
      children: colors
          .map(
            (e) => GestureDetector(
              onTap: (){
                colorIdSetter(e.id);
              },
              child: renderColor(
                e,
                selectedColorId == e.id,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget renderColor(CategoryColor color, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(
          int.parse(
            'FF${color.hexCode}',
            radix: 16,
          )
        ),
        border: isSelected ? Border.all(
          color: Colors.black,
          width: 4.0,
        ) :null,
      ),
      width: 32.0,
      height: 32.0,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              primary: PRIMARY_COLOR,
            ),
            child: Text('저장'),
          ),
        ),
      ],
    );
  }
}