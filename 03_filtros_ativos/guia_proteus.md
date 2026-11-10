# Projetos do Proteus

Os três projetos já estão desenhados, simulados e com os dados exportados. Este arquivo registra o que há em cada um, para refazer ou alterar.

Em todos:

- **Base:** cópia de `02_resposta_em_frequencia/proteus/resposta_em_frequencia_tl081.pdsprj`. Os amplificadores são o símbolo LM741 com o modelo SPICE trocado em Edit Component (campos Part Value, SPICE Model e SPICE Library).
- **Entrada:** gerador senoidal `VIN`, 1 V de amplitude. É a referência do gráfico.
- **Alimentação:** +15 V e -15 V.
- **Gráfico:** FREQUENCY, Start `1`, Stop `200M`, 100 pontos por década, três traços de ganho no eixo esquerdo e os mesmos três de fase no direito.
- **Exportação dos dados:** botão direito na barra de título do gráfico, **Export Graph Data**, salvando na pasta `dados/`.
- **Imagem do esquemático:** **File > Export Graphics > Export Bitmap**, 200 DPI, 256 cores, Output To File. Os recortes estão em `imgs/simulacao/`.

## 1. `proteus/itens_1_2_passa_alta.pdsprj` → `dados/PASSA_ALTA.DAT`

| Componente | Valor | Liga de | Para |
|---|---:|---|---|
| C1 | 100 nF | VIN | nó RC |
| R5 | 6,8 kΩ | nó RC | terra |
| U1 (TL082, TEX301) | | entrada + no nó RC | saída U1(OP), ganho 3 |
| R1 ($R_f$) | 20 kΩ | saída de U1 | entrada - de U1 |
| R2 ($R_g$) | 10 kΩ | entrada - de U1 | terra |
| U2 (TL082, TEX301) | | entrada + no nó RC | saída U2(OP), ganho 30 |
| R3 ($R_f$) | 29 kΩ | saída de U2 | entrada - de U2 |
| R4 ($R_g$) | 1 kΩ | entrada - de U2 | terra |

Colunas exportadas: `U1(OP)`, `U2(OP)`, `RC`, depois as três fases na mesma ordem.

## 2. `proteus/item_3_passa_baixa.pdsprj` → `dados/PASSA_BAIXA.DAT`

| Componente | Valor | Liga de | Para |
|---|---:|---|---|
| R5 | 1,6 kΩ | VIN | nó RC |
| C2 | 10 nF | nó RC | terra |
| U1 (TL082, TEX301) | | entrada + no nó RC | saída U1(OP) |
| R1 ($R_f$) | 9 kΩ | saída de U1 | entrada - de U1 |
| R2 ($R_g$) | 1 kΩ | entrada - de U1 | terra |
| U2 (LM324/NS, NATOA) | | entrada + no nó RC | saída U2(OP) |
| R3 ($R_f$) | 9 kΩ | saída de U2 | entrada - de U2 |
| R4 ($R_g$) | 1 kΩ | entrada - de U2 | terra |

Colunas exportadas: `U1(OP)` (TL082), `U2(OP)` (LM324), `RC`, depois as três fases.

## 3. `proteus/item_4_quinta_ordem.pdsprj` → `dados/QUINTA_ORDEM.DAT`

Três estágios em cascata, todos com modelo TL082.

| Componente | Valor | Liga de | Para |
|---|---:|---|---|
| **Estágio 1** | | | |
| R7 | 16 kΩ | VIN | entrada + de U1 |
| C1 | 10 nF | entrada + de U1 | terra |
| R1 ($R_b$) | 20 kΩ | saída de U1 | entrada - de U1 |
| R2 ($R_a$) | 10 kΩ | entrada - de U1 | terra |
| **Estágio 2** | | | |
| R9 | 16 kΩ | saída de U1 | nó A2 |
| R8 | 16 kΩ | nó A2 | entrada + de U2 |
| C3 | 10 nF | nó A2 | saída de U2 |
| C2 | 10 nF | entrada + de U2 | terra |
| R3 ($R_b$) | 3,9 kΩ | saída de U2 | entrada - de U2 |
| R4 ($R_a$) | 10 kΩ | entrada - de U2 | terra |
| **Estágio 3** | | | |
| R11 | 16 kΩ | saída de U2 | nó A3 |
| R10 | 16 kΩ | nó A3 | entrada + de U3 |
| C5 | 10 nF | nó A3 | saída de U3 |
| C4 | 10 nF | entrada + de U3 | terra |
| R5 ($R_b$) | 13,8 kΩ | saída de U3 | entrada - de U3 |
| R6 ($R_a$) | 10 kΩ | entrada - de U3 | terra |

Colunas exportadas: `U1(OP)`, `U2(OP)`, `U3(OP)`, depois as três fases.

No Proteus o resistor de 13,8 kΩ é um componente só; na bancada são 12 kΩ e 1,8 kΩ em série. Os de 9 kΩ e 29 kΩ também são combinações na prática (18 kΩ ∥ 18 kΩ e 27 kΩ + 2 kΩ).

## Depois de exportar de novo

```
powershell -ExecutionPolicy Bypass -File scripts/gerar_graficos.ps1
```

O script lê os três `.DAT`, imprime a tabela "Proteus" com ganho, corte, fase e taxa de atenuação de cada curva e gera os gráficos `bode_sim_x_teoria_*.svg` em `imgs/geradas/`. A ordem das colunas de cada arquivo está em `scripts/colunas_dat.ps1`.
