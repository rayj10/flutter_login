import 'package:flutter/material.dart';

class FormInput extends StatelessWidget {
  FormInput({this.fields, this.onSave, this.formKey});

  final List<Map> fields;
  final Function onSave;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: fields.map((e) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            child: TextFormField(
              decoration: InputDecoration(labelText: e['label'], errorText: e['error']),
              autocorrect: false,
              obscureText: e['secure'],
              controller: e['controller'],
              onSaved: (value) {
                onSave(e['key'], value);
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Your ${e['label']} is required';
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
