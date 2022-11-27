import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../const/colors.dart';

class CustomTextField extends StatelessWidget {
  // true - 시간, false - 내용         입력
  final bool isTime;
  final String label;
  final FormFieldSetter<String> onSaved;

  const CustomTextField({
    required this.isTime,
    required this.label,
    required this.onSaved,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: PRIMARY_COLOR,
            fontWeight: FontWeight.w600,
          ),
        ),
        if(isTime) renderTextField(),
        if(!isTime)
          Expanded(
            child: renderTextField(),
          ),
      ],
    );
  }
  Widget renderTextField(){
    return TextFormField(
      onSaved: onSaved,
      // From을 사용해 input들을 동시에 관리한다.
      // null이 return 되면 에러가 없다.
      // 에러가 있으면 에러를 String값으로 return
      validator: (String? val){
        if(val == null || val.isEmpty){
          return '값을 입력해주세요';
        }
      },
      cursorColor: Colors.grey,
      maxLines: isTime ? 1 : null, // 시간 입력시 1줄만 사용 가능, 내용을 입력시 무한입력가능
      expands: !isTime,
      keyboardType: isTime ? TextInputType.number : TextInputType.multiline,
      inputFormatters: isTime ? [
        FilteringTextInputFormatter.digitsOnly,
        // 숫자만 입력할 수 있게함 만약 블루투스 키보드로 영어를 입력하려해도 숫자만 받음
      ] : [],
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.grey[300],
      ),
    );
  }
}
