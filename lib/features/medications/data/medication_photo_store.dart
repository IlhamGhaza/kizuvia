import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Picks a photo and keeps a compressed copy (max 1280px, JPEG q80) in the
/// app documents folder. Only the local path is stored; cloud upload comes
/// with T2.11. Photos are health data: never written to logs.
class MedicationPhotoStore {
  MedicationPhotoStore([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Returns the stored path, or null if the user cancelled.
  Future<String?> pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 80,
    );
    if (picked == null) return null;
    final dir = Directory(
      p.join((await getApplicationDocumentsDirectory()).path, 'med_photos'),
    );
    await dir.create(recursive: true);
    final dest = p.join(dir.path, '${const Uuid().v4()}.jpg');
    await File(picked.path).copy(dest);
    return dest;
  }

  Future<void> delete(String? path) async {
    if (path == null) return;
    final f = File(path);
    if (f.existsSync()) await f.delete();
  }
}
