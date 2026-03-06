import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_aaa/core/services/global_search_service.dart';
import 'package:projet_aaa/widgets/islamic_background.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final GlobalSearchService _searchService = GlobalSearchService();
  final TextEditingController _controller = TextEditingController();
  List<SearchResult> _results = [];
  bool _isLoading = false;

  void _onSearch(String query) async {
    if (query.length < 2) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isLoading = true);
    final results = await _searchService.search(query);
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: TextField(
            controller: _controller,
            onChanged: _onSearch,
            autofocus: true,
            style: GoogleFonts.amiri(color: Colors.white, fontSize: 20),
            decoration: InputDecoration(
              hintText: "ابحث في القرآن، التفسير، والأذكار...",
              hintStyle: GoogleFonts.amiri(color: Colors.white54, fontSize: 16),
              border: InputBorder.none,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
            : _results.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _results.length,
                    itemBuilder: (context, index) => _buildResultCard(_results[index]),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            _controller.text.isEmpty ? "ابدأ البحث الآن" : "لا توجد نتائج تطابق بحثك",
            style: GoogleFonts.amiri(color: Colors.white54, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(SearchResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        onTap: () => _handleNavigation(result),
        title: Row(
          children: [
            _buildTypeBadge(result.type),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                result.title,
                style: GoogleFonts.amiri(color: const Color(0xFFF5A623), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            result.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.amiri(color: Colors.white70, fontSize: 16),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    String label;
    switch (type) {
      case 'quran':
        color = Colors.green;
        label = "قرآن";
        break;
      case 'adhkar':
        color = Colors.blue;
        label = "أذكار";
        break;
      default:
        color = Colors.orange;
        label = "تفسير";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(5), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _handleNavigation(SearchResult result) {
    if (result.type == 'quran') {
      context.push('/ayah-tadabbur', extra: result.extra);
    } else if (result.type == 'adhkar') {
      // For now, go to adhkar home
      context.push('/adhkar');
    }
  }
}
