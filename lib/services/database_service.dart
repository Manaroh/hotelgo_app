import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/reservation_model.dart';

/// Service responsable de la base de données locale SQLite.
///
/// Dans HotelGo, SQLite est utilisé pour gérer les réservations,
/// car elles nécessitent un vrai CRUD :
/// Create, Read, Update et Delete.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();

  DatabaseService._internal();

  static Database? _database;

  static const String _databaseName = 'hotelgo_database.db';
  static const int _databaseVersion = 2;

  static const String reservationsTable = 'reservations';

  /// Retourne l'instance de la base de données.
  ///
  /// Si la base existe déjà, on la réutilise.
  /// Sinon, on l'initialise.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  /// Initialise la base SQLite.
  ///
  /// Le fichier de base de données est créé dans le dossier local
  /// de l'application.
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crée la table des réservations lors du premier lancement.
  ///
  /// Le champ userEmail permet de séparer les réservations
  /// de chaque utilisateur.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $reservationsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userEmail TEXT NOT NULL,
        hotelId INTEGER NOT NULL,
        hotelName TEXT NOT NULL,
        city TEXT NOT NULL,
        pricePerNight REAL NOT NULL,
        customerName TEXT NOT NULL,
        checkInDate TEXT NOT NULL,
        checkOutDate TEXT NOT NULL,
        guests INTEGER NOT NULL,
        roomType TEXT NOT NULL,
        nights INTEGER NOT NULL,
        totalPrice REAL NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  /// Gère les changements de version de la base de données.
  ///
  /// La version 2 ajoute le champ userEmail pour rendre les réservations
  /// propres à chaque utilisateur.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final columns = await db.rawQuery(
        'PRAGMA table_info($reservationsTable)',
      );

      final hasUserEmail = columns.any(
        (column) => column['name'] == 'userEmail',
      );

      if (!hasUserEmail) {
        await db.execute(
          "ALTER TABLE $reservationsTable ADD COLUMN userEmail TEXT NOT NULL DEFAULT ''",
        );
      }
    }
  }

  /// Insère une nouvelle réservation dans SQLite.
  Future<int> insertReservation(ReservationModel reservation) async {
    final db = await database;

    return await db.insert(
      reservationsTable,
      reservation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère les réservations d'un utilisateur précis.
  ///
  /// Le filtre par userEmail garantit que chaque utilisateur voit
  /// uniquement ses propres réservations.
  Future<List<ReservationModel>> getReservationsByUser(
    String userEmail,
  ) async {
    final db = await database;

    final result = await db.query(
      reservationsTable,
      where: 'userEmail = ?',
      whereArgs: [userEmail.trim().toLowerCase()],
      orderBy: 'id DESC',
    );

    return result.map((map) => ReservationModel.fromMap(map)).toList();
  }

  /// Met à jour une réservation existante.
  ///
  /// La condition utilise l'id et l'email afin d'éviter de modifier
  /// une réservation appartenant à un autre compte.
  Future<int> updateReservation(ReservationModel reservation) async {
    final db = await database;

    return await db.update(
      reservationsTable,
      reservation.toMap(),
      where: 'id = ? AND userEmail = ?',
      whereArgs: [
        reservation.id,
        reservation.userEmail.trim().toLowerCase(),
      ],
    );
  }

  /// Supprime une réservation.
  ///
  /// Comme pour la modification, la suppression est sécurisée par id
  /// et par email utilisateur.
  Future<int> deleteReservation({
    required int id,
    required String userEmail,
  }) async {
    final db = await database;

    return await db.delete(
      reservationsTable,
      where: 'id = ? AND userEmail = ?',
      whereArgs: [
        id,
        userEmail.trim().toLowerCase(),
      ],
    );
  }
}