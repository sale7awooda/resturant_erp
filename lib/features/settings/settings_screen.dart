import 'package:flutter/material.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: ExpansionTileGroup(
          toggleType: ToggleType.expandOnlyCurrent, // only one open at a time
          spaceBetweenItem: 8,
          children: [
            // --- Restaurant Info ---
            ExpansionTileItem(
              title: const Text("Restaurant Information"),
              children: [
                _buildTile(context, "Name & Logo"),
                _buildTile(context, "Description"),
                _buildTile(context, "Location & Address"),
                _buildTile(context, "Phone"),
                _buildTile(context, "Working Hours"),
              ],
            ),

            // --- Menu & Categories ---
            ExpansionTileItem(
              title: const Text("Menu & Categories"),
              children: [
                _buildTile(context, "Manage Categories"),
                _buildTile(context, "Manage Menu Items"),
              ],
            ),

            // --- Tables ---
            ExpansionTileItem(
              title: const Text("Tables & Orders"),
              children: [
                _buildTile(context, "Dining Tables"),
                _buildTile(context, "Special Orders"),
              ],
            ),

            // --- Payments ---
            ExpansionTileItem(
              title: const Text("Payments & Invoices"),
              children: [
                _buildTile(context, "Payment Types"),
                _buildTile(context, "Currency"),
                _buildTile(context, "Invoice Settings"),
                _buildTile(context, "Share Invoice"),
              ],
            ),

            // --- Users & Roles ---
            ExpansionTileItem(
              title: const Text("Users & Roles"),
              children: [
                _buildTile(context, "Manage Users"),
                _buildTile(context, "Roles & Permissions"),
              ],
            ),

            // --- System ---
            ExpansionTileItem(
              title: const Text("System Settings"),
              children: [
                _buildTile(context, "Theme Mode"),
                _buildTile(context, "Accent Color"),
                _buildTile(context, "Language"),
                _buildTile(context, "Printer Settings"),
              ],
            ),

            // --- Data ---
            ExpansionTileItem(
              title: const Text("Data Management"),
              children: [
                _buildTile(context, "Export Database"),
                _buildTile(context, "Import Database"),
                _buildTile(context, "Backups"),
                _buildTile(context, "Reset System"),
              ],
            ),

            // --- Advanced ---
            ExpansionTileItem(
              title: const Text("Advanced & About"),
              children: [
                _buildTile(context, "Notifications"),
                _buildTile(context, "Logs"),
                _buildTile(context, "About App"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // TODO: Navigate to the right CRUD/settings screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Open: $title")),
        );
      },
    );
  }
}
