import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const ParsicApp());

class ParsicApp extends StatelessWidget {
  const ParsicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PARSIC',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101014),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC69B48),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final input = TextEditingController();
  String output = '';
  String mode = 'فارسی به پارسیک';

  static const Map<String, String> alphabet = {
    'ا':'𐎠','آ':'𐎠','a':'𐎠',
    'ب':'𐎲','پ':'𐎱',
    'ت':'𐎫','ث':'𐎰',
    'ج':'𐎩','چ':'𐎨',
    'ح':'𐎧','خ':'𐎧',
    'د':'𐎭','ذ':'𐎰',
    'ر':'𐎼','ز':'𐎹',
    'ژ':'𐎹','س':'𐎿',
    'ش':'𐏁','ص':'𐎿',
    'ض':'𐎭','ط':'𐎫',
    'ظ':'𐎹','ع':'𐎠',
    'غ':'𐎥','ف':'𐎱',
    'ق':'𐎣','ک':'𐎣',
    'گ':'𐎥','ل':'𐎴',
    'م':'𐎶','ن':'𐎴',
    'و':'𐎢','ه':'𐏃',
    'ی':'𐎡','ئ':'𐎡',
    ' ':'  ',
  };

  String translate(String text) {
    if (mode == 'فارسی به پارسیک') {
      return text.split('').map((c) => alphabet[c] ?? c).join();
    }

    final reverse = <String, String>{};
    alphabet.forEach((key, value) {
      if (key != ' ') reverse.putIfAbsent(value, () => key);
    });

    final result = StringBuffer();
    for (int i = 0; i < text.length;) {
      if (text.startsWith('  ', i)) {
        result.write(' ');
        i += 2;
      } else {
        final sign = text.substring(i, i + 1);
        result.write(reverse[sign] ?? sign);
        i++;
      }
    }
    return result.toString();
  }

  void convert() {
    setState(() => output = translate(input.text));
  }

  static const platform = MethodChannel('parsic/keyboard');

  Future<void> openKeyboard() async {
    try {
      await platform.invokeMethod('openKeyboard');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '𐎱𐎠𐎼𐎿𐎡𐎣  PARSIC',
          style: TextStyle(
            color: Color(0xFFD5AC5B),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 15),
          const Text(
            'زبان اختصاصی پارسیک',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'A NEW LANGUAGE INSPIRED BY OLD PERSIAN',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.amber, fontSize: 11),
          ),
          const SizedBox(height: 30),
          DropdownButtonFormField<String>(
            value: mode,
            decoration: const InputDecoration(
              labelText: 'جهت ترجمه',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'فارسی به پارسیک',
                child: Text('فارسی به پارسیک'),
              ),
              DropdownMenuItem(
                value: 'پارسیک به فارسی',
                child: Text('پارسیک به فارسی'),
              ),
            ],
            onChanged: (v) {
              setState(() {
                mode = v!;
                output = '';
              });
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: input,
            maxLines: 5,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              hintText: 'متن خود را وارد کنید...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          FilledButton(
            onPressed: convert,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('ترجمه کن'),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF202027),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.amber.shade700),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('نتیجه ترجمه'),
                const SizedBox(height: 15),
                SelectableText(
                  output.isEmpty ? '𐎱𐎠𐎼𐎿𐎡𐎣' : output,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: openKeyboard,
            icon: const Icon(Icons.keyboard),
            label: const Text('فعال‌سازی صفحه‌کلید پارسیک'),
          ),
          const SizedBox(height: 25),
          const Text(
            'الفبای پارسیک',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          const Text(
            '𐎠 𐎡 𐎢 𐎣 𐎥 𐎧 𐎩 𐎫 '
            '𐎭 𐎱 𐎲 𐎼 𐎿 𐏁 𐏃 𐎴 𐎶',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 27),
          ),
          const SizedBox(height: 25),
          const Text(
            'نسخه آزمایشی 1.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
