import 'package:flutter/material.dart';

class ProductsMenu extends StatelessWidget {
  final Function(String) onMenuItemSelected;

  const ProductsMenu({super.key, required this.onMenuItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Products Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _createDrawerItem(
            icon: Icons.cloud_upload,
            text: 'Uploads',
            onTap: () => _onItemTap(context, 'uploads'),
          ),
          _createDrawerItem(
            icon: Icons.hourglass_empty,
            text: 'Under Review',
            onTap: () => _onItemTap(context, 'under_review'),
          ),
          _createDrawerItem(
            icon: Icons.check_circle,
            text: 'Sold',
            onTap: () => _onItemTap(context, 'sold'),
          ),
          _createDrawerItem(
            icon: Icons.local_offer,
            text: 'On Sale',
            onTap: () => _onItemTap(context, 'on_sale'),
          ),
          _createDrawerItem(
            icon: Icons.work,
            text: 'In Process',
            onTap: () => _onItemTap(context, 'in_process'),
          ),
          _createDrawerItem(
            icon: Icons.cancel,
            text: 'Cancelled',
            onTap: () => _onItemTap(context, 'cancelled'),
          ),
          _createDrawerItem(
            icon: Icons.inventory,
            text: 'Inventory',
            onTap: () => _onItemTap(context, 'inventory'),
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          const SizedBox(width: 16),
          Text(text),
        ],
      ),
      onTap: onTap,
    );
  }

  void _onItemTap(BuildContext context, String menuOption) {
    Navigator.of(context).pop(); // Close the drawer
    onMenuItemSelected(menuOption); // Notify the parent widget
  }
}
