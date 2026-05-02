import 'package:flutter/material.dart';
import 'package:gunun_sozleri_kerem_ilker/api_service.dart';
import 'package:gunun_sozleri_kerem_ilker/quote_model.dart';

void main() {
  runApp(const SozApp());
}

class SozApp extends StatelessWidget {
  const SozApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D6EFD), // Modern Dashboard Mavisi
          brightness: Brightness.light,
        ),
        // Genel Font Ailesini iyileştirebilirsin (isteğe bağlı)
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  final List<String> _kategoriler = ["Ayet", "Hadis", "Vecize"];

  // --- ŞIK DİALOG TASARIMLARI ---

  void _silmeOnayi(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.delete_sweep, color: Colors.red, size: 40),
        title: const Text("Kaydı Sil"),
        content: const Text("Bu sözü kalıcı olarak silmek istediğinize emin misiniz?", textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await _apiService.sozSil(id);
              if (mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text("Evet, Sil"),
          ),
        ],
      ),
    );
  }

  void _sozFormDialog({Soz? mevcutSoz}) {
    final formKey = GlobalKey<FormState>();
    final metinController = TextEditingController(text: mevcutSoz?.metin ?? "");
    final kaynakController = TextEditingController(text: mevcutSoz?.kaynak ?? "");
    String secilenKategori = mevcutSoz?.kategori ?? _kategoriler[0];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Row(
            children: [
              Icon(mevcutSoz == null ? Icons.add_circle : Icons.edit_note, color: Colors.blue),
              const SizedBox(width: 10),
              Text(mevcutSoz == null ? "Yeni Kayıt" : "Düzenle"),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: secilenKategori,
                    decoration: InputDecoration(
                      labelText: "Kategori",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: _kategoriler.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                    onChanged: (val) => setDialogState(() => secilenKategori = val!),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: metinController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Özlü Söz",
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: "Hikmetli bir söz yazın...",
                    ),
                    validator: (v) => v!.isEmpty ? "Lütfen bir metin girin" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: kaynakController,
                    decoration: InputDecoration(
                      labelText: "Kaynak / Müellif",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final yeniSoz = Soz(
                    id: mevcutSoz?.id,
                    kategori: secilenKategori,
                    metin: metinController.text,
                    kaynak: kaynakController.text,
                  );
                  bool sonuc = mevcutSoz == null 
                    ? await _apiService.sozEkle(yeniSoz) 
                    : await _apiService.sozGuncelle(mevcutSoz.id!, yeniSoz);
                  
                  if (sonuc && mounted) {
                    Navigator.pop(context);
                    setState(() {});
                  }
                }
              },
              child: const Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern açık gri/mavi arka plan
      appBar: AppBar(
        title: const Text("Kerem İLKER 149", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: FutureBuilder<List<Soz>>(
        future: _apiService.getSozler(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  const Text("Henüz hiç söz eklenmemiş.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final soz = snapshot.data![index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GestureDetector(
                    onLongPress: () => _silmeOnayi(soz.id!),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // Sol şerit (Kategoriye göre renk)
                          Container(
                            width: 6,
                            color: _getCategoryColor(soz.kategori),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(soz.kategori).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          soz.kategori.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _getCategoryColor(soz.kategori),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey, size: 20),
                                        onPressed: () => _sozFormDialog(mevcutSoz: soz),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    soz.metin,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1E293B),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.format_quote, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        soz.kaynak.isEmpty ? "Bilinmiyor" : soz.kaynak,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _sozFormDialog(),
        elevation: 4,
        label: const Text("Yeni Söz", style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  // Kategorilere göre farklı renkler döndüren yardımcı fonksiyon
  Color _getCategoryColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'ayet': return Colors.green.shade600;
      case 'hadis': return Colors.orange.shade700;
      case 'vecize': return Colors.blue.shade700;
      default: return Colors.blueGrey;
    }
  }
}