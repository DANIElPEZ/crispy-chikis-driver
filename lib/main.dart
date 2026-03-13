import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crispychikisdriver/provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crispychikisdriver/components/appbar.dart';
import 'package:crispychikisdriver/views/home.dart';
import 'package:crispychikisdriver/theme/color/colors.dart';

Future<void> main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
      url: dotenv.env['API_URL'] ?? '', anonKey: dotenv.env['API_KEY'] ?? '');
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(ChangeNotifierProvider(create: (context)=>crispyDriverProvider(),
    child: Main()));
  });
}

class Main extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight),
              child: CustomAppBar(
                  bg_color: colorsPalete['dark blue']!,
                  shape_color: colorsPalete['orange']!)),
          body: HomeView()
        )
      ),
    );
  }
}