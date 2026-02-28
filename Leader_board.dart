import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health/health.dart';
import 'login_page.dart';
//import 'welcome_screen.dart';
//import 'Workout_main.dart';
import 'Workout_part2.dart';
import 'Workout_part3.dart';
import 'Workout_part4.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  bool _isLoading = false;
  bool _healthSynced = false;
  bool _isCreatingGroup = false;

  Future<void> _syncHealthData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final types = [HealthDataType.STEPS, HealthDataType.ACTIVE_ENERGY_BURNED];
    final health = Health();

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: 30));

    final authorized = await health.requestAuthorization(types);
    if (!authorized) {
      print("❌ Health permission not granted");
      // Show a friendly dialog explaining the need for Health access
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Health Access Required"),
          content: const Text(
            "To create or view groups, Atomfit needs permission to access Apple Health data.\n\n"
            "You can enable this in iPhone Settings → Health → Atomfit → Turn On All.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      setState(() {
        _healthSynced = true;
      });
      return;
    }

    try {
    
      final healthData = await health.getHealthDataFromTypes(
        types: types,
        startTime: thirtyDaysAgo,
        endTime: now,
      );
      int totalSteps = 0;
      double totalCalories = 0;

      for (var data in healthData) {
        final value = data.value;
        if (value is NumericHealthValue) {
          if (data.type == HealthDataType.STEPS) {
            totalSteps += value.numericValue.toInt();
          } else if (data.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
            totalCalories += value.numericValue;
          }
        }
      }

      print("🚶 Steps: $totalSteps, 🔥 Calories: $totalCalories");

      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDoc.set({
        'steps': totalSteps,
        'calories': totalCalories,
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Error fetching health data: $e");
    }
  }

  Future<void> _ensureDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();
    final data = userDoc.data();

    final existingName = data?['displayName']?.toString().trim();
    if (existingName != null && existingName.isNotEmpty) return;

    final controller = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Create Your User ID"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Enter a username (visible to others)"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await userDocRef.set({'displayName': name}, SetOptions(merge: true));
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchGroups(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final userData = userDoc.data();
      if (userData == null) {
        print("⚠️ No user document found for UID: $uid");
        return [];
      }

      final groupIds = List<String>.from(userData['groups'] ?? []);
      print("✅ User is part of ${groupIds.length} group(s)");

      if (groupIds.isEmpty) {
        return [];
      }

      final groups = await Future.wait(
        groupIds.map((id) => FirebaseFirestore.instance.collection('groups').doc(id).get()),
      );
      // Filter out deleted or malformed group docs
      return groups.where((d) => d.exists && d.data() != null).toList();
    } on FirebaseException catch (e) {
      // Handle permission-denied gracefully and surface a UI hint via print
      if (e.code == 'permission-denied') {
        print('🔒 Firestore rules blocked reading groups for this user. Check security rules.');
      } else {
        print('❌ Firestore error in _fetchGroups: ${e.code} ${e.message}');
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchGroupMemberStats(List<String> memberUids) async {
    final memberDocs = await Future.wait(
      memberUids.map((uid) => FirebaseFirestore.instance.collection('users').doc(uid).get()),
    );
    return memberDocs
        .where((doc) => doc.exists)
        .map((doc) {
          final data = doc.data()!;
          return {
            'displayName': data['displayName'] ?? 'Unknown',
            'steps': data['steps'] ?? 0,
            'calories': data['calories'] ?? 0,
          };
        })
        .toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _fetchGroups(user.uid);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    (() async {
      await _syncHealthData();
      await _ensureDisplayName();
      if (mounted) {
        setState(() => _healthSynced = true);
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    if (!_healthSynced) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in
      return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create a group with your friends and turn your fitness journey into a joyful, fun ride. Track each other’s progress and challenge one another to push further!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6C00),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Login to Create Groups',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Color(0xFFFF6C00), width: 2),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.fitness_center, size: 56, color: Colors.white),
                      onPressed: () {
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.local_fire_department, size: 56, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const CaloriesPage()),
                        );
                      },
                    ),
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: IconButton(
                        icon: const Icon(Icons.emoji_events, size: 72, color: Color(0xFFFF6C00)),
                        onPressed: () {},
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.person, size: 56, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // Logged in user
      return Scaffold(
        backgroundColor: Colors.white,
appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.pop(context);
    },
  ),
  title: const Text(
    'Your Fitness Groups',
    style: TextStyle(color: Colors.white),
  ),
  backgroundColor: const Color(0xFF00A884),
  elevation: 0,
  actions: [
    IconButton(
      icon: const Icon(Icons.refresh, color: Colors.white),
      onPressed: () => _refresh(),
    ),
    
  ],
),
        body: SafeArea(
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());

              final userRaw = userSnapshot.data?.data();
              if (userRaw == null) {
                print("⚠️ User document is null");
                return const Center(child: Text("User data not found."));
              }
              final userData = userRaw as Map<String, dynamic>;
              final groupIds = List<String>.from(userData['groups'] ?? []);

              // --- Inserted group create/join buttons here ---
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.group_add),
                          label: Text("Create Group"),
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00A884)),
                          onPressed: () async {
                            final controller = TextEditingController();
                            await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                title: const Text("Create New Group"),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(labelText: "Group Name"),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  StatefulBuilder(
                                    builder: (context, setStateDialog) {
                                      return TextButton(
                                        onPressed: _isCreatingGroup
                                            ? null
                                            : () async {
                                                if (_isCreatingGroup) return;
                                                setState(() {
                                                  _isCreatingGroup = true;
                                                });

                                                final groupName = controller.text.trim();
                                                if (groupName.isEmpty) {
                                                  setState(() {
                                                    _isCreatingGroup = false;
                                                  });
                                                  return;
                                                }

                                                final user = FirebaseAuth.instance.currentUser!;
                                                final createdGroupsQuery = await FirebaseFirestore.instance
                                                    .collection('groups')
                                                    .where('createdBy', isEqualTo: user.uid)
                                                    .get();

                                                if (createdGroupsQuery.docs.length >= 15) {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text("Limit Reached"),
                                                      content: const Text("You can only create up to 15 groups."),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: const Text("OK"),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  setState(() {
                                                    _isCreatingGroup = false;
                                                  });
                                                  return;
                                                }

                                                final groupDoc = await FirebaseFirestore.instance.collection('groups').add({
                                                  'name': groupName,
                                                  'createdBy': user.uid,
                                                  'members': [user.uid],
                                                  'createdAt': Timestamp.now(),
                                                  'inviteCode': DateTime.now().millisecondsSinceEpoch.toString().substring(7),
                                                });

                                                final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
                                                final userDocSnap = await userDocRef.get();
                                                if (!userDocSnap.exists) {
                                                  await userDocRef.set({
                                                    'groups': [],
                                                    'createdAt': Timestamp.now(),
                                                  });
                                                }

                                                await userDocRef.update({
                                                  'groups': FieldValue.arrayUnion([groupDoc.id])
                                                });

                                                Navigator.pop(context);
                                                await _refresh();
                                                setState(() {
                                                  _isCreatingGroup = false;
                                                });
                                              },
                                        child: _isCreatingGroup
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              )
                                            : const Text("Create"),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.input),
                          label: Text("Join Group"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                          onPressed: () async {
                            final controller = TextEditingController();
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Join Group"),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(labelText: "Enter Invite Code"),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final inviteCode = controller.text.trim();
                                      if (inviteCode.isEmpty) return;
                                      final groupQuery = await FirebaseFirestore.instance
                                          .collection('groups')
                                          .where('inviteCode', isEqualTo: inviteCode)
                                          .limit(1)
                                          .get();
                                      if (groupQuery.docs.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Group not found!")),
                                        );
                                      } else {
                                        final groupDoc = groupQuery.docs.first;
                                        final user = FirebaseAuth.instance.currentUser!;
                                        await FirebaseFirestore.instance.collection('groups').doc(groupDoc.id).update({
                                          'members': FieldValue.arrayUnion([user.uid])
                                        });
                                        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                                          'groups': FieldValue.arrayUnion([groupDoc.id])
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Joined group successfully!")),
                                        );
                                        setState(() {}); // refresh the list
                                      }
                                    },
                                    child: const Text("Join"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  if (groupIds.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text("You're not part of any group yet. Create a group with your friends and turn your fitness journey into a joyful, fun ride. Track each other’s progress and challenge one another to push further!"),
                    ),
                  Expanded(
                    child: Stack(
                      children: [
                        FutureBuilder<List<DocumentSnapshot>>(
                          future: _fetchGroups(user.uid),
                          builder: (context, groupSnapshots) {
                            if (!groupSnapshots.hasData) return const Center(child: CircularProgressIndicator());

                            final groups = groupSnapshots.data!;
                            if (groups.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text('No groups to show.'),
                                      SizedBox(height: 8),
                                      Text('Tap Refresh.', style: TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: groups.length,
                              itemBuilder: (context, index) {
                                final doc = groups[index];
                                final raw = doc.data();
                                final Map<String, dynamic>? group = raw is Map<String, dynamic> ? raw : null;
                                final groupId = doc.id;
                                final String groupName = (group?['name'] as String?)?.trim().isNotEmpty == true
                                    ? (group?['name'] as String)
                                    : 'Unnamed Group';
                                final String? inviteCode = group?['inviteCode'] as String?;
                                return Card(
                                  margin: const EdgeInsets.all(8),
                                  child: ListTile(
                                    title: Text(groupName),
                                    subtitle: Text('Invite Code: ${inviteCode ?? 'N/A'}'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => GroupLeaderboardPage(
                                            groupId: groupId,
                                            groupName: groupName,
                                          ),
                                        ),
                                      );
                                    },
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.share),
                                          onPressed: () {
                                            final code = inviteCode;
                                            if (code != null && code.isNotEmpty) {
                                              final message = 'Join my Atomfit group using this code: $code.\nDownload the app: https://apps.apple.com/in/app/atomfit/id6747727915';
                                              Share.share(message);
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () async {
                                            final controller = TextEditingController(text: groupName);
                                            final newName = await showDialog<String>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text("Rename Group"),
                                                content: TextField(
                                                  controller: controller,
                                                  decoration: const InputDecoration(labelText: "New Group Name"),
                                                ),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                                                  TextButton(
                                                    onPressed: () {
                                                      final name = controller.text.trim();
                                                      if (name.isNotEmpty) {
                                                        Navigator.pop(context, name);
                                                      }
                                                    },
                                                    child: const Text("Save"),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (newName != null && newName.trim().isNotEmpty) {
                                              await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
                                                'name': newName.trim()
                                              });
                                              setState(() {});
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text("Delete Group"),
                                                content: const Text("Are you sure you want to delete this group?"),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              final groupId = groups[index].id;
                                              await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
                                              await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                                                'groups': FieldValue.arrayRemove([groupId])
                                              });
                                              setState(() {});
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        
      );
    }
  }
}

// --- GroupLeaderboardPage screen for showing group leaderboard ---

class GroupLeaderboardPage extends StatelessWidget {
  final String groupId;
  final String groupName;

  const GroupLeaderboardPage({super.key, required this.groupId, required this.groupName});

  Future<List<Map<String, dynamic>>> _fetchMemberStats() async {
    final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
    final members = List<String>.from(groupDoc.data()?['members'] ?? []);

    final memberDocs = await Future.wait(
      members.map((uid) => FirebaseFirestore.instance.collection('users').doc(uid).get()),
    );

    return memberDocs
        .where((doc) => doc.exists)
        .map((doc) {
          final data = doc.data()!;
          return {
            'displayName': data['displayName'] ?? 'Unknown',
            'steps': data['steps'] ?? 0,
            'calories': data['calories'] ?? 0,
          };
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('$groupName Leaderboard'),
        backgroundColor: Color(0xFFFF6C00),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                labelColor: Colors.orange,
                unselectedLabelColor: Colors.black,
                tabs: [
                  Tab(text: "Steps"),
                  Tab(text: "Calories"),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Showing data from the last 30 days',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchMemberStats(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final stats = snapshot.data!;

                    final sortedBySteps = List<Map<String, dynamic>>.from(stats)
                      ..sort((a, b) => (b['steps'] as int).compareTo(a['steps'] as int));
                    final sortedByCalories = List<Map<String, dynamic>>.from(stats)
                      ..sort((a, b) => (b['calories'] as num).compareTo(a['calories'] as num));

                    return TabBarView(
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: sortedBySteps.length,
                          itemBuilder: (context, index) {
                            final member = sortedBySteps[index];
                            return ListTile(
                              leading: CircleAvatar(child: Text('${index + 1}')),
                              title: Text(member['displayName']),
                              subtitle: Text('🚶 Steps: ${member['steps']}'),
                            );
                          },
                        ),
                        ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: sortedByCalories.length,
                          itemBuilder: (context, index) {
                            final member = sortedByCalories[index];
                            return ListTile(
                              leading: CircleAvatar(child: Text('${index + 1}')),
                              title: Text(member['displayName']),
                              subtitle: Text('🔥 Calories: ${member['calories']}'),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
