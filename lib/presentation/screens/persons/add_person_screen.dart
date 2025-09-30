import 'package:flutter/material.dart';
import 'package:kurban_frontend/core/constants/app_colors.dart';
import '../../widgets/person_form_widget.dart';

class AddPersonScreen extends StatelessWidget {
  const AddPersonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Person'),
        centerTitle: true,
      ),
      body: PersonFormWidget(
        onSuccess: () {         
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Person added successfully'),
              backgroundColor: AppColors.completed,
            ),
          );
          Navigator.of(context).pop(true);
        },
      ),
    );
  }
}