// ============================================================
// ÉCRAN SOCIAL - Amis, recherche, invitations
// ============================================================

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/friend_service.dart';
import '../services/online_game_service.dart';
import '../utils/fantasy_theme.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _friendRequests = [];
  bool _isSearching = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final friends = await FriendService.getFriends();
    final requests = await FriendService.getFriendRequests();
    if (mounted) {
      setState(() {
        _friends = friends;
        _friendRequests = requests;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FantasyTheme.bgDark,
      appBar: AppBar(
        backgroundColor: FantasyTheme.bgMedium,
        title: Text('Mes amis', style: FantasyTheme.titleStyle.copyWith(fontSize: 20)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: FantasyTheme.purple,
          labelColor: FantasyTheme.purpleLight,
          unselectedLabelColor: FantasyTheme.silver,
          tabs: [
            Tab(text: 'Amis (${_friends.length})'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Demandes'),
                  if (_friendRequests.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: FantasyTheme.red,
                      ),
                      child: Center(
                        child: Text(
                          '${_friendRequests.length}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Rechercher'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: FantasyTheme.purple))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsList(),
                _buildRequestsList(),
                _buildSearchTab(),
              ],
            ),
    );
  }

  // ---- LISTE AMIS ----
  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return _buildEmptyState(
        '♟',
        'Pas encore d\'amis',
        'Recherche des joueurs dans l\'onglet "Rechercher"',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _friends.length,
        itemBuilder: (_, i) => _buildFriendTile(_friends[i]),
      ),
    );
  }

  Widget _buildFriendTile(Map<String, dynamic> friend) {
    final isOnline = friend['is_online'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: FantasyTheme.cardDecoration(
        borderColor: isOnline
            ? FantasyTheme.emerald.withValues(alpha: 0.4)
            : FantasyTheme.purple.withValues(alpha: 0.3),
      ),
      child: ListTile(
        leading: _buildAvatar(friend['avatar'] ?? '♙', isOnline),
        title: Text(
          friend['username'] ?? 'Joueur',
          style: TextStyle(
              color: FantasyTheme.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isOnline ? '🟢 En ligne' : '⚫ Hors ligne',
          style: TextStyle(
            color: isOnline ? FantasyTheme.emerald : FantasyTheme.silver,
            fontSize: 12,
          ),
        ),
        trailing: isOnline
            ? GestureDetector(
                onTap: () => _inviteToPlay(friend),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: FantasyTheme.purpleGradient,
                  ),
                  child: Text(
                    '⚔ Jouer',
                    style: TextStyle(
                        color: FantasyTheme.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  // ---- DEMANDES ----
  Widget _buildRequestsList() {
    if (_friendRequests.isEmpty) {
      return _buildEmptyState('📬', 'Aucune demande', 'Pas de nouvelles demandes d\'ami');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _friendRequests.length,
      itemBuilder: (_, i) => _buildRequestTile(_friendRequests[i]),
    );
  }

  Widget _buildRequestTile(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: FantasyTheme.cardDecoration(
        borderColor: FantasyTheme.gold.withValues(alpha: 0.4),
      ),
      child: ListTile(
        leading: _buildAvatar(user['avatar'] ?? '♙', false),
        title: Text(
          user['username'] ?? 'Joueur',
          style: TextStyle(color: FantasyTheme.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Veut être votre ami',
          style: TextStyle(color: FantasyTheme.gold, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _acceptRequest(user['uid']),
              icon: Icon(Icons.check_circle, color: FantasyTheme.emerald),
              tooltip: 'Accepter',
            ),
            IconButton(
              onPressed: () => _declineRequest(user['uid']),
              icon: Icon(Icons.cancel, color: FantasyTheme.red),
              tooltip: 'Refuser',
            ),
          ],
        ),
      ),
    );
  }

  // ---- RECHERCHE ----
  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: FantasyTheme.bgMedium,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: FantasyTheme.purple.withValues(alpha: 0.4)),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(color: FantasyTheme.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un pseudo...',
                hintStyle: TextStyle(
                    color: FantasyTheme.silver.withValues(alpha: 0.5)),
                prefixIcon:
                    Icon(Icons.search, color: FantasyTheme.purple, size: 22),
                suffixIcon: _isSearching
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: FantasyTheme.purple,
                          ),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(height: 16),
          // Résultats
          Expanded(
            child: _searchResults.isEmpty
                ? _buildEmptyState('🔍', 'Recherche un joueur',
                    'Tape un pseudo pour trouver des joueurs')
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (_, i) =>
                        _buildSearchResultTile(_searchResults[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultTile(Map<String, dynamic> user) {
    final myFriendIds = _friends.map((f) => f['uid'] as String).toList();
    final isFriend = myFriendIds.contains(user['uid']);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: FantasyTheme.cardDecoration(),
      child: ListTile(
        leading: _buildAvatar(user['avatar'] ?? '♙', false),
        title: Text(
          user['username'] ?? 'Joueur',
          style: TextStyle(
              color: FantasyTheme.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${user['wins'] ?? 0}V · ${user['losses'] ?? 0}D',
          style: TextStyle(color: FantasyTheme.silver, fontSize: 12),
        ),
        trailing: isFriend
            ? Text('✓ Ami',
                style: TextStyle(
                    color: FantasyTheme.emerald, fontSize: 12))
            : GestureDetector(
                onTap: () => _sendFriendRequest(user['uid']),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: FantasyTheme.purple.withValues(alpha: 0.6)),
                    color: FantasyTheme.purple.withValues(alpha: 0.2),
                  ),
                  child: Text(
                    '+ Ajouter',
                    style: TextStyle(
                        color: FantasyTheme.purpleLight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAvatar(String symbol, bool isOnline) {
    return Stack(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: FantasyTheme.purpleGradient,
          ),
          child: Center(
            child: Text(symbol, style: const TextStyle(fontSize: 20)),
          ),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FantasyTheme.emerald,
                border: Border.all(
                    color: FantasyTheme.bgDark, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(String icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(title,
              style: TextStyle(
                  color: FantasyTheme.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(
                  color: FantasyTheme.silver, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ---- ACTIONS ----
  Future<void> _onSearchChanged(String value) async {
    if (value.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await AuthService.searchUsers(value);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _sendFriendRequest(String uid) async {
    final error = await FriendService.sendFriendRequest(uid);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Demande envoyée !'),
        backgroundColor:
            error != null ? FantasyTheme.red : FantasyTheme.emerald,
      ),
    );
  }

  Future<void> _acceptRequest(String uid) async {
    await FriendService.acceptFriendRequest(uid);
    _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ami ajouté !'),
        backgroundColor: FantasyTheme.emerald,
      ),
    );
  }

  Future<void> _declineRequest(String uid) async {
    await FriendService.declineFriendRequest(uid);
    _loadData();
  }

  Future<void> _inviteToPlay(Map<String, dynamic> friend) async {
    await OnlineGameService.inviteFriend(friend['uid']);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation envoyée à ${friend['username']} !'),
        backgroundColor: FantasyTheme.purple,
      ),
    );
  }
}
