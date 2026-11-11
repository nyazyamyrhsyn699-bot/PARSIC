import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ParsicApp());
}

class ParsicApp extends StatelessWidget {
  const ParsicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'هخامنش',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101014),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC69B48),
          brightness: Brightness.dark,
        ),
      ),
      home: const ParsicHome(),
    );
  }
}

class ParsicHome extends StatefulWidget {
  const ParsicHome({super.key});

  @override
  State<ParsicHome> createState() => _ParsicHomeState();
}

class _ParsicHomeState extends State<ParsicHome> {
  final input = TextEditingController();
  final search = TextEditingController();

  String output = '';
  String mode = 'فارسی به هخامنش';
  int page = 0;

  static const Map<String, String> alphabet = {
    'ا':'𐎠','ب':'𐎡','پ':'𐎢','ت':'𐎣',
    'ث':'𐎤','ج':'𐎥','چ':'𐎦','ح':'𐎧',
    'خ':'𐎨','د':'𐎩','ذ':'𐎪','ر':'𐎫',
    'ز':'𐎬','ژ':'𐎭','س':'𐎮','ش':'𐎯',
    'ص':'𐎰','ض':'𐎱','ط':'𐎲','ظ':'𐎳',
    'ع':'𐎴','غ':'𐎵','ف':'𐎶','ق':'𐎷',
    'ک':'𐎸','گ':'𐎹','ل':'𐎺','م':'𐎻',
    'ن':'𐎼','و':'𐎽','ه':'𐎾','ی':'𐎿',
  };

  static const List<Map<String,String>> dictionary = [
    {'word':'من','meaning':'گوینده؛ شخص اول','category':'ضمیر'},
    {'word':'تو','meaning':'شنونده؛ شخص دوم','category':'ضمیر'},
    {'word':'او','meaning':'شخص سوم','category':'ضمیر'},
    {'word':'ما','meaning':'گروه شامل گوینده','category':'ضمیر'},
    {'word':'شما','meaning':'گروه شنوندگان','category':'ضمیر'},
    {'word':'آب','meaning':'مایع زندگی','category':'اسم'},
    {'word':'آتش','meaning':'عنصر آتش','category':'اسم'},
    {'word':'زمین','meaning':'سرزمین و خاک','category':'اسم'},
    {'word':'آسمان','meaning':'فضای بالای زمین','category':'اسم'},
    {'word':'خورشید','meaning':'ستاره منظومه شمسی','category':'اسم'},
    {'word':'ماه','meaning':'قمر زمین','category':'اسم'},
    {'word':'ستاره','meaning':'جرم نورانی آسمان','category':'اسم'},
    {'word':'خانه','meaning':'محل زندگی','category':'اسم'},
    {'word':'دوست','meaning':'یار و همراه','category':'اسم'},
    {'word':'دشمن','meaning':'مخالف و بدخواه','category':'اسم'},
    {'word':'شاه','meaning':'فرمانروا','category':'اسم'},
    {'word':'مردم','meaning':'انسان‌ها','category':'اسم'},
    {'word':'زبان','meaning':'سامانه ارتباطی','category':'اسم'},
    {'word':'کتاب','meaning':'اثر نوشتاری','category':'اسم'},
    {'word':'دانش','meaning':'آگاهی و شناخت','category':'اسم'},
    {'word':'بزرگ','meaning':'دارای اندازه یا اهمیت زیاد','category':'صفت'},
    {'word':'خوب','meaning':'دارای ویژگی پسندیده','category':'صفت'},
    {'word':'زیبا','meaning':'دارای زیبایی','category':'صفت'},
    {'word':'نو','meaning':'تازه','category':'صفت'},
    {'word':'رفتن','meaning':'حرکت کردن از جایی','category':'فعل'},
    {'word':'آمدن','meaning':'رسیدن به جایی','category':'فعل'},
    {'word':'دیدن','meaning':'با چشم مشاهده کردن','category':'فعل'},
    {'word':'دانستن','meaning':'آگاهی داشتن','category':'فعل'},
    {'word':'گفتن','meaning':'بیان کردن','category':'فعل'},
    {'word':'ساختن','meaning':'پدید آوردن','category':'فعل'},
    {'word':'سلام','meaning':'درود و خوشامدگویی','category':'عبارت'},
    {'word':'سپاس','meaning':'تشکر','category':'عبارت'},
    {'word':'بدرود','meaning':'خداحافظی','category':'عبارت'},
  ];

  static const List<Map<String,String>> grammar = [
    {'title':'ترتیب جمله','rule':'فاعل + مفعول + فعل'},
    {'title':'جمع','rule':'پسوند پیشنهادی جمع: ان'},
    {'title':'مالکیت','rule':'پسوند پیشنهادی مالکیت: ی'},
    {'title':'صفت','rule':'صفت پس از اسم قرار می‌گیرد'},
    {'title':'جهت نوشتار','rule':'چپ به راست'},
  ];

  String normalize(String text) {
    return text
        .replaceAll('آ','ا')
        .replaceAll('أ','ا')
        .replaceAll('إ','ا')
        .replaceAll('ي','ی')
        .replaceAll('ى','ی')
        .replaceAll('ك','ک');
  }

  String convert(String text) {
    final normalized = normalize(text);
    final reverse = {
      for (final entry in alphabet.entries) entry.value: entry.key
    };

    final runes = normalized.runes;
    final result = StringBuffer();

    for (final rune in runes) {
      final char = String.fromCharCode(rune);

      if (mode == 'فارسی به هخامنش') {
        result.write(alphabet[char] ?? char);
      } else {
        result.write(reverse[char] ?? char);
      }
    }
    return result.toString();
  }

  void translate() {
    setState(() => output = convert(input.text));
  }

  Future<void> copyOutput() async {
    if (output.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: output));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('متن کپی شد')),
    );
  }

  Future<void> openKeyboard() async {
    try {
      await const MethodChannel('parsic/keyboard')
          .invokeMethod('openKeyboard');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('صفحه‌کلید در دسترس نیست')),
      );
    }
  }

  Widget translatorPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const SizedBox(height: 8),
        const Text(
          '𐎱𐎠𐎼𐎿𐎡𐎣',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 42, color: Color(0xFFD5AC5B)),
        ),
        const SizedBox(height: 8),
        const Text(
          'زبان هخامنش',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'HAKHAMANESH LANGUAGE PROJECT',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.amber, letterSpacing: 2),
        ),
        const SizedBox(height: 25),
        DropdownButtonFormField<String>(
          value: mode,
          decoration: const InputDecoration(
            labelText: 'جهت تبدیل',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'فارسی به هخامنش',
              child: Text('فارسی به هخامنش'),
            ),
            DropdownMenuItem(
              value: 'هخامنش به فارسی',
              child: Text('هخامنش به فارسی'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              mode = value!;
              output = '';
            });
          },
        ),
        const SizedBox(height: 18),
        TextField(
          controller: input,
          maxLines: 5,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            labelText: 'متن ورودی',
            hintText: 'متن را وارد کنید...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: translate,
          icon: const Icon(Icons.translate),
          label: const Padding(
            padding: EdgeInsets.all(12),
            child: Text('تبدیل متن'),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF202027),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.amber.shade700),
          ),
          child: Column(
            children: [
              const Text('خروجی هخامنش'),
              const SizedBox(height: 18),
              SelectableText(
                output.isEmpty ? '𐎱𐎠𐎼𐎿𐎡𐎣' : output,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: copyOutput,
                icon: const Icon(Icons.copy),
                label: const Text('کپی خروجی'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: openKeyboard,
          icon: const Icon(Icons.keyboard),
          label: const Text('انتخاب صفحه‌کلید هخامنش'),
        ),
        const SizedBox(height: 12),
        const Text(
          'توجه: تبدیل حروف، آوانویسی آزمایشی است و ترجمه معنایی کامل زبان نیست.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget dictionaryPage() {
    final query = search.text.trim();
    final items = dictionary.where((item) {
      return item['word']!.contains(query) ||
          item['meaning']!.contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'جست‌وجو در فرهنگ لغت...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  title: Text(
                    item['word']!,
                    style: const TextStyle(fontSize: 19),
                  ),
                  subtitle: Text(item['meaning']!),
                  trailing: Text(item['category']!),
                  onTap: () {
                    setState(() {
                      input.text = item['word']!;
                      page = 0;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget alphabetPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'الفبای هخامنش',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: alphabet.entries.map((entry) {
            return Container(
              width: 76,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF29272A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: Column(
                children: [
                  Text(entry.value, style: const TextStyle(fontSize: 30)),
                  Text(entry.key, style: const TextStyle(fontSize: 16)),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 25),
        const Text(
          'قواعد پایه زبان',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22),
        ),
        const SizedBox(height: 12),
        ...grammar.map((item) => Card(
          child: ListTile(
            title: Text(item['title']!),
            subtitle: Text(item['rule']!),
          ),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      translatorPage(),
      dictionaryPage(),
      alphabetPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '𐎠𐎡𐎢𐎣  هخامنش',
          style: TextStyle(color: Color(0xFFD5AC5B)),
        ),
        centerTitle: true,
      ),
      body: pages[page],
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (value) => setState(() => page = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.translate),
            label: 'مترجم',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book),
            label: 'فرهنگ لغت',
          ),
          NavigationDestination(
            icon: Icon(Icons.abc),
            label: 'الفبا و قواعد',
          ),
        ],
      ),
    );
  }
}
