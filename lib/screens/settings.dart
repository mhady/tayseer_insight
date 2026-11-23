import 'package:flutter/material.dart';
import 'package:tayseer_insight/widgets/app_button.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  // Same behaviour as before (replace this screen with the target), but done
  // in one step instead of pop() followed by pushNamed().
  void _open(String route) => Navigator.of(context).pushReplacementNamed(route);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الإعدادات',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: AppButtonWrap(
          maxColumns: 2,
          spacing: 8,
          children: [
            AppButton(
              label: 'تغيير القارئ',
              fontSize: 27,
              autofocus: true,
              onPressed: () => _open('qare2Settings'),
            ),
            AppButton(
              label: 'تغيير التفسير',
              fontSize: 27,
              onPressed: () => _open('tafseerSettings'),
            ),
            AppButton(
              label: 'ضبط الشواهد',
              fontSize: 27,
              onPressed: () => _open('shwahedSettings'),
            ),
          ],
        ),
      ),
    );
  }
}
