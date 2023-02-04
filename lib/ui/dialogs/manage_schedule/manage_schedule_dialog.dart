import 'package:bingnuos_admin_panel/constants.dart';
import 'package:bingnuos_admin_panel/models/schedule/subject.dart';
import 'package:bingnuos_admin_panel/models/schedule/subject_info.dart';
import 'package:bingnuos_admin_panel/services/firebase/firestore_service.dart';
import 'package:bingnuos_admin_panel/services/snackbar_service.dart';
import 'package:bingnuos_admin_panel/ui/components/app_text_field.dart';
import 'package:bingnuos_admin_panel/ui/components/buttons/app_elevated_button.dart';
import 'package:bingnuos_admin_panel/ui/components/buttons/app_text_button.dart';
import 'package:bingnuos_admin_panel/utils/app_locale.dart';
import 'package:bingnuos_admin_panel/utils/utils.dart';
import 'package:flutter/material.dart';

class ManageScheduleDialog extends StatefulWidget {
  final int number;
  final String group;
  final WeekDay weekDay;
  final Subject? subject;

  const ManageScheduleDialog({
    Key? key,
    required this.group,
    required this.weekDay,
    required this.number,
    this.subject,
  }) : super(key: key);

  @override
  State<ManageScheduleDialog> createState() => _ManageScheduleDialogState();
}

class _ManageScheduleDialogState extends State<ManageScheduleDialog> {
  String get group => widget.group;
  WeekDay get weekDay => widget.weekDay;
  int get number => widget.number;
  Subject? get subject => widget.subject;

  final nameTextFieldController = TextEditingController();
  final teacherTextFieldController = TextEditingController();
  final cabinetTextFieldController = TextEditingController();

  final isNameError = ValueNotifier(false);
  final isTeacherError = ValueNotifier(false);
  final isCabinetError = ValueNotifier(false);
  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    if (subject != null) {
      nameTextFieldController.text = subject?.subject?.name ?? "";
      teacherTextFieldController.text = subject?.subject?.teacher ?? "";
      cabinetTextFieldController.text = subject?.subject?.cabinet ?? "";
    }
    super.initState();
  }

  Future<void> _remove() async {
    isLoading.value = true;

    final fieldScheduleInfo = readFields();
    if (fieldScheduleInfo == null) {
      isLoading.value = false;
      return;
    }

    bool success = await FirestoreService.removeSchedule(
      group: group,
      weekDay: weekDay,
      subjectInfo: fieldScheduleInfo,
    );

    showMessageAndPop(success);
    isLoading.value = false;
  }

  Future<void> _add() async {
    isLoading.value = true;

    final fieldSubjectInfo = readFields();
    if (fieldSubjectInfo == null) {
      isLoading.value = false;
      return;
    }

    bool success = subject != null
        ? await FirestoreService.updateSchedule(
            fieldSubjectInfo: fieldSubjectInfo,
            subjectInfo: subject!.subject!,
            group: group,
            weekDay: weekDay,
          )
        : await FirestoreService.addSchedule(
            group: group,
            weekDay: weekDay,
            subjectInfo: fieldSubjectInfo,
          );

    showMessageAndPop(success);
    isLoading.value = false;
  }

  void showMessageAndPop(bool success) {
    final appLocale = AppLocale.of(context);
    String message;

    if (success) {
      message = appLocale.success;
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      message = appLocale.somethingWentWrong;
    }

    if (mounted) {
      SnackBarService(context).show(message);
    }
  }

  SubjectInfo? readFields() {
    String name = nameTextFieldController.value.text;
    String cabinet = cabinetTextFieldController.value.text;
    String teacher = teacherTextFieldController.value.text;

    if (!validate(name, cabinet, teacher)) return null;
    FocusScope.of(context).unfocus();
    isLoading.value = true;

    return SubjectInfo(
      name: name,
      cabinet: cabinet,
      teacher: teacher,
    );
  }

  bool validate(String name, String cabinet, String teacher) {
    if (name.length < 3) {
      isNameError.value = true;
      return false;
    } else {
      isNameError.value = false;
    }
    if (cabinet.length < 3) {
      isCabinetError.value = true;
      return false;
    } else {
      isCabinetError.value = false;
    }
    if (teacher.length < 3) {
      isTeacherError.value = true;
      return false;
    } else {
      isTeacherError.value = false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.of(context);

    String subjectName = Utils.nameFromWeekDay(locale, weekDay);
    String title = '$group $subjectName ${number + 1} ${locale.subject}';

    return Dialog(
      insetPadding: const EdgeInsets.only(top: 20, left: 15, right: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 5,
      child: Container(
        padding:
            const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
        width: 600,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.manageSchedule,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              ValueListenableBuilder(
                valueListenable: isNameError,
                builder: (context, value, child) => AppTextField(
                  controller: nameTextFieldController,
                  hintText: locale.subjectHint,
                  errorText: locale.subjectNameWrong,
                  showError: value,
                ),
              ),
              const SizedBox(height: 15),
              ValueListenableBuilder(
                valueListenable: isCabinetError,
                builder: (context, value, child) => AppTextField(
                  controller: cabinetTextFieldController,
                  hintText: locale.cabinetNumberHint,
                  errorText: locale.cabinetNumberWrong,
                  showError: value,
                ),
              ),
              const SizedBox(height: 15),
              ValueListenableBuilder(
                valueListenable: isTeacherError,
                builder: (context, value, child) => AppTextField(
                  controller: teacherTextFieldController,
                  hintText: locale.teacherNameHint,
                  errorText: locale.teacherNameWrong,
                  showError: value,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.only(top: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppTextButton(
                      title: locale.cancel,
                      onPressed: () => Navigator.pop(context),
                    ),
                    if (widget.subject != null) ...[
                      const SizedBox(width: 20),
                      ValueListenableBuilder(
                        valueListenable: isLoading,
                        builder: (context, value, child) => AppElevatedButton(
                          title: locale.remove,
                          width: 120,
                          isDisabled: value,
                          onPressed: _remove,
                        ),
                      ),
                    ],
                    const SizedBox(width: 20),
                    ValueListenableBuilder(
                      valueListenable: isLoading,
                      builder: (context, value, child) => AppElevatedButton(
                        title: locale.add,
                        width: 120,
                        isDisabled: value,
                        onPressed: _add,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
