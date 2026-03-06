import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/islamic_background.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> with SingleTickerProviderStateMixin {
  static const _kCounter = "t_counter";
  static const _kCycle = "t_cycle";
  static const _kTarget = "t_target";
  static const _kZikr = "t_zikr";
  static const _kHaptics = "t_haptics";
  static const _kSound = "t_sound";

  int counter = 0;
  int cycle = 0;
  int target = 33;
  String zikr = "سبحان الله";
  bool enableHaptics = true;
  bool enableSound = true;

  final _player = AudioPlayer();
  late final AnimationController _tapAnim;

  final List<String> azkar = const [
    "سبحان الله", "الحمد لله", "الله أكبر", "لا إله إلا الله", 
    "استغفر الله", "سبحان الله وبحمده", "لاحول ولا قوة إلا بالله"
  ];

  @override
  void initState() {
    super.initState();
    _tapAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _load();
  }

  @override
  void dispose() {
    _tapAnim.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      counter = sp.getInt(_kCounter) ?? 0;
      cycle = sp.getInt(_kCycle) ?? 0;
      target = sp.getInt(_kTarget) ?? 33;
      zikr = sp.getString(_kZikr) ?? "سبحان الله";
      enableHaptics = sp.getBool(_kHaptics) ?? true;
      enableSound = sp.getBool(_kSound) ?? true;
    });
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kCounter, counter);
    await sp.setInt(_kCycle, cycle);
    await sp.setInt(_kTarget, target);
    await sp.setString(_kZikr, zikr);
    await sp.setBool(_kHaptics, enableHaptics);
    await sp.setBool(_kSound, enableSound);
  }

  Future<void> _playTapSound() async {
    if (!enableSound) return;
    try {
      await _player.stop();
      await _player.play(UrlSource('https://www.islamcan.com/audio/zikr/collections/real-tasbeeh/sounds/bead.mp3'), volume: 0.7);
    } catch (e) {
      debugPrint("Error playing tap sound: $e");
    }
  }

  void _onTapCounter() async {
    if (enableHaptics) HapticFeedback.lightImpact();
    _playTapSound();
    await _tapAnim.forward();
    await _tapAnim.reverse();
    setState(() {
      counter++;
      if (counter >= target) {
        counter = 0;
        cycle++;
        if (enableHaptics) HapticFeedback.mediumImpact();
      }
    });
    await _save();
  }

  void _reset() {
    setState(() { counter = 0; cycle = 0; });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final sw = constraints.maxWidth;
            final sh = constraints.maxHeight;

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. الهيدر الأخضر الفاخر
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: sh * 0.16,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D3B2E),
                      border: Border(bottom: BorderSide(color: Color(0xFFC19A6B), width: 2.5)),
                    ),
                    child: Stack(
                      children: [
                        Positioned(top: 15, right: 0, child: _buildDecorationImage(95)), 
                        Positioned(top: 15, left: 0, child: Transform.flip(flipX: true, child: _buildDecorationImage(95))),
                        
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.nightlight_round, color: Color(0xFFC19A6B), size: 30),
                                const SizedBox(width: 10),
                                Text("التسبيح", 
                                  style: GoogleFonts.amiri(
                                    fontSize: 48, 
                                    fontWeight: FontWeight.bold, 
                                    color: Colors.white,
                                    height: 1.1,
                                  )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. الكادر الذهبي
                Positioned.fill(
                  top: sh * 0.16,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFC19A6B).withOpacity(0.35), width: 1.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                // 3. الفوانيس
                Positioned(top: sh * 0.18, left: sw * 0.05, child: Image.asset("assets/images/tasbeeh/lantern.png", height: sh * 0.18)),
                Positioned(top: sh * 0.18, right: sw * 0.05, child: Image.asset("assets/images/tasbeeh/lantern.png", height: sh * 0.18)),

                // 4. اسم الذكر
                Positioned(
                  top: sh * 0.22, left: 0, right: 0,
                  child: Center(
                    child: Text(zikr, 
                      style: GoogleFonts.amiri(
                        fontSize: sw * 0.13, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        shadows: [const Shadow(color: Colors.black87, blurRadius: 20, offset: Offset(2, 2))]
                      )),
                  ),
                ),

                // 5. الماندالا والعداد (تغيير الخط للأميري واللون للبني)
                Positioned(
                  top: sh * 0.32, left: 0, right: 0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset("assets/images/tasbeeh/mandala.png", width: sw * 0.88),
                      Text("$counter", 
                        style: GoogleFonts.amiri(
                          fontSize: sw * 0.28, 
                          fontWeight: FontWeight.w900, 
                          color: const Color(0xFF42210B), 
                          shadows: [const Shadow(color: Colors.white24, blurRadius: 5, offset: Offset(1, 1))]
                        )),
                    ],
                  ),
                ),

                // 6. الإحصائيات (تغيير لون الكلمات من الأبيض للبني الخشبي)
                Positioned(
                  top: sh * 0.60, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2), // تغيير الخلفية لتناسب اللون البني
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.amiri(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: const Color(0xFF42210B), // اللون البني للكتابة
                          ),
                          children: [
                            const TextSpan(text: "الهدف: "),
                            TextSpan(text: "$target", style: const TextStyle(color: Color(0xFFB71C1C))), // لون مميز للرقم
                            const TextSpan(text: "  •  "),
                            const TextSpan(text: "الدورات: "),
                            TextSpan(text: "$cycle", style: const TextStyle(color: Color(0xFFB71C1C))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 7. زر التسبيح
                Positioned(
                  bottom: sh * 0.15,
                  left: 0, right: 0,
                  child: GestureDetector(
                    onTap: _onTapCounter,
                    child: AnimatedBuilder(
                      animation: _tapAnim,
                      builder: (context, child) => Transform.scale(
                        scale: 1.0 - _tapAnim.value,
                        child: Center(child: Image.asset("assets/images/tasbeeh/button_main.png", width: sw * 0.42)),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: sh * 0.05, left: sw * 0.08, right: sw * 0.08,
                  child: Row(
                    children: [
                      Expanded(child: GestureDetector(onTap: _reset, child: Image.asset("assets/images/tasbeeh/button_reset.png"))),
                      const SizedBox(width: 20),
                      Expanded(child: GestureDetector(onTap: _showZikrPicker, child: Image.asset("assets/images/tasbeeh/button_zikr.png"))),
                    ],
                  ),
                ),

                // أزرار النظام
                Positioned(top: 45, left: 15, child: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24), onPressed: () => context.go('/main-menu'))),
                Positioned(top: 45, right: 15, child: IconButton(icon: const Icon(Icons.settings, color: Colors.white, size: 28), onPressed: _showSettings)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDecorationImage(double size) {
    return Image.asset(
      "assets/images/tasbeeh/Gemini_Generated_Image_e03y1ze03y1ze03y (2).png", 
      width: size, 
      height: size,
      errorBuilder: (context, error, stackTrace) => const SizedBox(width: 95, height: 95),
    );
  }

  void _showZikrPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D3B2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("اختر الذكر", style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFFC19A6B))),
            const Divider(color: Colors.white10),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: azkar.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(azkar[index], textAlign: TextAlign.center, style: GoogleFonts.amiri(fontSize: 20, color: Colors.white)),
                  onTap: () { setState(() => zikr = azkar[index]); _save(); Navigator.pop(context); },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D3B2E),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("الإعدادات", style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFC19A6B))),
              SwitchListTile(title: Text("الاهتزاز", style: GoogleFonts.amiri(color: Colors.white)), value: enableHaptics, activeColor: const Color(0xFFC19A6B), onChanged: (v) { setSheet(() => enableHaptics = v); setState(() => enableHaptics = v); _save(); }),
              SwitchListTile(title: Text("الصوت", style: GoogleFonts.amiri(color: Colors.white)), value: enableSound, activeColor: const Color(0xFFC19A6B), onChanged: (v) { setSheet(() => enableSound = v); setState(() => enableSound = v); _save(); }),
              const Divider(color: Colors.white10),
              Text("تحديد الهدف", style: GoogleFonts.amiri(fontSize: 18, color: Colors.white70)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [33, 99, 1000].map((t) => ChoiceChip(
                  label: Text("$t"), selected: target == t, selectedColor: const Color(0xFFC19A6B),
                  onSelected: (s) { if(s) { setSheet(() => target = t); setState(() => target = t); _save(); } },
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
