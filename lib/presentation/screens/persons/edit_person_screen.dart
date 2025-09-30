import 'package:flutter/material.dart';
import 'package:kurban_frontend/core/constants/app_colors.dart';
import '../../../data/models/person.dart';
import '../../widgets/person_form_widget.dart';

class EditPersonScreen extends StatelessWidget {
  final Person person;

  const EditPersonScreen({
    super.key,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Person'),
        centerTitle: true,
      ),
      body: PersonFormWidget(
        person: person,
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Person updated successfully'),
              backgroundColor: AppColors.completed,
            ),
          );
          Navigator.of(context).pop(true);
        },
      ),
    );
  }
}