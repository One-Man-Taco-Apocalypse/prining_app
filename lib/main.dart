import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const IronCostApp());

class IronCostApp extends StatelessWidget {
  const IronCostApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315CFF)),
      fontFamily: 'Avenir',
    ),
    home: const MainShell(),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int tab = 0;
  final savedQuotes = <SavedQuote>[];
  final rates = <String, double>{
    'General Foreman': 120,
    'Foreman': 115,
    'Iron Worker': 110,
    'Operator': 115,
    'Oiler': 110,
  };
  final craneRates = <String, double>{
    '110T': 450,
    '90T': 400,
    '80T': 400,
    'RT': 350,
  };
  final equipmentRates = <String, double>{
    "60' Man Lift": 200,
    "80' Man Lift": 200,
    "125' Man Lift": 350,
    "135' Man Lift": 350,
  };
  final hourlyEquipmentRates = <String, double>{
    'Big Red': 175,
    'Little Red': 150,
    'Transport': 150,
  };
  double quarterDayHours = 2;
  double halfDayHours = 4;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: tab,
      children: [
        HomeScreen(
          rates: rates,
          craneRates: craneRates,
          equipmentRates: equipmentRates,
          hourlyEquipmentRates: hourlyEquipmentRates,
          quarterDayHours: quarterDayHours,
          halfDayHours: halfDayHours,
          savedQuotes: savedQuotes,
          onQuoteSaved: (quote) => setState(() => savedQuotes.insert(0, quote)),
        ),
        SettingsScreen(
          rates: rates,
          quarterDayHours: quarterDayHours,
          halfDayHours: halfDayHours,
          onChanged: (v) => setState(() => rates.addAll(v)),
          onThresholdsChanged: (values) => setState(() {
            quarterDayHours = values.$1;
            halfDayHours = values.$2;
          }),
        ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (v) => setState(() => tab = v),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.calculate_outlined),
          selectedIcon: Icon(Icons.calculate),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    ),
  );
}

class SavedQuote {
  final String title, building;
  final DateTime date;
  final double total;
  SavedQuote({
    required this.title,
    required this.building,
    required this.date,
    required this.total,
  });
}

class HomeScreen extends StatelessWidget {
  final Map<String, double> rates;
  final Map<String, double> craneRates;
  final Map<String, double> equipmentRates;
  final Map<String, double> hourlyEquipmentRates;
  final double quarterDayHours, halfDayHours;
  final List<SavedQuote> savedQuotes;
  final ValueChanged<SavedQuote> onQuoteSaved;
  const HomeScreen({
    super.key,
    required this.rates,
    required this.craneRates,
    required this.equipmentRates,
    required this.hourlyEquipmentRates,
    required this.quarterDayHours,
    required this.halfDayHours,
    required this.savedQuotes,
    required this.onQuoteSaved,
  });
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Quotes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171827),
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuoteScreen(
                    rates: rates,
                    craneRates: craneRates,
                    equipmentRates: equipmentRates,
                    hourlyEquipmentRates: hourlyEquipmentRates,
                    quarterDayHours: quarterDayHours,
                    halfDayHours: halfDayHours,
                    onSave: (quote) {
                      onQuoteSaved(quote);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New quote'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Create a crew estimate to get started.',
          style: TextStyle(color: Color(0xFF777A8A), fontSize: 15),
        ),
        if (savedQuotes.isEmpty) ...[
          const SizedBox(height: 90),
          const Icon(
            Icons.receipt_long_outlined,
            size: 58,
            color: Color(0xFFB9C3E6),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'No quotes yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Tap New quote to build your first estimate.',
              style: TextStyle(color: Color(0xFF777A8A)),
            ),
          ),
        ] else ...[
          const SizedBox(height: 28),
          const Text(
            'Saved quotes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...savedQuotes.map(
            (quote) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  quote.title.isEmpty ? 'Untitled quote' : quote.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${quote.building} · ${_dateLabel(quote.date)}'),
                trailing: Text(
                  _money(quote.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF315CFF),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class QuoteLine {
  String role;
  int quantity;
  double hours;
  final bool consumable;
  final bool crane;
  final bool equipment;
  final bool hourlyEquipment;
  final double? customTotal;
  bool overtime;
  QuoteLine(
    this.role, {
    this.quantity = 1,
    this.hours = 8,
    this.consumable = false,
    this.crane = false,
    this.equipment = false,
    this.hourlyEquipment = false,
    this.customTotal,
    this.overtime = false,
  });
}

class QuoteScreen extends StatefulWidget {
  final Map<String, double> rates;
  final Map<String, double> craneRates;
  final Map<String, double> equipmentRates;
  final Map<String, double> hourlyEquipmentRates;
  final double quarterDayHours, halfDayHours;
  final ValueChanged<SavedQuote> onSave;
  const QuoteScreen({
    super.key,
    required this.rates,
    required this.craneRates,
    required this.equipmentRates,
    required this.hourlyEquipmentRates,
    required this.quarterDayHours,
    required this.halfDayHours,
    required this.onSave,
  });
  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final lines = <QuoteLine>[];
  String building = 'CP1';
  String? purchaseOrder;
  DateTime quoteDate = DateTime.now();
  final poController = TextEditingController();
  final titleController = TextEditingController();
  final summaryController = TextEditingController();
  final sheetController = TextEditingController();
  final divisionController = TextEditingController();
  final deficiencyController = TextEditingController();

  @override
  void dispose() {
    poController.dispose();
    titleController.dispose();
    summaryController.dispose();
    sheetController.dispose();
    divisionController.dispose();
    deficiencyController.dispose();
    super.dispose();
  }

  double get total => lines.fold(0, (sum, line) => sum + lineTotal(line));

  double lineTotal(QuoteLine line) {
    if (line.customTotal != null) {
      return line.quantity * line.customTotal! * (line.overtime ? 2 : 1);
    }
    if (!line.consumable && !line.equipment) {
      final rate = line.crane
          ? widget.craneRates[line.role]!
          : widget.rates[line.role]!;
      return line.quantity * line.hours * rate * (line.overtime ? 2 : 1);
    }
    if (line.hourlyEquipment) {
      return line.quantity *
          line.hours *
          widget.hourlyEquipmentRates[line.role]! *
          (line.overtime ? 2 : 1);
    }
    final dailyRate = line.equipment
        ? widget.equipmentRates[line.role]!
        : 100.0;
    final fullDays = (line.hours / 8).floor();
    final remainder = line.hours - fullDays * 8;
    final remainderFraction = remainder <= 0
        ? 0
        : remainder <= widget.quarterDayHours
        ? 0.25
        : remainder <= widget.halfDayHours
        ? 0.5
        : 1.0;
    return line.quantity *
        (fullDays + remainderFraction) *
        dailyRate *
        (line.overtime ? 2 : 1);
  }

  Future<void> addLine() async {
    final category = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Add to quote',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.construction_outlined,
                color: Color(0xFF315CFF),
              ),
              title: const Text('Worker'),
              subtitle: const Text('Add workers and crew time'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context, 'Worker'),
            ),
            ListTile(
              leading: const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF315CFF),
              ),
              title: const Text('Consumables'),
              subtitle: const Text('Small tools and torches'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context, 'Consumables'),
            ),
            ListTile(
              leading: const Icon(
                Icons.precision_manufacturing_outlined,
                color: Color(0xFF315CFF),
              ),
              title: const Text('Cranes'),
              subtitle: const Text('Add crane time'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context, 'Cranes'),
            ),
            ListTile(
              leading: const Icon(
                Icons.agriculture_outlined,
                color: Color(0xFF315CFF),
              ),
              title: const Text('Equipment'),
              subtitle: const Text('Add equipment by day'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context, 'Equipment'),
            ),
            ListTile(
              leading: const Icon(
                Icons.edit_note_outlined,
                color: Color(0xFF315CFF),
              ),
              title: const Text('Other'),
              subtitle: const Text('Add a custom item'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context, 'Other'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (!mounted || category == null) return;
    if (category == 'Consumables') {
      final item = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text(
                  'Choose consumable',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              ...['Small tools', 'Torches'].map(
                (item) => ListTile(
                  leading: const Icon(Icons.handyman_outlined),
                  title: Text(item),
                  trailing: const Icon(Icons.add),
                  onTap: () => Navigator.pop(context, item),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
      if (!mounted || item == null) return;
      setState(() => lines.add(QuoteLine(item, consumable: true)));
      return;
    }
    if (category == 'Cranes') {
      final crane = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Choose crane type',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              ...widget.craneRates.keys.map(
                (type) => ListTile(
                  leading: const Icon(Icons.precision_manufacturing_outlined),
                  title: Text(type),
                  trailing: const Icon(Icons.add),
                  onTap: () => Navigator.pop(context, type),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
      if (!mounted || crane == null) return;
      setState(() => lines.add(QuoteLine(crane, crane: true)));
      return;
    }
    if (category == 'Equipment') {
      final equipment = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text(
                  'Choose equipment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              ...[
                ...widget.equipmentRates.keys,
                ...widget.hourlyEquipmentRates.keys,
              ].map(
                (type) => ListTile(
                  leading: const Icon(Icons.agriculture_outlined),
                  title: Text(type),
                  trailing: const Icon(Icons.add),
                  onTap: () => Navigator.pop(context, type),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
      if (!mounted || equipment == null) return;
      setState(
        () => lines.add(
          QuoteLine(
            equipment,
            hours: 8,
            equipment: true,
            hourlyEquipment: widget.hourlyEquipmentRates.containsKey(equipment),
          ),
        ),
      );
      return;
    }
    if (category == 'Other') {
      final nameController = TextEditingController();
      final hoursController = TextEditingController(text: '1');
      final totalController = TextEditingController();
      final result = await showDialog<(String, double, double)>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Add other item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: hoursController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Hours'),
              ),
              TextField(
                controller: totalController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Custom total',
                  prefixText: '\$',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final hours = double.tryParse(hoursController.text);
                final total = double.tryParse(totalController.text);
                if (name.isNotEmpty && hours != null && total != null) {
                  Navigator.pop(dialogContext, (name, hours, total));
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
      nameController.dispose();
      hoursController.dispose();
      totalController.dispose();
      if (!mounted || result == null) return;
      setState(
        () => lines.add(
          QuoteLine(result.$1, hours: result.$2, customTotal: result.$3),
        ),
      );
      return;
    }
    final role = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Choose work type',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            ...widget.rates.keys.map(
              (role) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(role),
                trailing: const Icon(Icons.add),
                onTap: () => Navigator.pop(context, role),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (!mounted || role == null) return;
    setState(() => lines.add(QuoteLine(role)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'New quote',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      backgroundColor: Colors.transparent,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      children: [
        const Text(
          'Quote details',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8E9F0)),
          ),
          child: Column(
            children: [
              _DetailField(label: 'Title', controller: titleController),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: building,
                decoration: const InputDecoration(
                  labelText: 'Building',
                  border: OutlineInputBorder(),
                ),
                items: ['CP1', 'FA1', 'Yard']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => building = value ?? building),
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: quoteDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => quoteDate = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      Text(_dateLabel(quoteDate)),
                      const Spacer(),
                      const Icon(Icons.calendar_today_outlined, size: 19),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: purchaseOrder,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'P/O',
                        border: OutlineInputBorder(),
                      ),
                      items: _purchaseOrders
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                value,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => purchaseOrder = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DetailField(
                      label: 'Sheet number',
                      controller: sheetController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DetailField(
                      label: 'Division',
                      controller: divisionController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DetailField(
                      label: 'Deficiency number',
                      controller: deficiencyController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DetailField(
                label: 'Summary',
                controller: summaryController,
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const SizedBox(height: 6),
        const Text(
          'Add the workers needed for this job.',
          style: TextStyle(color: Color(0xFF777A8A)),
        ),
        const SizedBox(height: 18),
        if (lines.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 42),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8E9F0)),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 42,
                  color: Color(0xFFB9C3E6),
                ),
                SizedBox(height: 12),
                Text(
                  'No work added yet',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 5),
                Text(
                  'Tap Add to choose a work type.',
                  style: TextStyle(color: Color(0xFF777A8A)),
                ),
              ],
            ),
          )
        else
          ...lines.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RepaintBoundary(
                child: _LineCard(
                  line: entry.value,
                  rate: entry.value.customTotal != null
                      ? 0
                      : entry.value.consumable
                      ? 0
                      : entry.value.crane
                      ? widget.craneRates[entry.value.role]!
                      : entry.value.equipment
                      ? entry.value.hourlyEquipment
                            ? widget.hourlyEquipmentRates[entry.value.role]!
                            : widget.equipmentRates[entry.value.role]!
                      : widget.rates[entry.value.role]!,
                  displayTotal: lineTotal(entry.value),
                  consumable: entry.value.consumable,
                  equipment: entry.value.equipment,
                  hourlyEquipment: entry.value.hourlyEquipment,
                  overtime: entry.value.overtime,
                  onChanged: () => setState(() {}),
                  onRemove: () => setState(() => lines.removeAt(entry.key)),
                ),
              ),
            ),
          ),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: addLine,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 18),
        _summaryBox(),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => widget.onSave(
            SavedQuote(
              title: titleController.text.trim(),
              building: building,
              date: quoteDate,
              total: total,
            ),
          ),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save quote'),
        ),
      ],
    ),
  );

  Widget _summaryBox() {
    final details = <String>[];
    details.add(_dateLabel(quoteDate));
    if (sheetController.text.trim().isNotEmpty)
      details.add('Sheet ${sheetController.text.trim()}');
    if (divisionController.text.trim().isNotEmpty)
      details.add('Division ${divisionController.text.trim()}');
    if (deficiencyController.text.trim().isNotEmpty)
      details.add('Deficiency ${deficiencyController.text.trim()}');
    if (summaryController.text.trim().isNotEmpty)
      details.add(summaryController.text.trim());

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E9F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Summary',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Copy summary',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _summaryText()));
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Summary copied')),
                    );
                },
                icon: const Icon(Icons.copy_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            details.join('\n'),
            style: const TextStyle(color: Color(0xFF777A8A), height: 1.4),
          ),
          if (lines.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '${line.quantity} ${line.role} @ ${_num(line.hours)} hours ${line.overtime ? '(OT) ' : ''}${_money(lineTotal(line))}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF303143)),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              Text(
                _money(total),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF315CFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _summaryText() {
    final details = <String>[_dateLabel(quoteDate)];
    if (sheetController.text.trim().isNotEmpty)
      details.add('Sheet ${sheetController.text.trim()}');
    if (divisionController.text.trim().isNotEmpty)
      details.add('Division ${divisionController.text.trim()}');
    if (deficiencyController.text.trim().isNotEmpty)
      details.add('Deficiency ${deficiencyController.text.trim()}');
    if (summaryController.text.trim().isNotEmpty)
      details.add(summaryController.text.trim());
    final itemLines = lines.map(
      (line) =>
          '${line.quantity} ${line.role} @ ${_num(line.hours)} hours ${line.overtime ? '(OT) ' : ''}${_money(lineTotal(line))}',
    );
    return [...details, ...itemLines, 'Total ${_money(total)}'].join('\n');
  }
}

class _LineCard extends StatefulWidget {
  final QuoteLine line;
  final double rate;
  final double displayTotal;
  final bool consumable;
  final bool equipment;
  final bool hourlyEquipment;
  final bool overtime;
  final VoidCallback onChanged, onRemove;
  const _LineCard({
    required this.line,
    required this.rate,
    required this.onChanged,
    required this.onRemove,
    required this.displayTotal,
    required this.consumable,
    required this.equipment,
    required this.hourlyEquipment,
    required this.overtime,
  });
  @override
  State<_LineCard> createState() => _LineCardState();
}

class _LineCardState extends State<_LineCard> {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE8E9F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.line.role,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              _money(widget.displayTotal),
              style: const TextStyle(
                color: Color(0xFF315CFF),
                fontWeight: FontWeight.w800,
              ),
            ),
            IconButton(
              onPressed: widget.onRemove,
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
            ),
          ],
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Overtime', style: TextStyle(fontSize: 13)),
          value: widget.line.overtime,
          onChanged: (value) {
            setState(() => widget.line.overtime = value);
            widget.onChanged();
          },
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'Quantity',
                value: widget.line.quantity.toString(),
                onChanged: (v) {
                  setState(() => widget.line.quantity = int.tryParse(v) ?? 0);
                  widget.onChanged();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Field(
                label: widget.consumable ? 'Hours / day' : 'Hours',
                value: _num(widget.line.hours),
                onChanged: (v) {
                  setState(() => widget.line.hours = double.tryParse(v) ?? 0);
                  widget.onChanged();
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Field extends StatefulWidget {
  final String label, value;
  final ValueChanged<String> onChanged;
  const _Field({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final TextEditingController controller = TextEditingController(
    text: widget.value,
  );

  void commit() => widget.onChanged(controller.text);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    onEditingComplete: () {
      commit();
      FocusManager.instance.primaryFocus?.unfocus();
    },
    onTapOutside: (_) {
      commit();
      FocusManager.instance.primaryFocus?.unfocus();
    },
    decoration: InputDecoration(
      labelText: widget.label,
      filled: true,
      fillColor: const Color(0xFFF8F9FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

class _DetailField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  const _DetailField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLines: maxLines,
    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}

String _dateLabel(DateTime date) =>
    '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';

const _purchaseOrders = [
  'Fab error 6901.003',
  'Design error 6901.007',
  'Crane down time 690.036',
  'Grating modification 6901.005',
  'Grating damage 6901.004',
  'CP1 deck 690.36',
  'CP1 Anchor Bolts 696.035',
  'FA1 deck 6961.003',
  'FA1 Anchor 696.020',
  'Yard 696.018',
];

class SettingsScreen extends StatefulWidget {
  final Map<String, double> rates;
  final double quarterDayHours, halfDayHours;
  final ValueChanged<Map<String, double>> onChanged;
  final ValueChanged<(double, double)> onThresholdsChanged;
  const SettingsScreen({
    super.key,
    required this.rates,
    required this.onChanged,
    required this.quarterDayHours,
    required this.halfDayHours,
    required this.onThresholdsChanged,
  });
  @override
  State<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  late final controllers = {
    for (final e in widget.rates.entries)
      e.key: TextEditingController(text: e.value.toStringAsFixed(0)),
  };
  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Set the hourly cost for each role.',
          style: TextStyle(color: Color(0xFF777A8A)),
        ),
        const SizedBox(height: 28),
        ...controllers.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              controller: e.value,
              keyboardType: TextInputType.number,
              onEditingComplete: () {
                final rate = double.tryParse(e.value.text);
                if (rate != null) widget.onChanged({e.key: rate});
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onTapOutside: (_) {
                final rate = double.tryParse(e.value.text);
                if (rate != null) widget.onChanged({e.key: rate});
                FocusManager.instance.primaryFocus?.unfocus();
              },
              decoration: InputDecoration(
                labelText: e.key,
                prefixText: '\$',
                suffixText: 'per hour',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Consumable day thresholds',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Set when consumables move from quarter day to half day, and half day to full day.',
          style: TextStyle(color: Color(0xFF777A8A)),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          min: 1,
          max: 8,
          divisions: 7,
          values: RangeValues(widget.quarterDayHours, widget.halfDayHours),
          labels: RangeLabels(
            '${widget.quarterDayHours.round()} hrs',
            '${widget.halfDayHours.round()} hrs',
          ),
          onChanged: (values) =>
              widget.onThresholdsChanged((values.start, values.end)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Quarter day: ${widget.quarterDayHours.round()} hrs'),
            Text('Half day: ${widget.halfDayHours.round()} hrs'),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Pricing: quarter day 25 dollars · half day 50 dollars · full day 100 dollars · each full 8-hour day after that adds 100 dollars.',
          style: TextStyle(color: Color(0xFF777A8A), fontSize: 13),
        ),
      ],
    ),
  );
}

String _money(double value) => '\$${value.toStringAsFixed(2)}';
String _num(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(1);
