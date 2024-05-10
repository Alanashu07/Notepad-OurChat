import 'package:flutter/material.dart';

class AppStyle{
  static Color bgColor = const Color(0xFFe2e2ee);
  static Color mainColor = const Color(0xFF000633);
  static Color accentColor = const Color(0xFF0065FF);

  static List<Color> cardsColor = [
    Colors.white,
    Colors.red.shade100,
    Colors.pink.shade100,
    Colors.orange.shade100,
    Colors.yellow.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.deepOrange.shade100
  ];
}


ThemeData lightTheme(BuildContext context) => ThemeData.light().copyWith(
  primaryColor: const Color(0xFF000633),
  scaffoldBackgroundColor: Colors.white,
  tabBarTheme: TabBarTheme(
    indicatorSize: TabBarIndicatorSize.label,
    unselectedLabelColor: Colors.black54,
    labelColor: Colors.white,
    indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(50), color: const Color(0xFF000633)
    )),
  appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF000633)),
  iconTheme: const IconThemeData(color: Colors.white),
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
);

ThemeData darkTheme(BuildContext context) => ThemeData.dark().copyWith(
  primaryColor: Colors.red,
  scaffoldBackgroundColor: Colors.black,
  tabBarTheme: TabBarTheme(
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(50), color: Colors.red
      )
  ),
  appBarTheme: const AppBarTheme(backgroundColor: Colors.red),
  iconTheme: IconThemeData(color: Colors.white),
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
);
bool isLightTheme(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light;
}

class LightMode{
  static Color bgColor = const Color(0xFFe2e2ee);
  static Color mainColor = const Color(0xFF000633);
  static Color accentColor = const Color(0xFF0065FF);
}

class DarkMode{
  static Color bgColor = Colors.black;
  static Color mainColor = Colors.red;
  static Color accentColor = Colors.redAccent;
}