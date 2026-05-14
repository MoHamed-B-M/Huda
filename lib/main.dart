import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/surah_list_view.dart';
import 'views/audio_player_view.dart';
import 'providers/audio_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: QuranApp(),
    ),
  );
}

/// Main Quran App with Material 3 design
class QuranApp extends ConsumerWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Material 3 color scheme from seed color
    const seedColor = Color(0xFF1F7A5E); // Islamic green
    
    return MaterialApp(
      title: 'Quran Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
          dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
        ),
        typography: Typography.material2021(
          platform: TargetPlatform.android,
        ),
        textTheme: GoogleFonts.amiriTextTheme(
          ThemeData.light().textTheme,
        ),
        // Material 3 AppBar styling
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor:
              ColorScheme.fromSeed(seedColor: seedColor)
                  .surface,
          foregroundColor:
              ColorScheme.fromSeed(seedColor: seedColor)
                  .onSurface,
        ),
        // Material 3 Card styling with outline variant
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // Rounded buttons with Material 3
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        // Navigation bar styling
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            GoogleFonts.amiri(fontSize: 12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
        ),
        textTheme: GoogleFonts.amiriTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const QuranHomePage(),
    );
  }
}

/// Home page with bottom navigation
class QuranHomePage extends ConsumerStatefulWidget {
  const QuranHomePage({super.key});

  @override
  ConsumerState<QuranHomePage> createState() => _QuranHomePageState();
}

class _QuranHomePageState extends ConsumerState<QuranHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMiniPlayerExpanded =
        ref.watch(isMiniPlayerExpandedProvider);
    final audioState = ref.watch(audioPlayerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          IndexedStack(
            index: _selectedIndex,
            children: const [
              SurahListView(),
              _BookmarksView(),
              _SettingsView(),
            ],
          ),
          // Full audio player overlay
          if (isMiniPlayerExpanded)
            const FullAudioPlayer(),
        ],
      ),
      // Bottom navigation
      bottomNavigationBar: Stack(
        children: [
          // Mini player
          if (audioState.currentReciterId != null &&
              !isMiniPlayerExpanded)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: MiniPlayer(
                onExpand: () {
                  ref
                      .read(isMiniPlayerExpandedProvider
                          .notifier)
                      .state = true;
                },
              ),
            ),
          // Navigation bar
          NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
              ref
                  .read(
                    isMiniPlayerExpandedProvider
                        .notifier,
                  )
                  .state = false;
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.book),
                label: 'Read',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark),
                label: 'Bookmarks',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bookmarks view placeholder
class _BookmarksView extends StatelessWidget {
  const _BookmarksView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks',
          style: GoogleFonts.amiri(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No bookmarks yet',
              style:
                  Theme.of(context)
                      .textTheme
                      .bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings view placeholder
class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.amiri(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Display'),
            subtitle: const Text('Font size, theme'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Audio'),
            subtitle: const Text('Reciters, playback'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Downloads'),
            subtitle: const Text('Manage offline content'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('About'),
            subtitle: const Text('App information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
