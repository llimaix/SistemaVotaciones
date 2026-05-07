const express = require('express');
const router = express.Router();
const db = require('../database/database');

function requireAuth(req, res, next) {
  if (!req.session.usuario) return res.redirect('/');
  next();
}

// Ver resultados de una votación
router.get('/:votacion_id', requireAuth, (req, res) => {
  const resultados = db.prepare(`
    SELECT resultados.*, mesas.numero as mesa_numero
    FROM resultados
    LEFT JOIN mesas ON resultados.mesa_id = mesas.id
    WHERE resultados.votacion_id = ?
  `).all(req.params.votacion_id);
  res.json(resultados);
});

// Registrar resultado
router.post('/registrar', requireAuth, (req, res) => {
  const { mesa_id, votacion_id, candidato, votos } = req.body;
  
  const existe = db.prepare(
    'SELECT * FROM resultados WHERE mesa_id = ? AND votacion_id = ? AND candidato = ?'
  ).get(mesa_id, votacion_id, candidato);

  if (existe) {
    db.prepare('UPDATE resultados SET votos = ? WHERE id = ?')
      .run(votos, existe.id);
  } else {
    db.prepare('INSERT INTO resultados (mesa_id, votacion_id, candidato, votos) VALUES (?, ?, ?, ?)')
      .run(mesa_id, votacion_id, candidato, votos);
  }

  res.redirect('/dashboard?msg=Resultado registrado correctamente');
});

// Consultar totales por votación
router.get('/totales/:votacion_id', requireAuth, (req, res) => {
  const totales = db.prepare(`
    SELECT candidato, SUM(votos) as total_votos
    FROM resultados
    WHERE votacion_id = ?
    GROUP BY candidato
    ORDER BY total_votos DESC
  `).all(req.params.votacion_id);
  res.json(totales);
});

module.exports = router;