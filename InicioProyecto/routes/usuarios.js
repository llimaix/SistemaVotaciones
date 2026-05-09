const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const db = require('../database/database');

// Middleware de autenticación
function requireAuth(req, res, next) {
  if (!req.session.usuario) return res.redirect('/');
  next();
}

// Ver todos los usuarios
router.get('/', requireAuth, (req, res) => {
  const usuarios = db.prepare('SELECT id, nombre, email, rol FROM usuarios').all();
  res.json(usuarios);
});

// Crear usuario
router.post('/crear', requireAuth, (req, res) => {
  const { nombre, email, password, rol } = req.body;
  const hash = bcrypt.hashSync(password, 10);
  try {
    db.prepare('INSERT INTO usuarios (nombre, email, password, rol) VALUES (?, ?, ?, ?)')
      .run(nombre, email, hash, rol);
    res.redirect('/dashboard?msg=Usuario creado correctamente');
  } catch (e) {
    res.redirect('/dashboard?error=El email ya existe');
  }
});

// Eliminar usuario
router.post('/eliminar/:id', requireAuth, (req, res) => {
  db.prepare('DELETE FROM usuarios WHERE id = ?').run(req.params.id);
  res.redirect('/dashboard?msg=Usuario eliminado');
});

module.exports = router;