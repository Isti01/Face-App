import 'package:face_app/bloc/data_classes/app_color.dart';
import 'package:face_app/bloc/data_classes/gender.dart';
import 'package:face_app/bloc/data_classes/interest.dart';
import 'package:face_app/bloc/register_bloc/register_bloc_states.dart';
import 'package:face_app/login/register_form/pages/form_page.dart';
import 'package:face_app/util/app_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final dateFormat = DateFormat("yyyy. MM. dd.");

final faceDetector = FirebaseVision.instance.faceDetector(
  FaceDetectorOptions(mode: FaceDetectorMode.accurate),
);

class SummaryPage extends StatefulWidget {
  final FirebaseUser user;
  final RegisterState state;
  final Function(List<Face> faces) onRegistrationFinished;
  final Function(List<Face> faces) onFacesDetected;

  const SummaryPage({
    Key key,
    this.state,
    this.user,
    @required this.onRegistrationFinished,
    this.onFacesDetected,
  }) : super(key: key);

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool loading = false;

  String get _name => widget.state.name != null && widget.state.name.isNotEmpty
      ? "${widget.state.name} a nevem. 👋\n\n"
      : "";

  String get _birthDate => widget.state.birthDate != null
      ? "${dateFormat.format(widget.state.birthDate)} a születési dátumom.👶\n\n"
      : "";

  String get _attractedTo =>
      writeList(widget.state.attractedTo, "Vonzódsz utána: ");

  String get _interests =>
      writeList(widget.state.interests.toList(), "Érdekel: ");

  String get _description =>
      widget.state.description != null && widget.state.description.isNotEmpty
          ? 'Néhány szó magamról: ${widget.state.description}'
          : "";

  String writeList(List list, String title) {
    if (list == null || list.isEmpty) return '';
    final buffer = StringBuffer(title);
    list.forEach(
      (val) {
        var text = '';
        if (val is Gender)
          text = val.text;
        else if (val is Interest) text = val.text;
        buffer..write('  ')..write(text);
      },
    );
    buffer.write('\n\n');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.state.color.color[800];
    final buttonTextStyle =
        Theme.of(context).textTheme.button.copyWith(color: color);

    final indicatorColor = AlwaysStoppedAnimation(color);
    return FormPage(
      title: "Helyes így a bemutatkozásod?",
      description: "Ezeken később változtathatsz",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          "$_name$_attractedTo$_birthDate$_interests$_description",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subhead,
        ),
      ),
      footer: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RaisedButton(
          color: Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      valueColor: indicatorColor,
                    ),
                  ),
                ),
              Text(
                "Kész a bemutatkozás!",
                style: buttonTextStyle,
              ),
            ],
          ),
          onPressed: loading ? () {} : onPressed,
        ),
      ),
    );
  }

  onPressed() async {
    print(widget.state);
    this.setState(() => loading = true);
    try {
      if (!widget.state.validate()) {
        showToast(
          context,
          title: "A regisztrációhoz tölts ki helyesen minden mezőt!",
        );
        this.setState(() => loading = false);
        return;
      }

      final faces = await faceDetector.processImage(
        FirebaseVisionImage.fromFilePath(widget.state.facePhoto),
      );

      if (faces.isEmpty) {
        showToast(
          context,
          title: "A megadott képen nem található arc!",
          message: "Adj meg egy olyan képet, amin rajta vagy!",
        );
        this.setState(() => loading = false);
        return;
      }

      widget.onFacesDetected(faces);
      widget.onRegistrationFinished(faces);
    } catch (e, s) {
      print([e, s]);
      this.setState(() => loading = false);
    }
  }
}
