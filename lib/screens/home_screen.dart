import 'package:flutter/material.dart';
import 'package:vi/screens/favorites_screen.dart';
import 'package:vi/screens/settings_screen.dart';
import 'package:vi/widgets/track_list.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _currentIndex = 0; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    
      body: _currentIndex == 0
          ? const _MusicSection() 
          :  SettingsScreen(), 

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),

    );
  }
}

class _MusicSection extends StatelessWidget {
  const _MusicSection();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vi Player'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.my_library_music), text: 'Tracks'),
              Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TrackList(),
            FavoritesScreen(),
          ],
        ),
      ),
    );
  }
}