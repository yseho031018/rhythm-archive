// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'harutalk_database.dart';

// ignore_for_file: type=lint
class $StoredDiaryEntriesTable extends StoredDiaryEntries
    with TableInfo<$StoredDiaryEntriesTable, StoredDiaryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredDiaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodNameMeta = const VerificationMeta(
    'moodName',
  );
  @override
  late final GeneratedColumn<String> moodName = GeneratedColumn<String>(
    'mood_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keywordsJsonMeta = const VerificationMeta(
    'keywordsJson',
  );
  @override
  late final GeneratedColumn<String> keywordsJson = GeneratedColumn<String>(
    'keywords_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _satisfactionMeta = const VerificationMeta(
    'satisfaction',
  );
  @override
  late final GeneratedColumn<int> satisfaction = GeneratedColumn<int>(
    'satisfaction',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSampleMeta = const VerificationMeta(
    'isSample',
  );
  @override
  late final GeneratedColumn<bool> isSample = GeneratedColumn<bool>(
    'is_sample',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_sample" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryDate,
    moodName,
    keywordsJson,
    satisfaction,
    summary,
    isSample,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_diary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredDiaryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('mood_name')) {
      context.handle(
        _moodNameMeta,
        moodName.isAcceptableOrUnknown(data['mood_name']!, _moodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_moodNameMeta);
    }
    if (data.containsKey('keywords_json')) {
      context.handle(
        _keywordsJsonMeta,
        keywordsJson.isAcceptableOrUnknown(
          data['keywords_json']!,
          _keywordsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_keywordsJsonMeta);
    }
    if (data.containsKey('satisfaction')) {
      context.handle(
        _satisfactionMeta,
        satisfaction.isAcceptableOrUnknown(
          data['satisfaction']!,
          _satisfactionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_satisfactionMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('is_sample')) {
      context.handle(
        _isSampleMeta,
        isSample.isAcceptableOrUnknown(data['is_sample']!, _isSampleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredDiaryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredDiaryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entry_date'],
      )!,
      moodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood_name'],
      )!,
      keywordsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keywords_json'],
      )!,
      satisfaction: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}satisfaction'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      isSample: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_sample'],
      )!,
    );
  }

  @override
  $StoredDiaryEntriesTable createAlias(String alias) {
    return $StoredDiaryEntriesTable(attachedDatabase, alias);
  }
}

class StoredDiaryEntry extends DataClass
    implements Insertable<StoredDiaryEntry> {
  final String id;
  final DateTime entryDate;
  final String moodName;
  final String keywordsJson;
  final int satisfaction;
  final String summary;
  final bool isSample;
  const StoredDiaryEntry({
    required this.id,
    required this.entryDate,
    required this.moodName,
    required this.keywordsJson,
    required this.satisfaction,
    required this.summary,
    required this.isSample,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_date'] = Variable<DateTime>(entryDate);
    map['mood_name'] = Variable<String>(moodName);
    map['keywords_json'] = Variable<String>(keywordsJson);
    map['satisfaction'] = Variable<int>(satisfaction);
    map['summary'] = Variable<String>(summary);
    map['is_sample'] = Variable<bool>(isSample);
    return map;
  }

  StoredDiaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return StoredDiaryEntriesCompanion(
      id: Value(id),
      entryDate: Value(entryDate),
      moodName: Value(moodName),
      keywordsJson: Value(keywordsJson),
      satisfaction: Value(satisfaction),
      summary: Value(summary),
      isSample: Value(isSample),
    );
  }

  factory StoredDiaryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredDiaryEntry(
      id: serializer.fromJson<String>(json['id']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      moodName: serializer.fromJson<String>(json['moodName']),
      keywordsJson: serializer.fromJson<String>(json['keywordsJson']),
      satisfaction: serializer.fromJson<int>(json['satisfaction']),
      summary: serializer.fromJson<String>(json['summary']),
      isSample: serializer.fromJson<bool>(json['isSample']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'moodName': serializer.toJson<String>(moodName),
      'keywordsJson': serializer.toJson<String>(keywordsJson),
      'satisfaction': serializer.toJson<int>(satisfaction),
      'summary': serializer.toJson<String>(summary),
      'isSample': serializer.toJson<bool>(isSample),
    };
  }

  StoredDiaryEntry copyWith({
    String? id,
    DateTime? entryDate,
    String? moodName,
    String? keywordsJson,
    int? satisfaction,
    String? summary,
    bool? isSample,
  }) => StoredDiaryEntry(
    id: id ?? this.id,
    entryDate: entryDate ?? this.entryDate,
    moodName: moodName ?? this.moodName,
    keywordsJson: keywordsJson ?? this.keywordsJson,
    satisfaction: satisfaction ?? this.satisfaction,
    summary: summary ?? this.summary,
    isSample: isSample ?? this.isSample,
  );
  StoredDiaryEntry copyWithCompanion(StoredDiaryEntriesCompanion data) {
    return StoredDiaryEntry(
      id: data.id.present ? data.id.value : this.id,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      moodName: data.moodName.present ? data.moodName.value : this.moodName,
      keywordsJson: data.keywordsJson.present
          ? data.keywordsJson.value
          : this.keywordsJson,
      satisfaction: data.satisfaction.present
          ? data.satisfaction.value
          : this.satisfaction,
      summary: data.summary.present ? data.summary.value : this.summary,
      isSample: data.isSample.present ? data.isSample.value : this.isSample,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredDiaryEntry(')
          ..write('id: $id, ')
          ..write('entryDate: $entryDate, ')
          ..write('moodName: $moodName, ')
          ..write('keywordsJson: $keywordsJson, ')
          ..write('satisfaction: $satisfaction, ')
          ..write('summary: $summary, ')
          ..write('isSample: $isSample')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entryDate,
    moodName,
    keywordsJson,
    satisfaction,
    summary,
    isSample,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredDiaryEntry &&
          other.id == this.id &&
          other.entryDate == this.entryDate &&
          other.moodName == this.moodName &&
          other.keywordsJson == this.keywordsJson &&
          other.satisfaction == this.satisfaction &&
          other.summary == this.summary &&
          other.isSample == this.isSample);
}

class StoredDiaryEntriesCompanion extends UpdateCompanion<StoredDiaryEntry> {
  final Value<String> id;
  final Value<DateTime> entryDate;
  final Value<String> moodName;
  final Value<String> keywordsJson;
  final Value<int> satisfaction;
  final Value<String> summary;
  final Value<bool> isSample;
  final Value<int> rowid;
  const StoredDiaryEntriesCompanion({
    this.id = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.moodName = const Value.absent(),
    this.keywordsJson = const Value.absent(),
    this.satisfaction = const Value.absent(),
    this.summary = const Value.absent(),
    this.isSample = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredDiaryEntriesCompanion.insert({
    required String id,
    required DateTime entryDate,
    required String moodName,
    required String keywordsJson,
    required int satisfaction,
    required String summary,
    this.isSample = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entryDate = Value(entryDate),
       moodName = Value(moodName),
       keywordsJson = Value(keywordsJson),
       satisfaction = Value(satisfaction),
       summary = Value(summary);
  static Insertable<StoredDiaryEntry> custom({
    Expression<String>? id,
    Expression<DateTime>? entryDate,
    Expression<String>? moodName,
    Expression<String>? keywordsJson,
    Expression<int>? satisfaction,
    Expression<String>? summary,
    Expression<bool>? isSample,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryDate != null) 'entry_date': entryDate,
      if (moodName != null) 'mood_name': moodName,
      if (keywordsJson != null) 'keywords_json': keywordsJson,
      if (satisfaction != null) 'satisfaction': satisfaction,
      if (summary != null) 'summary': summary,
      if (isSample != null) 'is_sample': isSample,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredDiaryEntriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? entryDate,
    Value<String>? moodName,
    Value<String>? keywordsJson,
    Value<int>? satisfaction,
    Value<String>? summary,
    Value<bool>? isSample,
    Value<int>? rowid,
  }) {
    return StoredDiaryEntriesCompanion(
      id: id ?? this.id,
      entryDate: entryDate ?? this.entryDate,
      moodName: moodName ?? this.moodName,
      keywordsJson: keywordsJson ?? this.keywordsJson,
      satisfaction: satisfaction ?? this.satisfaction,
      summary: summary ?? this.summary,
      isSample: isSample ?? this.isSample,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (moodName.present) {
      map['mood_name'] = Variable<String>(moodName.value);
    }
    if (keywordsJson.present) {
      map['keywords_json'] = Variable<String>(keywordsJson.value);
    }
    if (satisfaction.present) {
      map['satisfaction'] = Variable<int>(satisfaction.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (isSample.present) {
      map['is_sample'] = Variable<bool>(isSample.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredDiaryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('entryDate: $entryDate, ')
          ..write('moodName: $moodName, ')
          ..write('keywordsJson: $keywordsJson, ')
          ..write('satisfaction: $satisfaction, ')
          ..write('summary: $summary, ')
          ..write('isSample: $isSample, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoredCustomKeywordsTable extends StoredCustomKeywords
    with TableInfo<$StoredCustomKeywordsTable, StoredCustomKeyword> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredCustomKeywordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keywordMeta = const VerificationMeta(
    'keyword',
  );
  @override
  late final GeneratedColumn<String> keyword = GeneratedColumn<String>(
    'keyword',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [keyword, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_custom_keywords';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredCustomKeyword> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('keyword')) {
      context.handle(
        _keywordMeta,
        keyword.isAcceptableOrUnknown(data['keyword']!, _keywordMeta),
      );
    } else if (isInserting) {
      context.missing(_keywordMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {keyword};
  @override
  StoredCustomKeyword map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredCustomKeyword(
      keyword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keyword'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $StoredCustomKeywordsTable createAlias(String alias) {
    return $StoredCustomKeywordsTable(attachedDatabase, alias);
  }
}

class StoredCustomKeyword extends DataClass
    implements Insertable<StoredCustomKeyword> {
  final String keyword;
  final int sortOrder;
  const StoredCustomKeyword({required this.keyword, required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['keyword'] = Variable<String>(keyword);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  StoredCustomKeywordsCompanion toCompanion(bool nullToAbsent) {
    return StoredCustomKeywordsCompanion(
      keyword: Value(keyword),
      sortOrder: Value(sortOrder),
    );
  }

  factory StoredCustomKeyword.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredCustomKeyword(
      keyword: serializer.fromJson<String>(json['keyword']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'keyword': serializer.toJson<String>(keyword),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  StoredCustomKeyword copyWith({String? keyword, int? sortOrder}) =>
      StoredCustomKeyword(
        keyword: keyword ?? this.keyword,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  StoredCustomKeyword copyWithCompanion(StoredCustomKeywordsCompanion data) {
    return StoredCustomKeyword(
      keyword: data.keyword.present ? data.keyword.value : this.keyword,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredCustomKeyword(')
          ..write('keyword: $keyword, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(keyword, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredCustomKeyword &&
          other.keyword == this.keyword &&
          other.sortOrder == this.sortOrder);
}

class StoredCustomKeywordsCompanion
    extends UpdateCompanion<StoredCustomKeyword> {
  final Value<String> keyword;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const StoredCustomKeywordsCompanion({
    this.keyword = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredCustomKeywordsCompanion.insert({
    required String keyword,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : keyword = Value(keyword),
       sortOrder = Value(sortOrder);
  static Insertable<StoredCustomKeyword> custom({
    Expression<String>? keyword,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (keyword != null) 'keyword': keyword,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredCustomKeywordsCompanion copyWith({
    Value<String>? keyword,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return StoredCustomKeywordsCompanion(
      keyword: keyword ?? this.keyword,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (keyword.present) {
      map['keyword'] = Variable<String>(keyword.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredCustomKeywordsCompanion(')
          ..write('keyword: $keyword, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StorageMetadataTable extends StorageMetadata
    with TableInfo<$StorageMetadataTable, StorageMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StorageMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'storage_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<StorageMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  StorageMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StorageMetadataData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $StorageMetadataTable createAlias(String alias) {
    return $StorageMetadataTable(attachedDatabase, alias);
  }
}

class StorageMetadataData extends DataClass
    implements Insertable<StorageMetadataData> {
  final String key;
  final String value;
  const StorageMetadataData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  StorageMetadataCompanion toCompanion(bool nullToAbsent) {
    return StorageMetadataCompanion(key: Value(key), value: Value(value));
  }

  factory StorageMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StorageMetadataData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  StorageMetadataData copyWith({String? key, String? value}) =>
      StorageMetadataData(key: key ?? this.key, value: value ?? this.value);
  StorageMetadataData copyWithCompanion(StorageMetadataCompanion data) {
    return StorageMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StorageMetadataData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StorageMetadataData &&
          other.key == this.key &&
          other.value == this.value);
}

class StorageMetadataCompanion extends UpdateCompanion<StorageMetadataData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const StorageMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StorageMetadataCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<StorageMetadataData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StorageMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return StorageMetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StorageMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$HarutalkDatabase extends GeneratedDatabase {
  _$HarutalkDatabase(QueryExecutor e) : super(e);
  $HarutalkDatabaseManager get managers => $HarutalkDatabaseManager(this);
  late final $StoredDiaryEntriesTable storedDiaryEntries =
      $StoredDiaryEntriesTable(this);
  late final $StoredCustomKeywordsTable storedCustomKeywords =
      $StoredCustomKeywordsTable(this);
  late final $StorageMetadataTable storageMetadata = $StorageMetadataTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    storedDiaryEntries,
    storedCustomKeywords,
    storageMetadata,
  ];
}

typedef $$StoredDiaryEntriesTableCreateCompanionBuilder =
    StoredDiaryEntriesCompanion Function({
      required String id,
      required DateTime entryDate,
      required String moodName,
      required String keywordsJson,
      required int satisfaction,
      required String summary,
      Value<bool> isSample,
      Value<int> rowid,
    });
typedef $$StoredDiaryEntriesTableUpdateCompanionBuilder =
    StoredDiaryEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> entryDate,
      Value<String> moodName,
      Value<String> keywordsJson,
      Value<int> satisfaction,
      Value<String> summary,
      Value<bool> isSample,
      Value<int> rowid,
    });

class $$StoredDiaryEntriesTableFilterComposer
    extends Composer<_$HarutalkDatabase, $StoredDiaryEntriesTable> {
  $$StoredDiaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moodName => $composableBuilder(
    column: $table.moodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keywordsJson => $composableBuilder(
    column: $table.keywordsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get satisfaction => $composableBuilder(
    column: $table.satisfaction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSample => $composableBuilder(
    column: $table.isSample,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoredDiaryEntriesTableOrderingComposer
    extends Composer<_$HarutalkDatabase, $StoredDiaryEntriesTable> {
  $$StoredDiaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moodName => $composableBuilder(
    column: $table.moodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keywordsJson => $composableBuilder(
    column: $table.keywordsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get satisfaction => $composableBuilder(
    column: $table.satisfaction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSample => $composableBuilder(
    column: $table.isSample,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoredDiaryEntriesTableAnnotationComposer
    extends Composer<_$HarutalkDatabase, $StoredDiaryEntriesTable> {
  $$StoredDiaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get moodName =>
      $composableBuilder(column: $table.moodName, builder: (column) => column);

  GeneratedColumn<String> get keywordsJson => $composableBuilder(
    column: $table.keywordsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get satisfaction => $composableBuilder(
    column: $table.satisfaction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<bool> get isSample =>
      $composableBuilder(column: $table.isSample, builder: (column) => column);
}

class $$StoredDiaryEntriesTableTableManager
    extends
        RootTableManager<
          _$HarutalkDatabase,
          $StoredDiaryEntriesTable,
          StoredDiaryEntry,
          $$StoredDiaryEntriesTableFilterComposer,
          $$StoredDiaryEntriesTableOrderingComposer,
          $$StoredDiaryEntriesTableAnnotationComposer,
          $$StoredDiaryEntriesTableCreateCompanionBuilder,
          $$StoredDiaryEntriesTableUpdateCompanionBuilder,
          (
            StoredDiaryEntry,
            BaseReferences<
              _$HarutalkDatabase,
              $StoredDiaryEntriesTable,
              StoredDiaryEntry
            >,
          ),
          StoredDiaryEntry,
          PrefetchHooks Function()
        > {
  $$StoredDiaryEntriesTableTableManager(
    _$HarutalkDatabase db,
    $StoredDiaryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredDiaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoredDiaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoredDiaryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> entryDate = const Value.absent(),
                Value<String> moodName = const Value.absent(),
                Value<String> keywordsJson = const Value.absent(),
                Value<int> satisfaction = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<bool> isSample = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredDiaryEntriesCompanion(
                id: id,
                entryDate: entryDate,
                moodName: moodName,
                keywordsJson: keywordsJson,
                satisfaction: satisfaction,
                summary: summary,
                isSample: isSample,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime entryDate,
                required String moodName,
                required String keywordsJson,
                required int satisfaction,
                required String summary,
                Value<bool> isSample = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredDiaryEntriesCompanion.insert(
                id: id,
                entryDate: entryDate,
                moodName: moodName,
                keywordsJson: keywordsJson,
                satisfaction: satisfaction,
                summary: summary,
                isSample: isSample,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoredDiaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$HarutalkDatabase,
      $StoredDiaryEntriesTable,
      StoredDiaryEntry,
      $$StoredDiaryEntriesTableFilterComposer,
      $$StoredDiaryEntriesTableOrderingComposer,
      $$StoredDiaryEntriesTableAnnotationComposer,
      $$StoredDiaryEntriesTableCreateCompanionBuilder,
      $$StoredDiaryEntriesTableUpdateCompanionBuilder,
      (
        StoredDiaryEntry,
        BaseReferences<
          _$HarutalkDatabase,
          $StoredDiaryEntriesTable,
          StoredDiaryEntry
        >,
      ),
      StoredDiaryEntry,
      PrefetchHooks Function()
    >;
typedef $$StoredCustomKeywordsTableCreateCompanionBuilder =
    StoredCustomKeywordsCompanion Function({
      required String keyword,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$StoredCustomKeywordsTableUpdateCompanionBuilder =
    StoredCustomKeywordsCompanion Function({
      Value<String> keyword,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$StoredCustomKeywordsTableFilterComposer
    extends Composer<_$HarutalkDatabase, $StoredCustomKeywordsTable> {
  $$StoredCustomKeywordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoredCustomKeywordsTableOrderingComposer
    extends Composer<_$HarutalkDatabase, $StoredCustomKeywordsTable> {
  $$StoredCustomKeywordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoredCustomKeywordsTableAnnotationComposer
    extends Composer<_$HarutalkDatabase, $StoredCustomKeywordsTable> {
  $$StoredCustomKeywordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get keyword =>
      $composableBuilder(column: $table.keyword, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$StoredCustomKeywordsTableTableManager
    extends
        RootTableManager<
          _$HarutalkDatabase,
          $StoredCustomKeywordsTable,
          StoredCustomKeyword,
          $$StoredCustomKeywordsTableFilterComposer,
          $$StoredCustomKeywordsTableOrderingComposer,
          $$StoredCustomKeywordsTableAnnotationComposer,
          $$StoredCustomKeywordsTableCreateCompanionBuilder,
          $$StoredCustomKeywordsTableUpdateCompanionBuilder,
          (
            StoredCustomKeyword,
            BaseReferences<
              _$HarutalkDatabase,
              $StoredCustomKeywordsTable,
              StoredCustomKeyword
            >,
          ),
          StoredCustomKeyword,
          PrefetchHooks Function()
        > {
  $$StoredCustomKeywordsTableTableManager(
    _$HarutalkDatabase db,
    $StoredCustomKeywordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredCustomKeywordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoredCustomKeywordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StoredCustomKeywordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> keyword = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredCustomKeywordsCompanion(
                keyword: keyword,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String keyword,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => StoredCustomKeywordsCompanion.insert(
                keyword: keyword,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoredCustomKeywordsTableProcessedTableManager =
    ProcessedTableManager<
      _$HarutalkDatabase,
      $StoredCustomKeywordsTable,
      StoredCustomKeyword,
      $$StoredCustomKeywordsTableFilterComposer,
      $$StoredCustomKeywordsTableOrderingComposer,
      $$StoredCustomKeywordsTableAnnotationComposer,
      $$StoredCustomKeywordsTableCreateCompanionBuilder,
      $$StoredCustomKeywordsTableUpdateCompanionBuilder,
      (
        StoredCustomKeyword,
        BaseReferences<
          _$HarutalkDatabase,
          $StoredCustomKeywordsTable,
          StoredCustomKeyword
        >,
      ),
      StoredCustomKeyword,
      PrefetchHooks Function()
    >;
typedef $$StorageMetadataTableCreateCompanionBuilder =
    StorageMetadataCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$StorageMetadataTableUpdateCompanionBuilder =
    StorageMetadataCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$StorageMetadataTableFilterComposer
    extends Composer<_$HarutalkDatabase, $StorageMetadataTable> {
  $$StorageMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StorageMetadataTableOrderingComposer
    extends Composer<_$HarutalkDatabase, $StorageMetadataTable> {
  $$StorageMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StorageMetadataTableAnnotationComposer
    extends Composer<_$HarutalkDatabase, $StorageMetadataTable> {
  $$StorageMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$StorageMetadataTableTableManager
    extends
        RootTableManager<
          _$HarutalkDatabase,
          $StorageMetadataTable,
          StorageMetadataData,
          $$StorageMetadataTableFilterComposer,
          $$StorageMetadataTableOrderingComposer,
          $$StorageMetadataTableAnnotationComposer,
          $$StorageMetadataTableCreateCompanionBuilder,
          $$StorageMetadataTableUpdateCompanionBuilder,
          (
            StorageMetadataData,
            BaseReferences<
              _$HarutalkDatabase,
              $StorageMetadataTable,
              StorageMetadataData
            >,
          ),
          StorageMetadataData,
          PrefetchHooks Function()
        > {
  $$StorageMetadataTableTableManager(
    _$HarutalkDatabase db,
    $StorageMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StorageMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StorageMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StorageMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StorageMetadataCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => StorageMetadataCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StorageMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$HarutalkDatabase,
      $StorageMetadataTable,
      StorageMetadataData,
      $$StorageMetadataTableFilterComposer,
      $$StorageMetadataTableOrderingComposer,
      $$StorageMetadataTableAnnotationComposer,
      $$StorageMetadataTableCreateCompanionBuilder,
      $$StorageMetadataTableUpdateCompanionBuilder,
      (
        StorageMetadataData,
        BaseReferences<
          _$HarutalkDatabase,
          $StorageMetadataTable,
          StorageMetadataData
        >,
      ),
      StorageMetadataData,
      PrefetchHooks Function()
    >;

class $HarutalkDatabaseManager {
  final _$HarutalkDatabase _db;
  $HarutalkDatabaseManager(this._db);
  $$StoredDiaryEntriesTableTableManager get storedDiaryEntries =>
      $$StoredDiaryEntriesTableTableManager(_db, _db.storedDiaryEntries);
  $$StoredCustomKeywordsTableTableManager get storedCustomKeywords =>
      $$StoredCustomKeywordsTableTableManager(_db, _db.storedCustomKeywords);
  $$StorageMetadataTableTableManager get storageMetadata =>
      $$StorageMetadataTableTableManager(_db, _db.storageMetadata);
}
