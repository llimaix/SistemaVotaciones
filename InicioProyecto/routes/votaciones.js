const express = require('express');
const router = express.Router();
const db = require('../database/database');

function requireAuth(req, res, next) {
  if (!req.session.usuario) return res.redirect('/');
  next();
}

// Ver todas las votaciones
router.get('/', requireAuth, (req, res) => {
  const votaciones = db.prepare('SELECT * FROM votaciones').all();
  res.json(votaciones);
});

// Crear votación
router.post('/crear', requireAuth, (req, res) => {
  const { nombre, descripcion, fecha } = req.body;
  db.prepare('INSERT INTO votaciones (nombre, descripcion, fecha) VALUES (?, ?, ?)')
    .run(nombre, descripcion, fecha);
  res.redirect('/dashboard?msg=Votación creada correctamente');
});

// Eliminar votación
router.post('/eliminar/:id', requireAuth, (req, res) => {
  db.prepare('DELETE FROM votaciones WHERE id = ?').run(req.params.id);
  res.redirect('/dashboard?msg=Votación eliminada');
});

// Cambiar estado
router.post('/estado/:id', requireAuth, (req, res) => {
  const { estado } = req.body;
  db.prepare('UPDATE votaciones SET estado = ? WHERE id = ?').run(estado, req.params.id);
  res.redirect('/dashboard?msg=Estado actualizado');
});

module.exports = router;