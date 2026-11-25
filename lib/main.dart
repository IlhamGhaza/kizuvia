import 'package:kizuvia/bootstrap.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  try {
    await bootstrap();
  } on Object catch (e) {
    // Never a blank screen: show the error type only (no data, docs/08).
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Kizuvia gagal dimulai (${e.runtimeType}). '
                'Tutup lalu buka lagi; jika berulang, laporkan kode ini.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
