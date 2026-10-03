const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/upgrade/:nivel', (req, res) => {
  const nivel = Number(req.params.nivel);

  if (!Number.isInteger(nivel) || nivel < 1) {
    return res.status(400).json({
      erro: 'Nível inválido'
    });
  }

  const custo = nivel * 100;
  const poderClique = nivel + 1;

  res.json({
    nivel: nivel,
    custo: custo,
    poderClique: poderClique
  });
});

app.post('/upgrade/comprar', (req, res) => {
  const { nivelAtual, moedas } = req.body;

  const proximoNivel = nivelAtual + 1;
  const custo = proximoNivel * 100;
  const poderClique = proximoNivel + 1;

  if (moedas < custo) {
    return res.status(400).json({
      erro: 'Moedas insuficientes'
    });
  }

  res.json({
    moedas: moedas - custo,
    nivel: proximoNivel,
    poderClique: poderClique
  });
});

app.listen(3000, () => {
  console.log('API rodando em http://localhost:3000');
});