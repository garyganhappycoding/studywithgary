import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'screens/home_screen.dart';
import 'screens/rewards_setup_screen.dart';
import 'models/user.dart';
import 'models/knowledge_card.dart';
import 'models/knowledge_folder.dart';
import 'models/study_session.dart';
import 'models/battle_session.dart';
import 'models/reward.dart';
import 'models/chest.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        title: 'Study Royale',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Wait for data to load, then check if first time
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && userProvider.isFirstTime && userProvider.isDataLoaded) {
          _showRewardsSetup();
        }
      });
    });
  }

  void _showRewardsSetup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RewardsSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Show loading screen while data is being loaded
    if (!userProvider.isDataLoaded) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Loading your data...'),
            ],
          ),
        ),
      );
    }

    return const HomeScreen();
  }
}

class UserProvider extends ChangeNotifier {
  late User _user;
  bool isFirstTime = true;
  final Random _random = Random();
  late SharedPreferences _prefs;
  bool _isLoaded = false;

  UserProvider() {
    _initializeUser();
    _loadDataFromStorage();
  }

  void _initializeUser() {
    _user = User(
      arenaPoints: 0,
      cards: [],
      folders: [],
      sessions: [],
      battleSessions: [],
      chests: [],
      rewards: [],
    );
  }

  // ==================== STORAGE METHODS ====================

  /// Load data from SharedPreferences when app starts
  Future<void> _loadDataFromStorage() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Load arena points
      _user.arenaPoints = _prefs.getInt('arenaPoints') ?? 0;

      // Load folders
      final foldersJson = _prefs.getStringList('folders') ?? [];
      _user.folders = foldersJson
          .map((f) => KnowledgeFolder.fromJson(jsonDecode(f)))
          .toList();

      // Load cards
      final cardsJson = _prefs.getStringList('cards') ?? [];
      _user.cards = cardsJson
          .map((c) => KnowledgeCard.fromJson(jsonDecode(c)))
          .toList();

      // Load study sessions
      final sessionsJson = _prefs.getStringList('sessions') ?? [];
      _user.sessions = sessionsJson
          .map((s) => StudySession.fromJson(jsonDecode(s)))
          .toList();

      // Load battle sessions
      final battlesJson = _prefs.getStringList('battleSessions') ?? [];
      _user.battleSessions = battlesJson
          .map((b) => BattleSession.fromJson(jsonDecode(b)))
          .toList();

      // Load chests
      final chestsJson = _prefs.getStringList('chests') ?? [];
      _user.chests = chestsJson
          .map((ch) => Chest.fromJson(jsonDecode(ch)))
          .toList();

      // Load rewards
      final rewardsJson = _prefs.getStringList('rewards') ?? [];
      _user.rewards = rewardsJson
          .map((r) => Reward.fromJson(jsonDecode(r)))
          .toList();

      // Load isFirstTime flag
      isFirstTime = _prefs.getBool('isFirstTime') ?? true;

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      print('Error loading data: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Save all data to SharedPreferences
  Future<void> _saveDataToStorage() async {
    try {
      await _prefs.setInt('arenaPoints', _user.arenaPoints);

      await _prefs.setStringList(
        'folders',
        _user.folders.map((f) => jsonEncode(f.toJson())).toList(),
      );

      await _prefs.setStringList(
        'cards',
        _user.cards.map((c) => jsonEncode(c.toJson())).toList(),
      );

      await _prefs.setStringList(
        'sessions',
        _user.sessions.map((s) => jsonEncode(s.toJson())).toList(),
      );

      await _prefs.setStringList(
        'battleSessions',
        _user.battleSessions.map((b) => jsonEncode(b.toJson())).toList(),
      );

      await _prefs.setStringList(
        'chests',
        _user.chests.map((ch) => jsonEncode(ch.toJson())).toList(),
      );

      await _prefs.setStringList(
        'rewards',
        _user.rewards.map((r) => jsonEncode(r.toJson())).toList(),
      );

      await _prefs.setBool('isFirstTime', isFirstTime);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  bool get isDataLoaded => _isLoaded;

  // ==================== GETTERS ====================
  User get user => _user;

  int get arenaPoints => _user.arenaPoints;

  List<KnowledgeFolder> get folders => _user.folders;

  List<KnowledgeCard> get allCards => _user.cards;

  int get totalCardsCollected => _user.cards.length;

  List<StudySession> get studySessions => _user.sessions;

  int get sessions => _user.sessions.length;

  List<BattleSession> get battleSessions => _user.battleSessions;

  List<Chest> get chests => _user.chests;

  int get unopenedChestCount => _user.chests.where((c) => !c.opened).length;

  int get totalChests => _user.chests.length;

  List<Reward> get rewards => _user.rewards;

  int get totalBattlesWon {
    return _user.battleSessions.where((b) => b.isVictory).length;
  }

  int get totalBattles => _user.battleSessions.length;

  // ==================== ARENA & POINTS ====================
  int get currentArena {
    if (_user.arenaPoints < 100) return 1;
    if (_user.arenaPoints < 300) return 2;
    if (_user.arenaPoints < 600) return 3;
    if (_user.arenaPoints < 1000) return 4;
    return 5;
  }

  double get progressToNextArena {
    final currentArenaPoints = _getCurrentArenaPoints();
    final pointsNeeded = _getPointsNeededForArena();
    return currentArenaPoints / pointsNeeded;
  }

  int _getCurrentArenaPoints() {
    final arena = currentArena;
    if (arena == 1) return _user.arenaPoints;
    if (arena == 2) return _user.arenaPoints - 100;
    if (arena == 3) return _user.arenaPoints - 300;
    if (arena == 4) return _user.arenaPoints - 600;
    return _user.arenaPoints - 1000;
  }

  int _getPointsNeededForArena() {
    final arena = currentArena;
    if (arena == 1) return 100;
    if (arena == 2) return 200;
    if (arena == 3) return 300;
    if (arena == 4) return 400;
    return 500;
  }

  void addArenaPoints(int points) {
    _user.arenaPoints += points;
    _saveDataToStorage();
    notifyListeners();
  }

  // ==================== KNOWLEDGE CARDS ====================
  void addFolder(String name, String description) {
    final folder = KnowledgeFolder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
    );
    _user.folders.add(folder);
    _saveDataToStorage();
    notifyListeners();
  }

  void deleteFolder(String folderId) {
    _user.folders.removeWhere((f) => f.id == folderId);
    _user.cards.removeWhere((c) => c.folderId == folderId);
    _saveDataToStorage();
    notifyListeners();
  }

  void toggleFolderExpanded(String folderId) {
    final folder = _user.folders.firstWhere((f) => f.id == folderId);
    folder.isExpanded = !folder.isExpanded;
    _saveDataToStorage();
    notifyListeners();
  }

  void addCard(KnowledgeCard card) {
    _user.cards.add(card);
    _saveDataToStorage();
    notifyListeners();
  }

  void updateCard(KnowledgeCard updatedCard) {
    final index = _user.cards.indexWhere((c) => c.id == updatedCard.id);
    if (index != -1) {
      _user.cards[index] = updatedCard;
      _saveDataToStorage();
      notifyListeners();
    }
  }

  void deleteCard(String cardId) {
    _user.cards.removeWhere((c) => c.id == cardId);
    _saveDataToStorage();
    notifyListeners();
  }

  void levelUpCard(String cardId) {
    final card = _user.cards.firstWhere((c) => c.id == cardId);
    if (card.level < 3) {
      card.level++;
      _saveDataToStorage();
      notifyListeners();
    }
  }

  List<KnowledgeCard> getCardsInFolder(String folderId) {
    return _user.cards.where((c) => c.folderId == folderId).toList();
  }

  // ==================== STUDY SESSIONS ====================
  void addStudySession(StudySession session) {
    _user.sessions.add(session);
    _saveDataToStorage();
    notifyListeners();
  }

  int getTotalStudyTime() {
    return _user.sessions
        .fold(0, (sum, session) => sum + session.durationMinutes);
  }

  // ==================== BATTLE SESSIONS ====================
  void addBattleSession(BattleSession session) {
    _user.battleSessions.add(session);
    addArenaPoints(session.pointsAwarded);
    _saveDataToStorage();
    notifyListeners();
  }

  void updateBattleSession(BattleSession updatedSession) {
    final index =
    _user.battleSessions.indexWhere((b) => b.id == updatedSession.id);
    if (index != -1) {
      _user.battleSessions[index] = updatedSession;
      _saveDataToStorage();
      notifyListeners();
    }
  }

  // ==================== CHESTS ====================
  Map<String, dynamic> getRandomRewardAndType(RewardType preferredType) {
    List<Reward> availableRewards = _user.rewards
        .where((r) => r.type == preferredType && !r.claimed)
        .toList();

    if (availableRewards.isEmpty && preferredType != RewardType.common) {
      availableRewards = _user.rewards
          .where((r) => r.type == RewardType.common && !r.claimed)
          .toList();
    }

    if (availableRewards.isEmpty) {
      return {
        'reward': "No Reward Available: Keep adding rewards!",
        'type': RewardType.common,
      };
    }

    final int randomIndex = _random.nextInt(availableRewards.length);
    final Reward selectedReward = availableRewards[randomIndex];

    return {
      'reward':
      '${selectedReward.title}: ${selectedReward.description.isNotEmpty ? selectedReward.description : "A mystery reward!"}',
      'type': selectedReward.type,
    };
  }

  void addChest(String reward, RewardType rewardType) {
    final chest = Chest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reward: reward,
      rewardType: rewardType,
      opened: false,
    );
    _user.chests.add(chest);
    _saveDataToStorage();
    notifyListeners();
  }

  void openChest(String chestId) {
    try {
      final chest = _user.chests.firstWhere((c) => c.id == chestId);
      chest.opened = true;
      chest.openedAt = DateTime.now();
      _saveDataToStorage();
      notifyListeners();
    } catch (e) {
      print('Chest not found: $chestId');
    }
  }

  // ==================== REWARDS ====================
  void addReward(Reward reward) {
    _user.rewards.add(reward);
    isFirstTime = false;
    _saveDataToStorage();
    notifyListeners();
  }

  void deleteReward(String rewardId) {
    _user.rewards.removeWhere((r) => r.id == rewardId);
    _saveDataToStorage();
    notifyListeners();
  }

  void claimReward(String rewardId) {
    try {
      final reward = _user.rewards.firstWhere((r) => r.id == rewardId);
      reward.claimed = true;
      _saveDataToStorage();
      notifyListeners();
    } catch (e) {
      print('Reward not found: $rewardId');
    }
  }

  void unclaimReward(String rewardId) {
    try {
      final reward = _user.rewards.firstWhere((r) => r.id == rewardId);
      reward.claimed = false;
      _saveDataToStorage();
      notifyListeners();
    } catch (e) {
      print('Reward not found: $rewardId');
    }
  }

  int getRewardsByType(RewardType type) {
    return _user.rewards.where((r) => r.type == type).length;
  }

  int getClaimedRewardsByType(RewardType type) {
    return _user.rewards.where((r) => r.type == type && r.claimed).length;
  }

  // ==================== USER DATA ====================
  Map<String, dynamic> getUserStats() {
    return {
      'arenaPoints': _user.arenaPoints,
      'currentArena': currentArena,
      'totalCards': _user.cards.length,
      'totalSessions': _user.sessions.length,
      'totalBattles': _user.battleSessions.length,
      'battlesWon': totalBattlesWon,
      'totalChests': _user.chests.length,
      'unopenedChests': unopenedChestCount,
    };
  }
}
