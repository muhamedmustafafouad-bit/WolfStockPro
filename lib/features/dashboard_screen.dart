import 'package:flutter/material.dart';

import '../../models/user_model.dart';

import '../products/products_screen.dart';

class DashboardScreen extends StatelessWidget {
  final UserModel user;

  const DashboardScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WolfStock Pro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      drawer: _buildDrawer(context),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(
              const Duration(milliseconds: 500),
            );
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildWelcomeCard(context),

              const SizedBox(height: 20),

              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _statCard(
                    context,
                    icon: Icons.inventory_2_outlined,
                    title: 'Products',
                    value: '0',
                  ),
                  _statCard(
                    context,
                    icon: Icons.warning_amber_rounded,
                    title: 'Low Stock',
                    value: '0',
                  ),
                  _statCard(
                    context,
                    icon: Icons.trending_up,
                    title: "Today's In",
                    value: '0',
                  ),
                  _statCard(
                    context,
                    icon: Icons.trending_down,
                    title: "Today's Out",
                    value: '0',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),
              
              _actionTile(
  context,
  Icons.add_box_outlined,
  'Add Product',
  'Create a new inventory item',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductsScreen(
          branchId: user.branchId ?? 1,
        ),
      ),
    );
  },
),
              _actionTile(
                context,
                Icons.login,
                'Stock In',
                'Receive products into stock',
              ),

              _actionTile(
                context,
                Icons.logout,
                'Stock Out',
                'Issue products from stock',
              ),

              _actionTile(
                context,
                Icons.swap_horiz,
                'Transfer Stock',
                'Move stock between branches',
              ),

              const SizedBox(height: 20),

              const Text(
                'System',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _actionTile(
                context,
                Icons.assessment_outlined,
                'Reports',
                'View inventory and movement reports',
              ),

              _actionTile(
                context,
                Icons.backup_outlined,
                'Backup',
                'Backup and restore your database',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer,
              colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: Text(
                user.fullName.isNotEmpty
                    ? user.fullName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${user.role} • Branch #${user.branchId ?? '-'}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),

            const Spacer(),

            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(
  BuildContext context,
  IconData icon,
  String title,
  String subtitle, {
  VoidCallback? onTap,
})
{
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: onTap ??
    () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$title module will be available soon.',
          ),
        ),
      );
    },
        
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_rounded,
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'WolfStock Pro',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.username,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
  leading: const Icon(Icons.inventory_2_outlined),
  title: const Text('Products'),
  onTap: () {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductsScreen(
          branchId: user.branchId ?? 1,
        ),
      ),
    );
  },
),

            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Categories'),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('Suppliers'),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Stock Transfers'),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.assessment_outlined),
              title: const Text('Reports'),
              onTap: () {},
            ),

            const Spacer(),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
