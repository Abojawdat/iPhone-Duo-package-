import 'package:duo_dynamic_sizing/duo_dynamic_sizing.dart';
import 'package:flutter/material.dart';

void main() => runApp(const Showcase());

const brand = Color(0xFF6D5DFC);

ThemeData appTheme(Brightness brightness, {List<String>? fontFallback}) {
  final scheme = ColorScheme.fromSeed(seedColor: brand, brightness: brightness);
  final base = ThemeData(colorScheme: scheme, fontFamilyFallback: fontFallback);
  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: base.textTheme.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -.4,
        color: scheme.onSurface,
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.primaryContainer,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.primaryContainer,
    ),
  );
}

typedef Mail = ({
  String from,
  String subject,
  String preview,
  String time,
  bool unread,
});

typedef Copy = ({
  List<String> tabs,
  String pick,
  String reply,
  String forward,
  String toMe,
  String body,
  String compose,
  String to,
  String send,
  String close,
  String video,
  List<Mail> mails,
});

const Copy en = (
  tabs: ['Inbox', 'Watch', 'Device'],
  pick: 'Pick an email',
  reply: 'Reply',
  forward: 'Forward',
  toMe: 'to me',
  body:
      'Fold the phone and this email stays open. Unfold it and the list '
      'comes back right next to it, scrolled where you left it.',
  compose: 'Compose',
  to: 'To',
  send: 'Send',
  close: 'Close',
  video: 'Night drive',
  mails: [
    (
      from: 'Sara Haddad',
      subject: 'Duo build is green',
      preview: 'All checks passed on the foldable simulator, shipping tonight.',
      time: '9:41',
      unread: true,
    ),
    (
      from: 'Omar Khalil',
      subject: 'Split View feedback',
      preview: 'The rail follows the left app, exactly like the native bars.',
      time: '9:12',
      unread: true,
    ),
    (
      from: 'Lina Park',
      subject: 'Crease test results',
      preview: 'Nothing interactive sits on the fold anymore. Shots attached.',
      time: '8:55',
      unread: false,
    ),
    (
      from: 'Yousef Amin',
      subject: 'Release notes 1.0',
      preview: 'Draft is up, can you add the media fit section?',
      time: 'Yesterday',
      unread: false,
    ),
    (
      from: 'Maya Chen',
      subject: 'Tabletop mode ideas',
      preview: 'Video on top, controls on the bottom half. Feels natural.',
      time: 'Yesterday',
      unread: false,
    ),
    (
      from: 'Adam Novak',
      subject: 'Lunch on Thursday?',
      preview: 'New place next to the office, great shawarma.',
      time: 'Mon',
      unread: false,
    ),
    (
      from: 'Noor Saleh',
      subject: 'Design review',
      preview: 'Loved the passport shape layouts, few notes on spacing.',
      time: 'Mon',
      unread: false,
    ),
    (
      from: 'Ethan Brooks',
      subject: 'Android foldables',
      preview: 'Half open fold, the panes split right at the hinge.',
      time: 'Sun',
      unread: false,
    ),
  ],
);

const Copy ar = (
  tabs: ['البريد', 'المشاهدة', 'الجهاز'],
  pick: 'اختر رسالة',
  reply: 'رد',
  forward: 'إعادة توجيه',
  toMe: 'إليّ',
  body:
      'اطوِ الهاتف وستبقى هذه الرسالة مفتوحة. افتحه وستعود القائمة بجانبها '
      'في نفس موضع التمرير الذي تركتها عنده.',
  compose: 'رسالة جديدة',
  to: 'إلى',
  send: 'إرسال',
  close: 'إغلاق',
  video: 'قيادة ليلية',
  mails: [
    (
      from: 'سارة حداد',
      subject: 'نسخة Duo جاهزة',
      preview: 'نجحت كل الاختبارات على محاكي الجهاز القابل للطي، سننشر الليلة.',
      time: '9:41',
      unread: true,
    ),
    (
      from: 'عمر خليل',
      subject: 'ملاحظات على Split View',
      preview: 'شريط التنقل يتبع التطبيق الأيسر تماماً مثل الأشرطة الأصلية.',
      time: '9:12',
      unread: true,
    ),
    (
      from: 'لينا ناصر',
      subject: 'نتائج اختبار الطية',
      preview: 'لم يعد أي عنصر قابل للنقر يقع على الطية. الصور مرفقة.',
      time: '8:55',
      unread: false,
    ),
    (
      from: 'يوسف أمين',
      subject: 'ملاحظات الإصدار 1.0',
      preview: 'المسودة جاهزة، هل يمكنك إضافة قسم ملاءمة الوسائط؟',
      time: 'أمس',
      unread: false,
    ),
    (
      from: 'مايا سعيد',
      subject: 'أفكار لوضع الطاولة',
      preview: 'الفيديو في الأعلى وأزرار التحكم في النصف السفلي. تجربة طبيعية.',
      time: 'أمس',
      unread: false,
    ),
    (
      from: 'آدم يوسف',
      subject: 'غداء يوم الخميس؟',
      preview: 'مطعم جديد بجانب المكتب، والشاورما عندهم رائعة.',
      time: 'الإثنين',
      unread: false,
    ),
    (
      from: 'نور صالح',
      subject: 'مراجعة التصميم',
      preview: 'أعجبتني التخطيطات بشكل جواز السفر، لدي ملاحظات على المسافات.',
      time: 'الإثنين',
      unread: false,
    ),
    (
      from: 'أحمد العلي',
      subject: 'أجهزة أندرويد القابلة للطي',
      preview: 'عند فتح الجهاز نصف فتحة تنقسم اللوحات عند المفصل تماماً.',
      time: 'الأحد',
      unread: false,
    ),
  ],
);

Copy copyOf(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl ? ar : en;

const _avatarColors = [
  Color(0xFF6D5DFC),
  Color(0xFFEC4899),
  Color(0xFF14B8A6),
  Color(0xFFF59E0B),
  Color(0xFF3B82F6),
  Color(0xFF8B5CF6),
  Color(0xFF10B981),
  Color(0xFFEF4444),
];

Color colorAt(int i) => _avatarColors[i % _avatarColors.length];

class Showcase extends StatefulWidget {
  const Showcase({super.key});

  @override
  State<Showcase> createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> {
  DuoPose? _pose = DuoPose.openLandscape;
  bool _guides = true;
  bool _rtl = false;

  @override
  Widget build(BuildContext context) {
    final pose = _pose;
    if (pose == null) {
      return MailApp(
        onSimulate: () => setState(() => _pose = DuoPose.openLandscape),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(Brightness.dark),
      home: Scaffold(
        backgroundColor: const Color(0xFF0A0B14),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in DuoPose.values)
                      ChoiceChip(
                        label: Text(p.name),
                        selected: p == pose,
                        onSelected: (_) => setState(() => _pose = p),
                      ),
                    FilterChip(
                      label: const Text('RTL'),
                      selected: _rtl,
                      onSelected: (v) => setState(() => _rtl = v),
                    ),
                    FilterChip(
                      label: const Text('Guides'),
                      selected: _guides,
                      onSelected: (v) => setState(() => _guides = v),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.phone_iphone),
                      label: const Text('This device'),
                      onPressed: () => setState(() => _pose = null),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DuoSimulator(
                    pose: pose,
                    showGuides: _guides,
                    child: MailApp(
                      textDirection: _rtl ? TextDirection.rtl : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MailApp extends StatelessWidget {
  const MailApp({
    super.key,
    this.onSimulate,
    this.debugOverlay = true,
    this.initialTab = 0,
    this.initialMail,
    this.initialFit = DuoMediaFit.smart,
    this.textDirection,
    this.fontFallback,
  });

  final VoidCallback? onSimulate;
  final bool debugOverlay;
  final int initialTab;
  final int? initialMail;
  final DuoMediaFit initialFit;

  /// rtl also switches the content to Arabic.
  final TextDirection? textDirection;
  final List<String>? fontFallback;

  @override
  Widget build(BuildContext context) {
    final dir = textDirection;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Duo Mail',
      theme: appTheme(Brightness.light, fontFallback: fontFallback),
      darkTheme: appTheme(Brightness.dark, fontFallback: fontFallback),
      themeMode: ThemeMode.light,
      builder: (context, child) {
        final app = DuoDebugOverlay(enabled: debugOverlay, child: child!);
        return dir == null
            ? app
            : Directionality(textDirection: dir, child: app);
      },
      home: Home(
        onSimulate: onSimulate,
        initialTab: initialTab,
        initialMail: initialMail,
        initialFit: initialFit,
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    super.key,
    this.onSimulate,
    this.initialTab = 0,
    this.initialMail,
    this.initialFit = DuoMediaFit.smart,
  });

  final VoidCallback? onSimulate;
  final int initialTab;
  final int? initialMail;
  final DuoMediaFit initialFit;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final copy = copyOf(context);
    return DuoNavigationScaffold(
      appBar: AppBar(
        title: Text(copy.tabs[_tab]),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          const Padding(
            padding: EdgeInsetsDirectional.only(end: 12, start: 4),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: brand,
              child: Text(
                'M',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      selectedIndex: _tab,
      onDestinationSelected: (i) => setState(() => _tab = i),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: _compose,
              tooltip: copy.compose,
              elevation: 0,
              child: const Icon(Icons.edit_outlined),
            )
          : null,
      destinations: [
        DuoDestination(
          icon: const Icon(Icons.inbox_outlined),
          selectedIcon: const Icon(Icons.inbox),
          label: copy.tabs[0],
        ),
        DuoDestination(
          icon: const Icon(Icons.play_circle_outline),
          selectedIcon: const Icon(Icons.play_circle),
          label: copy.tabs[1],
        ),
        DuoDestination(
          icon: const Icon(Icons.devices_fold_outlined),
          selectedIcon: const Icon(Icons.devices_fold),
          label: copy.tabs[2],
        ),
      ],
      body: IndexedStack(
        index: _tab,
        children: [
          Inbox(initialMail: widget.initialMail),
          WatchPage(initialFit: widget.initialFit),
          DevicePage(onSimulate: widget.onSimulate),
        ],
      ),
    );
  }

  void _compose() {
    final copy = copyOf(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(copy.compose),
        content: TextField(decoration: InputDecoration(hintText: copy.to)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(copy.send),
          ),
        ],
      ),
    );
  }
}

class Inbox extends StatefulWidget {
  const Inbox({super.key, this.initialMail});

  final int? initialMail;

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  late int? _open = widget.initialMail;

  @override
  Widget build(BuildContext context) {
    final mails = copyOf(context).mails;
    return DuoListDetail<int>(
      selected: _open,
      onClose: () => setState(() => _open = null),
      empty: (_) => const _Empty(),
      list: (context) => ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: 24,
        itemBuilder: (context, i) => _MailTile(
          mail: mails[i % mails.length],
          color: colorAt(i),
          selected: i == _open,
          onTap: () => setState(() => _open = i),
        ),
      ),
      detail: (context, i) => MailView(
        mail: mails[i % mails.length],
        color: colorAt(i),
        onClose: () => setState(() => _open = null),
      ),
    );
  }
}

class _MailTile extends StatelessWidget {
  const _MailTile({
    required this.mail,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Mail mail;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = TextStyle(color: scheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected ? scheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color,
                  child: Text(
                    mail.from.characters.first,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mail.from,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: mail.unread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            mail.time,
                            style: theme.textTheme.labelSmall?.merge(muted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mail.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        mail.preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.merge(muted),
                      ),
                    ],
                  ),
                ),
                if (mail.unread)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 8,
                      top: 26,
                    ),
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: scheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MailView extends StatelessWidget {
  const MailView({
    super.key,
    required this.mail,
    required this.color,
    required this.onClose,
  });

  final Mail mail;
  final Color color;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final copy = copyOf(context);
    final m = context.duo.margin;
    return Material(
      color: scheme.surface,
      child: ListView(
        padding: EdgeInsets.fromLTRB(m, 4, m, m),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    mail.subject,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.3,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                tooltip: copy.close,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color,
                child: Text(
                  mail.from.characters.first,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mail.from, style: theme.textTheme.titleSmall),
                    Text(
                      '${copy.toMe} · ${mail.time}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${mail.preview}\n\n${copy.body}',
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 20),
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF6D5DFC), Color(0xFFA855F7)],
              ),
            ),
            child: const Center(
              child: Icon(Icons.devices_fold, color: Colors.white, size: 44),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.reply),
                label: Text(copy.reply),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.forward),
                label: Text(copy.forward),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mark_email_read_outlined, size: 56, color: scheme.outline),
          const SizedBox(height: 12),
          Text(
            copyOf(context).pick,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class WatchPage extends StatefulWidget {
  const WatchPage({super.key, this.initialFit = DuoMediaFit.smart});

  final DuoMediaFit initialFit;

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  late var _fit = widget.initialFit;

  @override
  Widget build(BuildContext context) {
    final duo = context.duo;
    final picker = Padding(
      padding: EdgeInsets.fromLTRB(duo.margin, 4, duo.margin, 12),
      child: SegmentedButton<DuoMediaFit>(
        showSelectedIcon: false,
        segments: [
          for (final f in DuoMediaFit.values)
            ButtonSegment(value: f, label: Text(f.name)),
        ],
        selected: {_fit},
        onSelectionChanged: (s) => setState(() => _fit = s.first),
      ),
    );
    final video = LayoutBuilder(
      builder: (context, box) {
        final shown = DuoMedia.fitSize(16 / 9, box.biggest, fit: _fit);
        return Stack(
          fit: StackFit.expand,
          children: [
            DuoMedia(aspectRatio: 16 / 9, fit: _fit, child: const _Video()),
            PositionedDirectional(
              start: 12,
              top: 12,
              child: _Tag(
                '${copyOf(context).video} · 16:9 · '
                '${shown.width.round()} × ${shown.height.round()}',
              ),
            ),
          ],
        );
      },
    );
    if (duo.posture == DuoPosture.tabletop) {
      return DuoSplit(
        primary: video,
        secondary: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [picker, const _Controls()],
        ),
      );
    }
    return Column(
      children: [
        picker,
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              video,
              const DuoAvoidFold(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _Controls(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Video extends StatelessWidget {
  const _Video();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B4B), Color(0xFF6D5DFC), Color(0xFF22D3EE)],
        ),
      ),
      child: Center(
        child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 72),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: .45),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: scheme.surface.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(28),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.replay_10)),
              IconButton.filled(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.forward_10)),
            ],
          ),
        ),
      ),
    );
  }
}

class DevicePage extends StatelessWidget {
  const DevicePage({super.key, this.onSimulate});

  final VoidCallback? onSimulate;

  @override
  Widget build(BuildContext context) {
    return DuoLayout(
      closed: (_) => DuoKeep(id: 'facts', child: _Facts(onSimulate)),
      open: (_) => Row(
        children: [
          Expanded(
            child: DuoKeep(id: 'facts', child: _Facts(onSimulate)),
          ),
          const VerticalDivider(width: 1),
          const Expanded(child: _ModeCard()),
        ],
      ),
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts(this.onSimulate);

  final VoidCallback? onSimulate;

  @override
  Widget build(BuildContext context) {
    final duo = context.duo;
    final p = duo.safe;
    String n(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
    Widget fact(IconData icon, String name, String value) => ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(name),
      trailing: Text(value),
    );
    return ListView(
      children: [
        fact(Icons.devices_fold, 'Mode', duo.mode.name),
        fact(Icons.phone_iphone, 'iPhone Duo', duo.isIphoneDuo ? 'yes' : 'no'),
        fact(
          Icons.aspect_ratio,
          'Window',
          '${n(duo.size.width)} × ${n(duo.size.height)}',
        ),
        fact(
          Icons.border_outer,
          'Safe area',
          'L${n(p.left)} T${n(p.top)} R${n(p.right)} B${n(p.bottom)}',
        ),
        fact(Icons.view_column_outlined, 'Columns', '${duo.columns}'),
        fact(Icons.grid_view, 'Grid, 160 pt tiles', '${duo.gridColumns(160)}'),
        fact(Icons.menu_book_outlined, 'Posture', duo.posture.name),
        fact(
          Icons.vertical_split_outlined,
          'Fold',
          duo.fold == null
              ? 'none'
              : '${duo.foldDirection!.name}'
                    '${duo.isSeparating ? ', separating' : ''}',
        ),
        fact(
          Icons.navigation_outlined,
          'Navigation',
          duo.prefersRail ? 'side rail' : 'bottom bar',
        ),
        if (onSimulate != null)
          Padding(
            padding: EdgeInsets.all(duo.margin),
            child: FilledButton.icon(
              onPressed: onSimulate,
              icon: const Icon(Icons.devices_fold),
              label: const Text('Try every pose'),
            ),
          ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard();

  @override
  Widget build(BuildContext context) {
    final duo = context.duo;
    final scheme = Theme.of(context).colorScheme;
    final icon = switch (duo.mode) {
      DuoMode.closedPortrait || DuoMode.closedLandscape => Icons.smartphone,
      DuoMode.openLandscape || DuoMode.openPortrait => Icons.devices_fold,
      DuoMode.splitView => Icons.splitscreen,
      DuoMode.tablet => Icons.tablet_mac,
      DuoMode.desktop => Icons.desktop_windows,
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 96, color: scheme.primary),
          const SizedBox(height: 12),
          Text(
            duo.mode.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            duo.posture.name,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
