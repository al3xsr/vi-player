import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vi/provider/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool themeState = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      child: Scaffold(
        appBar: AppBar(title: Text("Settings")),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            spacing: 7,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Dark Theme"),
                  Switch(
                    value: themeProvider.isPlatformDark,
                    onChanged: (_) =>
                        context.read<ThemeProvider>().toggleTheme(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Show App Info"),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),
                              const Text("VI Player"),
                              const SizedBox(height: 8),
                              const Text("By Alezs"),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                    },
                    child: const Text("Show"),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
