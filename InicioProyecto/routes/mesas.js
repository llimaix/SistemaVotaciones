const express = require('express');
const router = express.Router();
const db = require('../database/database');

function requireAuth(req, res, next) {
  if (!req.session.usuario) return res.redirect('/');
  next();
}

// Ver todas las mesas
router.get('/', requireAuth, (req, res) => {
  const mesas = db.prepare(`
    SELECT mesas.*, votaciones.nombre as votacion_nombre 
    FROM mesas 
    LEFT JOIN votaciones ON mesas.votacion_id = votaciones.id
  `).all();
  res.json(mesas);
});

// Crear mesa
router.post('/crear', requireAuth, (req, res) => {
  const { numero, ubicacion, votacion_id } = req.body;
  db.prepare('INSERT INTO mesas (numero, ubicacion, votacion_id) VALUES (?, ?, ?)')
    .run(numero, ubicacion, votacion_id);
  res.redirect('/dashboard?msg=Mesa creada correctamente');
});

// Eliminar mesa
router.post('/eliminar/:id', requireAuth, (req, res) => {
  db.prepare('DELETE FROM mesas WHERE id = ?').run(req.params.id);
  res.redirect('/dashboard?msg=Mesa eliminada');
});

module.exports = router;