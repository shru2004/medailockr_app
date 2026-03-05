// ─── Medicos Screen — Reddit-style Professional Medical Community ─────────────
// Tabs: Feed (Hot/New/Top/Rising) | Communities
// Post card:  r/Specialty • Posted by u/DrName • timestamp
//             Flair badge • Title • Body preview
//             Award badges | ▲ score ▼ | 💬 Comments | Share | Save
// Comments sheet: per-comment vote arrows + nested look
// Create post FAB: community picker, flair selector

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_endpoints.dart';
import '../../models/notification_model.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _orange   = Color(0xFFFF4500);
const _bgGrey   = Color(0xFFDAE0E6);
const _downBlue = Color(0xFF7193FF);
const _cardBg   = Colors.white;
const _textDim  = Color(0xFF7C7C7C);
const _flair    = Color(0xFF0DD3BB);

const _awardData = {
  'gold':       ('🥇', Color(0xFFFFD700)),
  'silver':     ('🥈', Color(0xFFB0B0B0)),
  'helpful':    ('🏅', Color(0xFFFF8C00)),
  'insightful': ('💡', Color(0xFF4A90D9)),
  'wholesome':  ('❤️', Color(0xFFFF4500)),
};

const _flairColors = {
  'Case Study':  Color(0xFF0DD3BB),
  'Discussion':  Color(0xFF4A90D9),
  'Research':    Color(0xFF7E53C1),
  'Protocol':    Color(0xFF46D160),
  'Question':    Color(0xFFFF6314),
};

class MedicosScreen extends StatefulWidget {
  const MedicosScreen({super.key});
  @override
  State<MedicosScreen> createState() => _MedicosScreenState();
}

class _MedicosScreenState extends State<MedicosScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<MedicosPost> _posts      = kMedicosFeed;
  bool              _loading    = false;
  String            _sort       = 'hot';
  String            _community  = '';
  List<Map<String, dynamic>> _communities = [];
  bool _communitiesLoading = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _fetchFeed();
    _fetchCommunities();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _fetchFeed({String? sort, String? community}) async {
    if (!mounted) return;
    final s = sort      ?? _sort;
    final c = community ?? _community;
    setState(() { _loading = true; _sort = s; _community = c; });
    try {
      final uri = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.medicosFeed}'
        '?sort=$s${c.isNotEmpty ? '&community=$c' : ''}&limit=50',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = (data['posts'] as List<dynamic>? ?? [])
            .map((e) => MedicosPost.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() { _posts = list.isNotEmpty ? list : kMedicosFeed; });
      }
    } catch (_) {
      if (mounted) setState(() { _posts = kMedicosFeed; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _fetchCommunities() async {
    if (!mounted) return;
    setState(() => _communitiesLoading = true);
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.medicosCommunities}');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = List<Map<String, dynamic>>.from(
          (data['communities'] as List<dynamic>? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map)));
        setState(() => _communities = list);
      }
    } catch (_) {}
    finally { if (mounted) setState(() => _communitiesLoading = false); }
  }

  Future<void> _vote(MedicosPost post, String direction) async {
    final prev  = post.voteDirection ?? 'none';
    final dir   = prev == direction ? 'none' : direction;
    int up   = post.upvotes;
    int down = post.downvotes;
    if (prev == 'up')   up   = (up   - 1).clamp(0, 9999);
    if (prev == 'down') down = (down - 1).clamp(0, 9999);
    if (dir  == 'up')   up   += 1;
    if (dir  == 'down') down += 1;
    setState(() {
      _posts = _posts.map((p) => p.backendId == post.backendId
          ? p.copyWith(upvotes: up, downvotes: down, score: up - down,
              voteDirection: dir == 'none' ? null : dir)
          : p).toList();
    });
    if (post.backendId == null) return;
    try {
      await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.medicosVote(post.backendId!)}'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'direction': dir, 'prev': prev}),
      ).timeout(const Duration(seconds: 8));
    } catch (_) {}
  }

  Future<void> _share(MedicosPost post) async {
    if (post.backendId == null) return;
    try {
      await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.medicosShare(post.backendId!)}'),
        headers: const {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 6));
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Link copied!'), backgroundColor: _orange,
        duration: Duration(seconds: 2)));
  }

  Future<void> _addPost(Map<String, dynamic> payload) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.medicosPosts}'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 201 && mounted) {
        final p = MedicosPost.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
        setState(() => _posts = [p, ..._posts]);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGrey,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              indicatorColor: _orange,
              indicatorWeight: 3,
              labelColor: _orange,
              unselectedLabelColor: _textDim,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              tabs: const [Tab(text: 'Feed'), Tab(text: 'Communities')],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _FeedTab(
                  posts:      _posts,
                  loading:    _loading,
                  sort:       _sort,
                  onSort:     (s) => _fetchFeed(sort: s),
                  onVote:     _vote,
                  onShare:    _share,
                  onRefresh:  _fetchFeed,
                  onTapPost:  _openPost,
                  onTapCommunity: (c) { _tabs.animateTo(0); _fetchFeed(community: c); },
                ),
                _CommunitiesTab(
                  communities:     _communities,
                  loading:         _communitiesLoading,
                  activeCommunity: _community,
                  onTap: (name) { _tabs.animateTo(0); _fetchFeed(community: name); },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _orange,
        child: const Icon(Icons.edit, color: Colors.white),
        onPressed: _showCreatePost,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: _orange),
            child: const Center(
              child: Text('r/', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12))),
          ),
          const SizedBox(width: 8),
          const Text('Medicos', style: TextStyle(color: Color(0xFF1A1A1B), fontWeight: FontWeight.w800, fontSize: 18)),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search, color: Color(0xFF1A1A1B)), onPressed: () {}),
        IconButton(icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1A1A1B)), onPressed: () {}),
        const SizedBox(width: 4),
      ],
    );
  }

  void _openPost(MedicosPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentSheet(post: post),
    );
  }

  void _showCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePostSheet(
        communities: _communities.isNotEmpty
            ? _communities.map((c) => c['name'] as String).toList()
            : const ['Cardiology', 'Dermatology', 'Neurology', 'Pediatrics',
                     'Ophthalmology', 'Psychiatry'],
        onSubmit: _addPost,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Feed Tab
// ══════════════════════════════════════════════════════════════════════════════

class _FeedTab extends StatelessWidget {
  final List<MedicosPost> posts;
  final bool              loading;
  final String            sort;
  final void Function(String) onSort;
  final void Function(MedicosPost, String) onVote;
  final void Function(MedicosPost) onShare;
  final Future<void> Function() onRefresh;
  final void Function(MedicosPost) onTapPost;
  final void Function(String) onTapCommunity;

  const _FeedTab({
    required this.posts, required this.loading, required this.sort,
    required this.onSort, required this.onVote, required this.onShare,
    required this.onRefresh, required this.onTapPost, required this.onTapCommunity,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _orange,
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _SortBar(current: sort, onSelect: onSort)),
          if (loading)
            const SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator(color: _orange))),
            )
          else if (posts.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No posts yet. Be the first!',
                  style: TextStyle(color: _textDim))),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _PostCard(
                    post: posts[i],
                    onVote: (dir) => onVote(posts[i], dir),
                    onShare: () => onShare(posts[i]),
                    onTap:   () => onTapPost(posts[i]),
                    onTapCommunity: onTapCommunity,
                  ),
                ),
                childCount: posts.length,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Sort bar ──────────────────────────────────────────────────────────────────

class _SortBar extends StatelessWidget {
  final String current;
  final void Function(String) onSelect;
  const _SortBar({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const sorts = [
      ('hot',    '🔥', 'Hot'),
      ('new',    '✨', 'New'),
      ('top',    '⬆️', 'Top'),
      ('rising', '📈', 'Rising'),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: sorts.map<Widget>((t) {
          final (key, emoji, label) = t;
          final active = current == key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:        active ? _orange.withOpacity(0.12) : const Color(0xFFF6F7F8),
                  border:       Border.all(color: active ? _orange : const Color(0xFFEDEFF1), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: active ? _orange : const Color(0xFF1A1A1B))),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Post Card ─────────────────────────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  final MedicosPost post;
  final void Function(String) onVote;
  final VoidCallback onShare;
  final VoidCallback onTap;
  final void Function(String) onTapCommunity;

  const _PostCard({
    required this.post, required this.onVote, required this.onShare,
    required this.onTap, required this.onTapCommunity,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardBg,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetaRow(post: post, onTapCommunity: onTapCommunity),
              const SizedBox(height: 6),
              if (post.awards.isNotEmpty) ...[
                _AwardBadges(awards: post.awards),
                const SizedBox(height: 6),
              ],
              if (post.flair != null) ...[
                _FlairChip(label: post.flair!),
                const SizedBox(height: 4),
              ],
              Text(post.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                      color: Color(0xFF1A1A1B))),
              const SizedBox(height: 4),
              Text(post.body, maxLines: 3, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF3C3C3C), height: 1.4)),
              if (post.imageUrl != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(post.imageUrl!, height: 180, width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ),
              ],
              const SizedBox(height: 10),
              _ActionTray(post: post, onVote: onVote, onShare: onShare, onComment: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final MedicosPost post;
  final void Function(String) onTapCommunity;
  const _MetaRow({required this.post, required this.onTapCommunity});

  @override
  Widget build(BuildContext context) {
    final specialty = post.specialty ??
        (post.tags.isNotEmpty ? post.tags.first.replaceAll('#', '') : 'Medicos');
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onTapCommunity(specialty),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 10, backgroundColor: _orange,
                  child: const Text('r/', style: TextStyle(color: Colors.white, fontSize: 8,
                      fontWeight: FontWeight.w900))),
              const SizedBox(width: 4),
              Text('r/$specialty',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12,
                      color: Color(0xFF1A1A1B))),
            ],
          ),
        ),
        const Text(' • ', style: TextStyle(color: _textDim, fontSize: 12)),
        Text('Posted by u/${post.author.name.replaceAll(' ', '').replaceFirst('Dr.', 'Dr')}',
            style: const TextStyle(color: _textDim, fontSize: 12)),
        if (post.author.verified) ...[
          const SizedBox(width: 2),
          const Icon(Icons.verified, size: 12, color: _orange),
        ],
        const Text(' • ', style: TextStyle(color: _textDim, fontSize: 12)),
        Text(post.timestamp, style: const TextStyle(color: _textDim, fontSize: 12)),
      ],
    );
  }
}

class _AwardBadges extends StatelessWidget {
  final List<Map<String, dynamic>> awards;
  const _AwardBadges({required this.awards});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: awards.take(5).map((a) {
        final type  = a['type'] as String? ?? 'helpful';
        final count = a['count'] as int? ?? 1;
        final entry = _awardData[type];
        final emoji = entry?.$1 ?? '🏅';
        final color = entry?.$2 ?? _orange;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              if (count > 1) ...[
                const SizedBox(width: 2),
                Text('$count', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _FlairChip extends StatelessWidget {
  final String label;
  const _FlairChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = _flairColors[label] ?? _flair;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.15),
        border:       Border.all(color: color.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _ActionTray extends StatelessWidget {
  final MedicosPost post;
  final void Function(String) onVote;
  final VoidCallback onShare;
  final VoidCallback onComment;
  const _ActionTray({required this.post, required this.onVote, required this.onShare, required this.onComment});

  static String _fmt(int n) => n >= 1000 ? '${(n/1000).toStringAsFixed(1)}k' : '$n';

  @override
  Widget build(BuildContext context) {
    final dir = post.voteDirection;
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(color: const Color(0xFFF6F7F8), borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => onVote('up'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Icon(Icons.arrow_upward_rounded, size: 18,
                      color: dir == 'up' ? _orange : _textDim),
                ),
              ),
              Text(_fmt(post.score), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: dir == 'up' ? _orange : dir == 'down' ? _downBlue : const Color(0xFF1A1A1B))),
              GestureDetector(
                onTap: () => onVote('down'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Icon(Icons.arrow_downward_rounded, size: 18,
                      color: dir == 'down' ? _downBlue : _textDim),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _ActionBtn(icon: Icons.chat_bubble_outline_rounded, label: _fmt(post.comments), onTap: onComment),
        const SizedBox(width: 8),
        _ActionBtn(icon: Icons.share_outlined, label: 'Share', onTap: onShare),
        const SizedBox(width: 8),
        _ActionBtn(icon: Icons.bookmark_border_rounded, label: 'Save', onTap: () {}),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String   label;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFFF6F7F8), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: _textDim),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: _textDim, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Communities Tab
// ══════════════════════════════════════════════════════════════════════════════

class _CommunitiesTab extends StatelessWidget {
  final List<Map<String, dynamic>> communities;
  final bool   loading;
  final String activeCommunity;
  final void Function(String) onTap;
  const _CommunitiesTab({
    required this.communities, required this.loading,
    required this.activeCommunity, required this.onTap,
  });

  static const _fallback = <Map<String, dynamic>>[
    {'name': 'Cardiology',    'icon': '❤️',  'members': 18400, 'postCount': 4, 'color': 0xFFEF4444},
    {'name': 'Dermatology',   'icon': '🩺',  'members': 12200, 'postCount': 3, 'color': 0xFFF59E0B},
    {'name': 'Neurology',     'icon': '🧠',  'members': 15700, 'postCount': 5, 'color': 0xFF8B5CF6},
    {'name': 'Pediatrics',    'icon': '👶',  'members': 14200, 'postCount': 4, 'color': 0xFFEC4899},
    {'name': 'Ophthalmology', 'icon': '👁',  'members': 9300,  'postCount': 2, 'color': 0xFF06B6D4},
    {'name': 'Psychiatry',    'icon': '🧩',  'members': 10600, 'postCount': 2, 'color': 0xFF6366F1},
  ];

  static String _fmtM(int n) => n >= 1000 ? '${(n/1000).toStringAsFixed(1)}k' : '$n';

  @override
  Widget build(BuildContext context) {
    final data = communities.isNotEmpty ? communities : _fallback;
    if (loading) return const Center(child: CircularProgressIndicator(color: _orange));
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (ctx, i) {
        final c      = data[i];
        final name   = c['name'] as String? ?? '';
        final icon   = c['icon'] as String? ?? '🏥';
        final members= c['members'] as int? ?? 0;
        final posts  = c['postCount'] as int? ?? 0;
        final colorVal = c['color'];
        final color  = colorVal is int ? Color(colorVal | 0xFF000000) : _orange;
        final active = activeCommunity.toLowerCase() == name.toLowerCase();

        return Material(
          color: active ? _orange.withOpacity(0.06) : Colors.white,
          child: InkWell(
            onTap: () => onTap(name),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:  color.withOpacity(0.15),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('r/$name', style: const TextStyle(fontWeight: FontWeight.w700,
                                fontSize: 14, color: Color(0xFF1A1A1B))),
                            if (active) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(8)),
                                child: const Text('Active', style: TextStyle(color: Colors.white,
                                    fontSize: 10, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('${_fmtM(members)} members • $posts ${posts == 1 ? 'post' : 'posts'}',
                            style: const TextStyle(color: _textDim, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: _textDim),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Comment Sheet
// ══════════════════════════════════════════════════════════════════════════════

class _CommentSheet extends StatefulWidget {
  final MedicosPost post;
  const _CommentSheet({required this.post});
  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final _ctrl = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _loading = false;
  bool _posting  = false;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    if (widget.post.backendId == null) return;
    setState(() => _loading = true);
    try {
      final res = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.medicosComments(widget.post.backendId!)}'),
      ).timeout(const Duration(seconds: 8));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() {
          _comments = List<Map<String, dynamic>>.from(
            (data['comments'] as List<dynamic>? ?? [])
                .map((e) => Map<String, dynamic>.from(e as Map)));
        });
      }
    } catch (_) {} finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _postComment() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || widget.post.backendId == null) return;
    setState(() => _posting = true);
    try {
      final res = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.medicosComments(widget.post.backendId!)}'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'author': {'name': 'You', 'title': 'Doctor',
            'image': 'https://i.pravatar.cc/150?img=1', 'verified': false}, 'body': text}),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 201 && mounted) {
        final c = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() { _comments = [Map<String, dynamic>.from(c), ..._comments]; _ctrl.clear(); });
      }
    } catch (_) {} finally { if (mounted) setState(() => _posting = false); }
  }

  Future<void> _voteComment(String commentId, String direction, String prev) async {
    try {
      await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.medicosCommentVote(commentId)}'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'direction': direction, 'prev': prev}),
      ).timeout(const Duration(seconds: 6));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFCCCCCC),
                      borderRadius: BorderRadius.circular(2))),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.post.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text('${widget.post.comments} comments',
                      style: const TextStyle(color: _textDim, fontSize: 12)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: _orange))
                  : _comments.isEmpty
                      ? const Center(child: Text('No comments yet. Start the discussion!',
                          style: TextStyle(color: _textDim)))
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemCount: _comments.length,
                          itemBuilder: (_, i) => _CommentTile(
                            comment: _comments[i],
                            onVote: (dir, prev) =>
                                _voteComment(_comments[i]['id'] as String? ?? '', dir, prev),
                          ),
                        ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.only(left: 12, right: 12, top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 8),
              child: Row(
                children: [
                  const CircleAvatar(radius: 16,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Add a comment…',
                        hintStyle: const TextStyle(color: _textDim, fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true, fillColor: const Color(0xFFF6F7F8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _posting
                      ? const SizedBox(width: 32, height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2, color: _orange))
                      : IconButton(
                          icon: const Icon(Icons.send_rounded, color: _orange),
                          onPressed: _postComment),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatefulWidget {
  final Map<String, dynamic> comment;
  final void Function(String, String) onVote;
  const _CommentTile({required this.comment, required this.onVote});
  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  String? _voteDir;
  late int _score;

  @override
  void initState() {
    super.initState();
    final up   = widget.comment['upvotes']   as int? ?? 1;
    final down = widget.comment['downvotes'] as int? ?? 0;
    _score = (widget.comment['score'] as int?) ?? (up - down);
  }

  void _handleVote(String dir) {
    final prev = _voteDir ?? 'none';
    final next = prev == dir ? 'none' : dir;
    int s = _score;
    if (prev == 'up')   s--;
    if (prev == 'down') s++;
    if (next == 'up')   s++;
    if (next == 'down') s--;
    setState(() { _voteDir = next == 'none' ? null : next; _score = s; });
    widget.onVote(next, prev);
  }

  @override
  Widget build(BuildContext context) {
    final a        = widget.comment['author'] as Map<String, dynamic>? ?? {};
    final name     = a['name']     as String? ?? 'Anonymous';
    final image    = a['image']    as String? ?? 'https://i.pravatar.cc/150?img=1';
    final verified = a['verified'] as bool?   ?? false;
    final body     = widget.comment['body']      as String? ?? '';
    final ts       = widget.comment['timestamp'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 14, backgroundImage: NetworkImage(image)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    if (verified) ...[
                      const SizedBox(width: 2),
                      const Icon(Icons.verified, size: 11, color: _orange),
                    ],
                    const SizedBox(width: 4),
                    Text(ts, style: const TextStyle(color: _textDim, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 13, height: 1.4)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _handleVote('up'),
                      child: Icon(Icons.arrow_upward_rounded, size: 16,
                          color: _voteDir == 'up' ? _orange : _textDim),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text('$_score', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                          color: _voteDir == 'up' ? _orange : _voteDir == 'down' ? _downBlue : _textDim)),
                    ),
                    GestureDetector(
                      onTap: () => _handleVote('down'),
                      child: Icon(Icons.arrow_downward_rounded, size: 16,
                          color: _voteDir == 'down' ? _downBlue : _textDim),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('Reply', style: TextStyle(fontSize: 12,
                          color: _textDim, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Create Post Sheet
// ══════════════════════════════════════════════════════════════════════════════

class _CreatePostSheet extends StatefulWidget {
  final List<String> communities;
  final Future<void> Function(Map<String, dynamic>) onSubmit;
  const _CreatePostSheet({required this.communities, required this.onSubmit});
  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();
  String? _selectedCommunity;
  String? _selectedFlair;
  bool    _submitting = false;

  static const _flairs = ['Case Study', 'Discussion', 'Research', 'Protocol', 'Question'];

  @override
  void dispose() { _titleCtrl.dispose(); _bodyCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Title and body are required.'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _submitting = true);
    await widget.onSubmit({
      'author': {'name': 'You', 'title': 'Doctor',
          'image': 'https://i.pravatar.cc/150?img=1', 'verified': false},
      'title':     _titleCtrl.text.trim(),
      'body':      _bodyCtrl.text.trim(),
      'specialty': _selectedCommunity,
      'flair':     _selectedFlair,
      'tags':      _selectedCommunity != null ? ['#${_selectedCommunity!}'] : <String>[],
    });
    if (mounted) { setState(() => _submitting = false); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 4),
            child: Row(
              children: [
                const Expanded(child: Text('Create Post',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17))),
                TextButton(
                  onPressed: _submitting ? null : _submit,
                  style: TextButton.styleFrom(backgroundColor: _orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: _submitting
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Community', style: TextStyle(fontWeight: FontWeight.w600,
                      fontSize: 13, color: _textDim)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedCommunity,
                    hint: const Text('Choose a community'),
                    decoration: InputDecoration(
                      filled: true, fillColor: const Color(0xFFF6F7F8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    items: widget.communities
                        .map((c) => DropdownMenuItem(value: c, child: Text('r/$c')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCommunity = v),
                  ),
                  const SizedBox(height: 14),
                  const Text('Flair (optional)', style: TextStyle(fontWeight: FontWeight.w600,
                      fontSize: 13, color: _textDim)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _flairs.map((f) {
                      final selected = _selectedFlair == f;
                      final color = _flairColors[f] ?? _flair;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFlair = selected ? null : f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:        selected ? color : color.withOpacity(0.1),
                            border:       Border.all(color: color, width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(f, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : color)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Text('Title', style: TextStyle(fontWeight: FontWeight.w600,
                      fontSize: 13, color: _textDim)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleCtrl, maxLength: 300,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Post title', counterText: '',
                      filled: true, fillColor: const Color(0xFFF6F7F8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Body', style: TextStyle(fontWeight: FontWeight.w600,
                      fontSize: 13, color: _textDim)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _bodyCtrl, maxLines: 8, maxLength: 5000,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText:  'Share your case, question, or insight…',
                      counterText: '', filled: true, fillColor: const Color(0xFFF6F7F8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
