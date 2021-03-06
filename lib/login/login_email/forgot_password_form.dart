import 'package:face_app/bloc/data_classes/app_color.dart';
import 'package:face_app/bloc/login_logic.dart';
import 'package:face_app/localizations/localizations.dart';
import 'package:face_app/util/app_toast.dart';
import 'package:face_app/util/constants.dart';
import 'package:face_app/util/input_field.dart';
import 'package:flutter/material.dart';

class ForgotPasswordForm extends StatefulWidget {
  final AppColor color;

  const ForgotPasswordForm({Key key, @required this.color}) : super(key: key);

  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  TextEditingController controller;

  GlobalKey<FormState> _formKey = GlobalKey(
    debugLabel: "Forgot Password Form Key",
  );

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(primarySwatch: widget.color.color),
      child: DraggableScrollableSheet(
        initialChildSize: 0.35,
        maxChildSize: 0.5,
        expand: false,
        builder: buildSheet,
      ),
    );
  }

  Widget buildSheet(BuildContext context, _) {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Container(
                  height: 4,
                  width: 20,
                  decoration: ShapeDecoration(
                    color: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 12),
            Text(
              localizations.forgotPassword,
              style: Theme.of(context).textTheme.title,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InputField(
                labelText: localizations.emailAddress,
                icon: Icons.email,
                controller: controller,
                validator: (s) => validateEmail(context, s),
                onFieldSubmitted: (email) => submitEmail(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: RaisedButton(
                shape: AppBorder,
                color: widget.color.color,
                textColor: AppTextColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(localizations.resetPassword),
                ),
                onPressed: () => submitEmail(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  submitEmail(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final onFailed = (error) => showToast(
          context,
          title: localizations.failedToRequestNewPassword,
          message: error,
        );

    if (_formKey.currentState.validate()) {
      Navigator.of(context).pop();

      if (forgotPassword(context, controller.text, onFailed))
        showToast(context, title: localizations.passwordResetEmailSent);
      else
        onFailed(null);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
