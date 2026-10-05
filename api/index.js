const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

const automaticos = {
  minerador: {
    nome: 'Minerador',
    descricao: 'Minera ouro automaticamente.',
    custoBase: 100,
    crescimento: 1.35,
    producaoBase: 1,
  },
  fabrica: {
    nome: 'Fábrica',
    descricao: 'Produz moedas em escala industrial.',
    custoBase: 500,
    crescimento: 1.42,
    producaoBase: 5,
  },
  banco: {
    nome: 'Banco',
    descricao: 'Gera moedas a partir de investimentos.',
    custoBase: 2000,
    crescimento: 1.5,
    producaoBase: 20,
  },
};

const permanentes = {
  picaretaEficiente: {
    nome: 'Picareta eficiente',
    descricao: 'Aumenta permanentemente a força do clique para 2.',
    custo: 600,
    efeitos: {
      picaretaEficiente: true,
      poderClique: 2,
    },
  },
  franquia: {
    nome: 'Franquia',
    descricao: 'Dobra permanentemente a produção de cada Fábrica.',
    custo: 2500,
    efeitos: {
      franquia: true,
      producaoFabrica: 10,
    },
  },
  investidores: {
    nome: 'Investidores',
    descricao: 'Dobra permanentemente a produção de cada Banco.',
    custo: 8000,
    efeitos: {
      investidores: true,
      producaoBanco: 40,
    },
  },
};

function inteiroNaoNegativo(valor) {
  const numero = Number(valor);
  return Number.isInteger(numero) && numero >= 0 ? numero : null;
}

function custoAutomatico(tipo, quantidade) {
  const upgrade = automaticos[tipo];

  if (!upgrade) return null;

  return Math.round(
    upgrade.custoBase * Math.pow(upgrade.crescimento, quantidade)
  );
}

app.get('/automaticos/precos', (req, res) => {
  const mineradores = inteiroNaoNegativo(req.query.mineradores);
  const fabricas = inteiroNaoNegativo(req.query.fabricas);
  const bancos = inteiroNaoNegativo(req.query.bancos);

  if (mineradores === null || fabricas === null || bancos === null) {
    return res.status(400).json({
      erro: 'As quantidades dos upgrades automáticos são inválidas.',
    });
  }

  const quantidades = {
    minerador: mineradores,
    fabrica: fabricas,
    banco: bancos,
  };

  const resposta = Object.entries(automaticos).map(([tipo, upgrade]) => ({
    tipo,
    nome: upgrade.nome,
    descricao: upgrade.descricao,
    custo: custoAutomatico(tipo, quantidades[tipo]),
    producaoBase: upgrade.producaoBase,
  }));

  res.json({ automaticos: resposta });
});

app.post('/automaticos/comprar', (req, res) => {
  const { tipo } = req.body;
  const moedas = inteiroNaoNegativo(req.body.moedas);
  const quantidadeAtual = inteiroNaoNegativo(req.body.quantidadeAtual);

  if (!automaticos[tipo]) {
    return res.status(400).json({ erro: 'Upgrade automático inválido.' });
  }

  if (moedas === null || quantidadeAtual === null) {
    return res.status(400).json({ erro: 'Dados da compra inválidos.' });
  }

  const custo = custoAutomatico(tipo, quantidadeAtual);

  if (moedas < custo) {
    return res.status(400).json({ erro: 'Moedas insuficientes.' });
  }

  res.json({
    tipo,
    custo,
    moedas: moedas - custo,
    quantidade: quantidadeAtual + 1,
  });
});

app.get('/permanentes', (req, res) => {
  const resposta = Object.entries(permanentes).map(([tipo, upgrade]) => ({
    tipo,
    nome: upgrade.nome,
    descricao: upgrade.descricao,
    custo: upgrade.custo,
  }));

  res.json({ permanentes: resposta });
});

app.post('/permanentes/comprar', (req, res) => {
  const { tipo, jaComprado } = req.body;
  const moedas = inteiroNaoNegativo(req.body.moedas);
  const upgrade = permanentes[tipo];

  if (!upgrade) {
    return res.status(400).json({ erro: 'Upgrade permanente inválido.' });
  }

  if (moedas === null || typeof jaComprado !== 'boolean') {
    return res.status(400).json({ erro: 'Dados da compra inválidos.' });
  }

  if (jaComprado) {
    return res.status(409).json({ erro: 'Este upgrade já foi comprado.' });
  }

  if (moedas < upgrade.custo) {
    return res.status(400).json({ erro: 'Moedas insuficientes.' });
  }

  res.json({
    tipo,
    custo: upgrade.custo,
    moedas: moedas - upgrade.custo,
    efeitos: upgrade.efeitos,
  });
});

app.listen(3000, () => {
  console.log('API rodando em http://localhost:3000');
});
