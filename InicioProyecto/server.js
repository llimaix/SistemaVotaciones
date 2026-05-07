const express = require('express');
const session = require('express-session');
const path = require('path');

const app = express();
const PORT = 3000;

// Configuración
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));
app.use(session({
  secret: 'votaciones2024',
  resave: false,
  saveUninitialized: false
}));

// Rutas
const authRoutes = require('./routes/auth');
const usuariosRoutes = require('./routes/usuarios');
const votacionesRoutes = require('./routes/votaciones');
const mesasRoutes = require('./routes/mesas');
const resultadosRoutes = require('./routes/resultados');

app.use('/auth', authRoutes);
app.use('/usuarios', usuariosRoutes);
app.use('/votaciones', votacionesRoutes);
app.use('/mesas', mesasRoutes);
app.use('/resultados', resultadosRoutes);

// Página principal
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'views', 'login.html'));
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
// Dashboard
app.get('/dashboard', (req, res) => {
  if (!req.session.usuario) return res.redirect('/');
  res.sendFile(path.join(__dirname, 'views', 'dashboard.html'));
});