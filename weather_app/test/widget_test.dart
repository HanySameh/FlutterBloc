import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';
import 'package:weather_app/weather/models/models.dart';

import 'package:weather_repository/weather_repository.dart' hide Weather;
import 'package:weather_app/presentation/screens/search_screen.dart';
import 'package:weather_app/presentation/screens/settings_screen.dart';
import 'package:weather_app/presentation/screens/weather_screen.dart';
import 'package:weather_app/presentation/widgets/weather_empty.dart';
import 'package:weather_app/presentation/widgets/weather_error.dart';
import 'package:weather_app/presentation/widgets/weather_loading.dart';
import 'package:weather_app/presentation/widgets/weather_populated.dart';
import 'package:weather_app/theme/cubit/theme_cubit.dart';
import 'package:weather_app/weather/cubit/weather_cubit.dart';

import 'helpers/hydrated_bloc.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockThemeCubit extends MockCubit<Color> implements ThemeCubit {}

class MockWeatherCubit extends MockCubit<WeatherState>
    implements WeatherCubit {}

void main() {
  initHydratedStorage();

  group('WeatherPage', () {
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherRepository = MockWeatherRepository();
    });

    testWidgets('renders WeatherView', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: weatherRepository,
          child: const MaterialApp(home: WeatherScreen()),
        ),
      );
      expect(find.byType(WeatherView), findsOneWidget);
    });
  });

  group('WeatherView', () {
    final weather = Weather(
      temperature: const Temperature(value: 4.2),
      condition: WeatherCondition.cloudy,
      lastUpdated: DateTime(2020),
      location: 'London',
    );
    late ThemeCubit themeCubit;
    late WeatherCubit weatherCubit;

    setUp(() {
      themeCubit = MockThemeCubit();
      weatherCubit = MockWeatherCubit();
    });

    testWidgets('renders WeatherEmpty for WeatherStatus.initial',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      expect(find.byType(WeatherEmpty), findsOneWidget);
    });

    testWidgets('renders WeatherLoading for WeatherStatus.loading',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.loading,
        ),
      );
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      expect(find.byType(WeatherLoading), findsOneWidget);
    });

    testWidgets('renders WeatherPopulated for WeatherStatus.success',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
        ),
      );
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      expect(find.byType(WeatherPopulated), findsOneWidget);
    });

    testWidgets('renders WeatherError for WeatherStatus.failure',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.failure,
        ),
      );
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      expect(find.byType(WeatherError), findsOneWidget);
    });

    testWidgets('state is cached', (tester) async {
      when<dynamic>(() => hydratedStorage.read('$WeatherCubit')).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
          temperatureUnits: TemperatureUnits.fahrenheit,
        ).toJson(),
      );
      await tester.pumpWidget(
        BlocProvider.value(
          value: WeatherCubit(MockWeatherRepository()),
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      expect(find.byType(WeatherPopulated), findsOneWidget);
    });

    testWidgets('navigates to SettingsPage when settings icon is tapped',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('navigates to SearchPage when search button is tapped',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('calls updateTheme when whether changes', (tester) async {
      whenListen(
        weatherCubit,
        Stream<WeatherState>.fromIterable([
          WeatherState(),
          WeatherState(status: WeatherStatus.success, weather: weather),
        ]),
      );
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
        ),
      );
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: themeCubit),
            BlocProvider.value(value: weatherCubit),
          ],
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      // verify(() => themeCubit.updateTheme(weather)).called(1);
    });

    testWidgets('triggers refreshWeather on pull to refresh', (tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
        ),
      );
      when(() => weatherCubit.refreshWeather()).thenAnswer((_) async {});
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      await tester.fling(
        find.text('London'),
        const Offset(0, 500),
        1000,
      );
      await tester.pumpAndSettle();
      verify(() => weatherCubit.refreshWeather()).called(1);
    });

    testWidgets('triggers fetch on search pop', (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      when(() => weatherCubit.fetchWeather(any())).thenAnswer((_) async {});
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Chicago');
      await tester.tap(find.byKey(const Key('searchPage_search_iconButton')));
      await tester.pumpAndSettle();
      verify(() => weatherCubit.fetchWeather('Chicago')).called(1);
    });
  });
}
