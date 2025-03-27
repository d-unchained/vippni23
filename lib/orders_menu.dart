import 'package:flutter/material.dart';
import 'orders_screen.dart'; // Import the OrdersScreen widget

class OrdersMenu extends StatelessWidget {
  const OrdersMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF31135F),
            ),
            child: Text(
              'Orders Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Orders Received'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrdersScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Earnings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EarningsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem),
            title: const Text('Disputed'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DisputedPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Print Labels'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Print Labels functionality is not yet implemented.')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Color(0xFF31135F),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Created'),
                Tab(text: 'Dispatched'),
              ],
              labelColor: Colors.black,
              indicatorColor: Color(0xFF31135F),
            ),
            Expanded(
              child: const TabBarView(
                children: [
                  Center(
                      child: Text(
                          'Created Reports Content')), // Placeholder for Created Tab
                  Center(
                      child: Text(
                          'Dispatched Reports Content')), // Placeholder for Dispatched Tab
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DisputedPage extends StatelessWidget {
  const DisputedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disputed Orders'),
        backgroundColor: Color(0xFF31135F),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Under Review'),
                Tab(text: 'Completed'),
              ],
              labelColor: Colors.black,
              indicatorColor: Color(0xFF31135F),
            ),
            Expanded(
              child: const TabBarView(
                children: [
                  Center(
                      child: Text(
                          'Under Review Content')), // Placeholder for Under Review Tab
                  Center(
                      child: Text(
                          'Completed Content')), // Placeholder for Completed Tab
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: Color(0xFF31135F),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Received'),
              ],
              labelColor: Colors.black,
              indicatorColor: Color(0xFF31135F),
            ),
            Expanded(
              child: const TabBarView(
                children: [
                  Center(
                      child: Text(
                          'Pending Earnings Content')), // Placeholder for Pending Tab
                  Center(
                      child: Text(
                          'Received Earnings Content')), // Placeholder for Received Tab
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
