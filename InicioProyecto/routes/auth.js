const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const db = require('../database/database');

// Login
router.post('/login', (req, res) => {
  const { email, password } = req.body;
  const usuario = db.prepare('SELECT * FROM usuarios WHERE email = ?').get(email);

  if (!usuario || !bcrypt.compareSync(password, usuario.password)) {
    return res.redirect('/?error=Credenciales incorrectas');
  }

  req.session.usuario = usuario;
  res.redirect('/dashboard');
});

// Logout
router.get('/logout', (req, res) => {
  req.session.destroy();
  res.redirect('/');
});

module.exports = router;
