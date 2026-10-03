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

app.post('/minerador/comprar', (req, res) => {
  const { moedas, mineradores } = req.body;

  const custo = Math.round(
    Math.pow(0.5 * (mineradores + 1), 2) * 100
    );

  if (moedas < custo) {
    return res.status(400).json({
      erro: 'Moedas insuficientes'
    });
  }

  res.json({
    moedas: moedas - custo,
    mineradores: mineradores + 1
  });
});

app.get('/minerador/:quantidade', (req, res) => {
  const quantidade = Number(req.params.quantidade);

  if (!Number.isInteger(quantidade) || quantidade < 0) {
    return res.status(400).json({
      erro: 'Quantidade inválida'
    });
  }

  const custo = Math.round(
    Math.pow(0.5 * (quantidade + 1), 2) * 100
    );

  res.json({
    quantidadeAtual: quantidade,
    custoProximo: custo
  });
});

app.listen(3000, () => {
  console.log('API rodando em http://localhost:3000');
});