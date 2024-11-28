import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';

class HomeShowPage extends StatefulWidget {
  final int id;

  const HomeShowPage({super.key, required this.id});

  @override
  State<HomeShowPage> createState() => _HomeShowPageState();
}

class _HomeShowPageState extends State<HomeShowPage> {
  final String baseUrl = 'https://mobile-app.atko.tech/api/show/';
  final String imageUrlBase = 'https://mobile-app.atko.tech/images/';
  final box = GetStorage();
  bool isLoading = true;
  Map<String, dynamic>? item;

  @override
  void initState() {
    super.initState();
    fetchItemDetails();
  }

  Future<void> fetchItemDetails() async {
    final token = box.read('token');
    if (token == null) {
      Get.snackbar('Xatolik', 'Token topilmadi');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl${widget.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          item = json.decode(response.body);
          isLoading = false;
        });
      } else {
        Get.snackbar('Xatolik', 'Ma\'lumotlarni olib kelishda muammo yuz berdi.');
      }
    } catch (e) {
      Get.snackbar('Xatolik', 'Tarmoqda muammo yuz berdi.');
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return 'Noma\'lum';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ma\'lumot tafsilotlari',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : item == null
          ? const Center(
        child: Text(
          'Ma\'lumot topilmadi.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      '$imageUrlBase${item!['image']}',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          height: 200,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 100,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    item!['title'] ?? 'Noma\'lum',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Hudud: ${item!['refion'] ?? 'Noma\'lum'}',
                    style: const TextStyle(
                        fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Ma`lumot turi : ${item!['type'] ?? 'Noma\'lum'}',
                    style: const TextStyle(
                        fontSize: 18, color: Colors.black87),
                  ),
                  const Divider(
                    height: 32,
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  const Text(
                    'Tavsif:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 8.0),
                  HtmlWidget(
                    item!['description'] ?? 'Tavsif mavjud emas',
                    textStyle: const TextStyle(
                        fontSize: 16, color: Colors.black87),
                  ),
                  const Divider(
                    height: 32,
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: Colors.grey),
                      const SizedBox(width: 8.0),
                      Text(
                        'Tayyorlandi: ${formatDate(item!['created_at'] ?? '')}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
