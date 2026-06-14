import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class BackupFileService {
  const BackupFileService();

  static const maxBackupBytes = 5 * 1024 * 1024;

  Future<String?> pickBackup() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: '하루톡 백업 파일 선택',
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (result == null) return null;

    final file = result.files.single;
    if (file.size > maxBackupBytes) {
      throw const FormatException('백업 파일은 5MB 이하만 불러올 수 있어요.');
    }
    final bytes = file.bytes;
    if (bytes == null) {
      throw const FormatException('선택한 백업 파일을 읽지 못했어요.');
    }
    return utf8.decode(bytes);
  }

  Future<void> saveBackup(String json, DateTime now) async {
    final date =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    await FilePicker.saveFile(
      dialogTitle: '하루톡 백업 저장',
      fileName: 'harutalk-backup-$date.json',
      type: FileType.custom,
      allowedExtensions: const ['json'],
      bytes: Uint8List.fromList(utf8.encode(json)),
    );
  }
}
