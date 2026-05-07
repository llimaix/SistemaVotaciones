const Database = require('better-sqlite3');
const path = require('path');

const db = new Database(path.join(__dirname, 'votaciones.db'));

// Crear tablas
db.exec(`
  CREATE TABLE IF NOT EXISTS usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    rol TEXT DEFAULT 'operador'
  );

  CREATE TABLE IF NOT EXISTS votaciones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    fecha TEXT NOT NULL,
    estado TEXT DEFAULT 'activa'
  );

  CREATE TABLE IF NOT EXISTS mesas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    numero TEXT NOT NULL,
    ubicacion TEXT NOT NULL,
    votacion_id INTEGER,
    FOREIGN KEY (votacion_id) REFERENCES votaciones(id)
  );

  CREATE TABLE IF NOT EXISTS resultados (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mesa_id INTEGER,
    votacion_id INTEGER,
    candidato TEXT NOT NULL,
    votos INTEGER DEFAULT 0,
    FOREIGN KEY (mesa_id) REFERENCES mesas(id),
    FOREIGN KEY (votacion_id) REFERENCES votaciones(id)
  );
`);

// Crear admin por defecto
const adminExiste = db.prepare('SELECT * FROM usuarios WHERE email = ?').get('admin@votaciones.com');
if (!adminExiste) {
  const bcrypt = require('bcryptjs');
  const hash = bcrypt.hashSync('admin123', 10);
  db.prepare('INSERT INTO usuarios (nombre, email, password, rol) VALUES (?, ?, ?, ?)')
    .run('Administrador', 'admin@votaciones.com', hash, 'admin');
  console.log('Usuario admin creado: admin@votaciones.com / admin123');
}

module.exports = db;