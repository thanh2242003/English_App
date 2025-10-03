import 'package:english_app/core/widgets/my_button.dart';
import 'package:flutter/material.dart';
import '../../models/translation_quiz.dart';

class LessonTranslationWidget extends StatelessWidget {
  const LessonTranslationWidget({
    super.key,
    required this.question,
    //required this.onAnwer,
  });

  final TranslationQuiz question;

  //final void Function(String) onAnwer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.only(left: 70),
              child: Text(
                question.correctWord,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            SizedBox(height: 10,),
            Center(
              child: Image.asset(
                question.imagePath,
                width: 360,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 120),
            ...question.options.map((option) {
              return Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: MyButton(data: option, onTap: () {}),
              );
            }),
          ],
        ),
      ),
    );
  }
}
