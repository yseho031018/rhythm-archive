import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'harutalk_database.g.dart';

class StoredDiaryEntries extends Table {
  TextColumn get id => text()();

  DateTimeColumn get entryDate => dateTime()();

  TextColumn get moodName => text()();

  TextColumn get keywordsJson => text()();

  IntColumn get satisfaction => integer()();

  TextColumn get summary => text()();

  BoolColumn get isSample => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StoredCustomKeywords extends Table {
  TextColumn get keyword => text()();

  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {keyword};
}

class StorageMetadata extends Table {
  TextColumn get key => text()();

  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [StoredDiaryEntries, StoredCustomKeywords, StorageMetadata],
)
class HarutalkDatabase extends _$HarutalkDatabase {
  HarutalkDatabase(super.executor);

  HarutalkDatabase.defaults()
    : super(
        driftDatabase(
          name: 'harutalk',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 1;
}
