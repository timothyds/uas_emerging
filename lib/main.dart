import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_project/screen/adopt.dart';
import 'package:uas_project/screen/browse.dart';
import 'package:uas_project/screen/login.dart';
import 'package:uas_project/screen/offer.dart';
import 'package:uas_project/screen/registration.dart';

String active_user = "";
String _userName = "";
void doLogout() async {
  final prefs = await SharedPreferences.getInstance();
  active_user = "";
  prefs.remove("user_id");
  prefs.remove("user_name");
  prefs.remove("user_password");

  main();
}


Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String user_id = prefs.getString("user_id") ?? '';
  return user_id;
}

void main() {
  //runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) {
    if (result == '') {
      runApp(MyLogin());
    } else {
      active_user = result;
      runApp(MyApp());
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'browse':(context)=> BrowseScreen(),
        'offer':(context)=> OfferScreen(),
        'adopt':(context)=> AdoptScreen(),
        'login':(context)=>MyLogin(),
        'register':(context)=>RegisterScreen()
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// class MyLoginApp extends StatelessWidget {
//   const MyLoginApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Adopsian',),
//     );
//   }
// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }
  _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString("user_name") ?? "Guest";
    });
  }

  final List<Widget> _screens = [HomeScreen(), BrowseScreen(), OfferScreen(), AdoptScreen()];
  final List<String> _judul = ['Home', 'Browse', 'Offer', 'Adopt'];

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_judul[_currentIndex]),
      ),
      body:_screens[_currentIndex],
      drawer: methodDrawer(),
      bottomNavigationBar: methodBottomNavBar(),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
    return scaffold;
  }

  BottomNavigationBar methodBottomNavBar() {
    return BottomNavigationBar(
        currentIndex: _currentIndex,
        unselectedItemColor: Colors.grey,
        fixedColor: Colors.teal,
        items: [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "Browse",
            icon: Icon(
              Icons.search,
              size: 40,
            ),
          ),
          BottomNavigationBarItem(
            label: "Offer",
            icon: Icon(
              Icons.local_offer,
              size: 40,
            ),
          ),
          BottomNavigationBarItem(
            label: "Adopt",
            icon: Icon(
              Icons.pets,
              size: 40,
            ),
          )
        ],
        onTap: (int index) {
          setState(() {
            _currentIndex=index;
          });
        });
  }

  Drawer methodDrawer() {
    return Drawer(
      elevation: 16.0,
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(_userName),
            accountEmail: Text(active_user),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/150")
            ),
          ),
          Divider(height: 20.0),
          ListTile(
            title: Text(active_user != "" ? "Logout" : "Login"),
            leading: Icon(Icons.login),
            onTap: () {
              active_user != "" ? doLogout() : Navigator.popAndPushNamed(context, 'login');
            },
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Pet Adoption App',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'This app helps you to browse, offer, and adopt pets easily. '
            'You can explore different pets available for adoption, propose to adopt a pet, '
            'and even offer pets that you want to find a new home for. '
            'Start by navigating through the tabs below.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
