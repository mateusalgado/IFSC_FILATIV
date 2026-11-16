# Filtros Ativos - IFSC

Trabalhos da unidade curricular Filtros Ativos (Engenharia Eletrônica, IFSC), Prof. Luis Carlos Martinhago Schlichting.

| Pasta | Trabalho | Relatório |
|---|---|---|
| `01_nao_idealidades/` | Atividade 01: impedância de saída, saturação e slew rate | `atividade_01_nao_idealidades.pdf` |
| `02_resposta_em_frequencia/` | Atividade 02: resposta em frequência do LM741 e do TL081 | `atividade_02_resposta_em_frequencia.pdf` |
| `03_filtros_ativos/` | Análise 01: filtros ativos de primeira e de quinta ordem | `analise_01_filtros_ativos.pdf` |
| `outros/` | Projetos avulsos do Proteus | |
| `contador_assincrono/` | Contador assíncrono de 0 a 10 (Proteus) | |

## Estrutura de cada trabalho

```
NN_nome/
  <relatorio>.md      texto do relatório
  <relatorio>.pdf     PDF gerado a partir do .md
  proteus/            projetos .pdsprj
  dados/              varreduras exportadas do Proteus (.DAT)
  scripts/            geração de gráficos e do PDF
  imgs/
    enunciado/        figuras do enunciado
    datasheet/        folhas de dados e recortes
    simulacao/        imagens exportadas do Proteus
    geradas/          gráficos criados pelos scripts
    protoboard/       fotos e telas de osciloscópio da bancada
```

Nem todo trabalho tem todas as pastas: a Atividade 01 não tem `dados/` nem `scripts/`.

## Regerar gráficos e PDF

A partir da pasta do trabalho, no PowerShell:

```
powershell -ExecutionPolicy Bypass -File scripts/gerar_graficos.ps1
powershell -ExecutionPolicy Bypass -File scripts/gerar_pdf.ps1
```

`gerar_graficos.ps1` lê os `.DAT` de `dados/` e grava os SVG em `imgs/geradas/`. `gerar_pdf.ps1` precisa do pandoc e do Microsoft Edge (ou do Node com Playwright, se instalado).

## Nomes

- Pastas e arquivos em minúsculas, sem espaços nem acentos, com `_` entre palavras.
- Os `.DAT` mantêm o nome em maiúsculas com que foram exportados do Proteus.
- Telas de osciloscópio: `<circuito>_<frequencia>.jpeg`.
