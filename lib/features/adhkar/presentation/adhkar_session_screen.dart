import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:projet_aaa/widgets/islamic_background.dart';
import '../data/models/adhkar_model.dart';
import '../data/adhkar_data.dart';

class AdhkarSessionScreen extends StatefulWidget {
  final AthkarCategory category;
  const AdhkarSessionScreen({super.key, required this.category});

  @override
  State<AdhkarSessionScreen> createState() => _AdhkarSessionScreenState();
}

class _AdhkarSessionScreenState extends State<AdhkarSessionScreen> {
  late List<AthkarItem> items;
  int currentIndex = 0;
  int currentRepeat = 0;
  final PageController _pageController = PageController();
  
  // TTS Settings
  final FlutterTts _tts = FlutterTts();
  bool isAudioEnabled = true;
  double speechRate = 0.4; // هادئ وبطيء

  @override
  void initState() {
    super.initState();
    items = rawAthkarItems
        .where((i) => i['categoryId'] == widget.category.id)
        .map((i) => AthkarItem.fromJson(i))
        .toList();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("ar-SA");
    await _tts.setSpeechRate(speechRate);
    await _tts.setPitch(0.9);
    
    _tts.setCompletionHandler(() {
      if (mounted && isAudioEnabled) {
        _onAutoNext();
      }
    });

    // بدء القراءة للذكر الأول
    _speakCurrent();
  }

  void _speakCurrent() async {
    if (isAudioEnabled) {
      await _tts.stop();
      await _tts.setSpeechRate(speechRate);
      await _tts.speak(items[currentIndex].text);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _pageController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    _processStep();
  }

  void _onAutoNext() {
    // محاكاة النقرة عند انتهاء الصوت للانتقال التلقائي
    _processStep();
  }

  void _processStep() {
    setState(() {
      if (currentRepeat < items[currentIndex].repeat - 1) {
        currentRepeat++;
        _speakCurrent(); // إعادة القراءة إذا كان هناك تكرار
      } else {
        _nextItem();
      }
    });
  }

  void _nextItem() {
    if (currentIndex < items.length - 1) {
      setState(() {
        currentIndex++;
        currentRepeat = 0;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _speakCurrent();
    } else {
      _tts.stop();
      _showCompletionDialog();
    }
  }

  void _toggleAudio() {
    setState(() {
      isAudioEnabled = !isAudioEnabled;
      if (isAudioEnabled) {
        _speakCurrent();
      } else {
        _tts.stop();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D3B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تقبل الله منك', 
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(color: const Color(0xFFC19A6B), fontWeight: FontWeight.bold)),
        content: Text('لقد أتممت ${widget.category.title} بنجاح.',
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(color: Colors.white70)),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC19A6B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: Text('عودة', style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final item = items[currentIndex];
    final progress = (currentIndex + 1) / items.length;

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.category.title, 
            style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(isAudioEnabled ? Icons.volume_up : Icons.volume_off, color: const Color(0xFFF5A623)),
              onPressed: _toggleAudio,
            ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              color: const Color(0xFFF5A623),
              minHeight: 4,
            ),
            _buildAudioSettingsRow(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) => _buildItemCard(items[index]),
              ),
            ),
            _buildActionButtons(item),
            _buildCounterButton(item),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSettingsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.speed, color: Colors.white54, size: 18),
          const SizedBox(width: 8),
          Text('سرعة القراءة', style: GoogleFonts.amiri(color: Colors.white54, fontSize: 12)),
          Expanded(
            child: Slider(
              value: speechRate,
              min: 0.1, max: 0.8,
              activeColor: const Color(0xFFF5A623),
              inactiveColor: Colors.white10,
              onChanged: (v) {
                setState(() => speechRate = v);
                _tts.setSpeechRate(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(AthkarItem item) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.text,
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.6,
                ),
              ),
              if (item.reference != null) ...[
                const SizedBox(height: 20),
                Text('[ ${item.reference} ]', style: GoogleFonts.amiri(color: const Color(0xFFC19A6B), fontSize: 16)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(AthkarItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSmallButton(Icons.copy, () {
             Clipboard.setData(ClipboardData(text: item.text));
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ')));
          }),
          _buildSmallButton(Icons.replay, () => _speakCurrent()),
          _buildSmallButton(Icons.star_border, () {}),
        ],
      ),
    );
  }

  Widget _buildSmallButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }

  Widget _buildCounterButton(AthkarItem item) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: 140, height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFC19A6B), Color(0xFF8B6B4A)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: const Color(0xFFC19A6B).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text('${item.repeat - currentRepeat}', style: GoogleFonts.notoSans(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            Text('تبقّى', style: GoogleFonts.amiri(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
