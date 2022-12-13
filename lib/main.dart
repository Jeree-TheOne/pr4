import 'dart:async';

import 'package:cubitapp/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  ThemeMode currentMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: currentMode,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      title: 'Material App',
      home: Scaffold(
        body: BlocProvider(
          create: (context) => ThemeCubit(),
          child: BodyWidget(
            changeMode: (currentMode) => setState(() {
              this.currentMode = currentMode;
            }),
          ),
        ),
      ),
    );
  }
}

class BodyWidget extends StatefulWidget {
  BodyWidget({Key? key, required this.changeMode}) : super(key: key);
  void Function(ThemeMode currentMode) changeMode;

  @override
  State<BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  List<String> values = [];
  late Timer _timer;
  SharedPreferences? currentPrefs;
  int currentValue = 0;

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      currentPrefs = value;
      if (currentPrefs!.containsKey("count")) {
        setState(() {
          currentPrefs = value;
          values = value.getStringList("count")!;
          currentValue = value.getInt("value")!;
        });
      }
      if (currentPrefs!.containsKey('theme')) {
        context
            .read<ThemeCubit>()
            .changeTheme(ThemeMode.values[value.getInt('theme')!]);
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      context.read<ThemeCubit>().calculateTheme(
          Theme.of(context).brightness == Brightness.light
              ? ThemeMode.light
              : ThemeMode.dark,
          false);
    });
    super.initState();
  }

  Timer getTimer() => Timer.periodic(const Duration(seconds: 5), (timer) {
        context.read<ThemeCubit>().calculateTheme(
            Theme.of(context).brightness == Brightness.light
                ? ThemeMode.light
                : ThemeMode.dark,
            false);
      });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ThemeCubit, ThemeCubitState>(
      listener: (context, state) {
        if (state is ThemeValueAddedState) {
          setState(() {
            currentValue += state.currentValue;
            values.add(
                "Текущее значение: $currentValue, Тема: ${state.currentTheme.name}");
          });

          currentPrefs?.setStringList("count", values);
          currentPrefs?.setInt("value", currentValue);
        } else if (state is ThemeModeChangedState) {
          widget.changeMode(state.currentTheme);
          currentPrefs?.setInt("theme", state.currentTheme.index);
        }
      },
      child: Stack(
        children: [
          Expanded(
            child: ListView(
              clipBehavior: Clip.none,
              children: values.map((e) => Center(child: Text(e))).toList(),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: ColoredBox(
              color: const Color.fromARGB(136, 0, 29, 133),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              _timer.cancel();
                              _timer = getTimer();
                              context.read<ThemeCubit>().calculateTheme(
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? ThemeMode.light
                                      : ThemeMode.dark,
                                  false);
                            },
                            child: Text(
                              "+${context.read<ThemeCubit>().getThemeValue(
                                Theme.of(context).brightness ==
                                      Brightness.light
                                      ? ThemeMode.light
                                      : ThemeMode.dark)}",
                              textScaleFactor: 2,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold),
                            ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _timer.cancel();
                              _timer = getTimer();
                              context.read<ThemeCubit>().calculateTheme(
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? ThemeMode.light
                                      : ThemeMode.dark,
                                  true);
                            },
                            child: Text(
                              "-${context.read<ThemeCubit>().getThemeValue(
                                Theme.of(context).brightness ==
                                      Brightness.light
                                      ? ThemeMode.light
                                      : ThemeMode.dark)}",
                              textScaleFactor: 2,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currentValue.toString(),
                      textScaleFactor: 2, 
                      style: const TextStyle(
                          color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => context
                              .read<ThemeCubit>()
                              .changeTheme(Theme.of(context).brightness ==
                                      Brightness.light
                                  ? ThemeMode.dark
                                  : ThemeMode.light),
                          child: const Icon(Icons.swap_horiz_rounded),
                        ),
                        if (currentPrefs != null &&
                            currentPrefs!.containsKey("count"))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                currentPrefs!.clear();
                                setState(() {
                                  values.clear();
                                  currentValue = 0;
                                  _timer.cancel();
                                  _timer = getTimer();
                                });
                              },
                              child: const Icon(Icons.delete_outline_rounded),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
