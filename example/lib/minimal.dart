// the smallest real app: flutter run -t lib/minimal.dart
import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Inbox()));

class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  int tab = 0;
  int? open;

  @override
  Widget build(BuildContext context) {
    return DuoNavigationScaffold(
      appBar: AppBar(title: Text(context.duo.mode.name)),
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        DuoDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
        DuoDestination(icon: Icon(Icons.star), label: 'Starred'),
      ],
      body: DuoListDetail<int>(
        selected: open,
        onClose: () => setState(() => open = null),
        empty: (_) => const Center(child: Text('Pick a message')),
        list: (_) => ListView.builder(
          itemCount: 30,
          itemBuilder: (_, i) => ListTile(
            title: Text('Message $i'),
            selected: i == open,
            onTap: () => setState(() => open = i),
          ),
        ),
        detail: (_, i) => Center(child: Text('Message $i')),
      ),
    );
  }
}
