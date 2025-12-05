const jsonServer = require('json-server');
const server = jsonServer.create();
const router = jsonServer.router('db.json');
const middlewares = jsonServer.defaults();

// Configuración para evitar problemas de CORS
server.use(middlewares);
server.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  next();
});

server.use(jsonServer.bodyParser);
server.use(router);

const PORT = 3000;
server.listen(PORT, () => {
  console.log(`JSON Server is running on http://localhost:${PORT}`);
  console.log('Endpoints disponibles:');
  console.log('  GET    /kahoots');
  console.log('  POST   /kahoots');
  console.log('  GET    /kahoots/:id');
  console.log('  PUT    /kahoots/:id');
  console.log('  DELETE /kahoots/:id');
  console.log('  GET    /themes');
});