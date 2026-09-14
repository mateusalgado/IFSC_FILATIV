# Atividade 01 – Não Idealidades em Amplificadores Operacionais

**Curso:** CST Eletrônica Industrial / Engenharia Eletrônica
**Unidade Curricular:** FIL221A06 – Filtros Ativos
**Professor:** Luis Carlos Martinhago Schlichting

---

## Objetivo

Ver na teoria e na simulação (e, na Parte 2, também na bancada) como algumas limitações reais dos ampops afetam um circuito: valor dos resistores de realimentação, carga na saída, saturação de tensão, limite de corrente de saída e slew rate.

Na Parte 1 foi usado o **LM741**. Na Parte 2 o LM741 (entrada bipolar) foi comparado com o **TL082** (entrada JFET). O TL082 é um TL081 duplo, com dois ampops no mesmo CI e as mesmas características.

---

# PARTE 1 – Impedância e Saturação

## 1.1 Circuito

![Figura 1](imgs/enunciado/figura1_impedancia_saturacao.png)

*Figura 1 – Circuito da Parte 1.*

São três amplificadores inversores (U1, U2 e U3) ligados na mesma fonte V1 (senoide de 1 kHz), com alimentação de ±15 V. A entrada não inversora de todos está no terra.

| Circuito | R_in | R_f | R_L (carga) | Ganho ideal $A_v = -R_f/R_{in}$ | Alimentação |
|----------|:----:|:---:|:-----------:|:--------------------------------:|:-----------:|
| U1 | R2 = 10 kΩ | R1 = 100 kΩ | R7 = 1 kΩ | −10 | ±15 V |
| U2 | R4 = 5 Ω | R3 = 50 Ω | R8 = 1 kΩ | −10 | ±15 V |
| U3 | R6 = 10 kΩ | R5 = 100 kΩ | R9 = 300 Ω | −10 | ±15 V |

Os três têm o mesmo ganho (−10), mas mudam em outras coisas:

- U1 e U2 têm a mesma carga, mas os resistores de U2 são de ohms e não de kΩ. Serve para ver o efeito de uma realimentação de baixa impedância.
- U1 e U3 têm a mesma realimentação, mas a carga de U3 é bem menor (300 Ω). Serve para ver o efeito da carga.

**Procedimento:**

1. Calcular o ganho de cada circuito.
2. Aplicar uma senoide de 1 kHz com 1 V de pico e medir a saída de U1, U2 e U3.
3. Repetir com 3 V de pico.
4. Ver se a limitação em cada caso é de tensão (alimentação) ou de corrente de saída.

---

## 1.2 Teoria

### Ganho

Com V⁺ no terra, pelo curto-circuito virtual V⁻ = 0 e:

$$I_{R_{in}} = \frac{V_{in}}{R_{in}} = I_{R_f} = \frac{-V_{out}}{R_f} \quad \Rightarrow \quad A_v = \frac{V_{out}}{V_{in}} = -\frac{R_f}{R_{in}}$$

$$A_{v,U1} = -\frac{100k}{10k} = -10 \qquad A_{v,U2} = -\frac{50}{5} = -10 \qquad A_{v,U3} = -\frac{100k}{10k} = -10$$

### Saturação de tensão

A saída não passa de mais ou menos `V_CC − 2 V`. Valores típicos do LM741 com ±15 V:

| Parâmetro (típico, LM741) | Valor |
|---------------------|:-----:|
| Excursão de saída (V_sat), R_L ≥ 2 kΩ | ≈ ±13 V |
| Corrente de curto-circuito na saída (I_sc) | ≈ 25 mA |
| Resistência de entrada (r_i) | ≈ 2 MΩ (mínimo 0,3 MΩ) |
| Resistência de saída em malha aberta (r_o) | ≈ 75 Ω |
| Ganho em malha aberta (A_VD) | 200 V/mV (mínimo 20 V/mV) |
| Corrente de polarização (I_B) | ≈ 80 nA |

Esses são os valores clássicos do 741 (datasheet µA741 da TI até a revisão G, de 2018). A revisão de 2026 do datasheet mudou vários típicos (I_sc = 80 mA, r_i = 540 GΩ, r_o = 575 Ω), provavelmente por causa de uma versão nova do CI. Aqui foram usados os valores clássicos, que são os que costumam aparecer nos livros.

### Limite de corrente

O ampop também tem um limite de corrente na saída (I_sc). A corrente que ele precisa fornecer é a da carga mais a da realimentação:

$$I_{out} = \frac{|V_{out}|}{R_L} + \frac{|V_{out}|}{R_f}$$

Se essa corrente chegar em I_sc antes de a saída chegar em V_sat, o circuito satura por corrente e a saída máxima fica:

$$V_{out,max} = \frac{I_{sc}}{\dfrac{1}{R_L} + \dfrac{1}{R_f}}$$

Ou seja, dois circuitos com o mesmo ganho podem saturar por motivos diferentes, dependendo dos valores de R_f e R_L.

### Impedâncias e o tamanho dos resistores

O ganho só depende da razão R_f/R_in, mas o valor absoluto dos resistores define as impedâncias que a fonte e o ampop enxergam.

**Impedância de entrada do circuito.** No inversor, a entrada V⁻ fica no terra virtual, então a fonte V1 enxerga só o R_in:

| Circuito | Impedância de entrada ($= R_{in}$) | Corrente pedida à fonte com Vp = 1 V |
|---|:---:|:---:|
| U1 | 10 kΩ | 0,1 mA |
| U2 | **5 Ω** | **200 mA** |
| U3 | 10 kΩ | 0,1 mA |

Em U2 a fonte teria que entregar 200 mA. No Proteus a fonte V1 é ideal e consegue, mas um gerador de funções real tem 50 Ω de impedância de saída. Com uma carga de 5 Ω, sobraria na entrada só $5/(50+5) \approx 9\%$ do sinal (1 V viraria uns 0,09 V). Ou seja, U2 já não funcionaria na prática antes mesmo de chegar no ampop.

**Carga vista pela saída do ampop.** A saída alimenta a carga R_L e também o R_f, que vai até o terra virtual. Os dois ficam em paralelo, então a carga total é $R_f \parallel R_L$, e a fórmula do limite de corrente fica simplesmente $V_{out,max} = I_{sc} \cdot (R_f \parallel R_L)$:

| Circuito | $R_f \parallel R_L$ | $V_{out,max}$ com I_sc = 25 mA | Resultado |
|---|:---:|:---:|---|
| U1 | 100k ∥ 1k = 990 Ω | 24,8 V | acima de V_sat → limita por tensão (≈ 13 V) |
| U2 | 50 ∥ 1k = 47,6 Ω | 1,19 V | limita por corrente |
| U3 | 100k ∥ 300 = 299 Ω | 7,48 V | limita por corrente |

O datasheet especifica a excursão de saída para R_L ≥ 2 kΩ. O gráfico de tensão máxima × carga do datasheet mostra que abaixo de 1 kΩ a excursão cai rápido: com 300 Ω fica em torno de ±7 a 8 V, o mesmo valor calculado para U3. A carga de U2 (47,6 Ω) é menor até que a própria resistência de saída do 741 em malha aberta (r_o ≈ 75 Ω).

**Resistência de saída com realimentação.** Enquanto o ampop está na região linear, a realimentação reduz a resistência de saída:

$$r_{out} = \frac{r_o}{1 + A\beta} \qquad \beta = \frac{R_{in}}{R_{in} + R_f} = \frac{1}{11}$$

Em 1 kHz o ganho do 741 em malha aberta é de uns $1\ \text{MHz} / 1\ \text{kHz} = 1000$, então $A\beta \approx 91$ e $r_{out} \approx 75/92 \approx 0{,}8\ \Omega$. Por isso, na região linear, a saída se comporta como uma fonte de tensão quase ideal e o r_o não atrapalha. O problema começa quando o ampop bate no limite de corrente. A partir daí ele não consegue mais corrigir a saída, a realimentação para de funcionar e a saída deixa de ser uma fonte de baixa impedância. É isso que acontece em U2 (ver 1.5).

**Por que também não usar resistores muito grandes.** O limite de cima vem da entrada do ampop:

- Os resistores precisam ser bem menores que r_i ≈ 2 MΩ. Senão, parte da corrente vai para dentro do ampop e o ganho erra.
- A corrente de polarização passa pelo R_f e gera um erro de offset $I_B \times R_f$. Com 100 kΩ isso dá 8 mV, que é pouco. Com 10 MΩ daria 0,8 V.

Por isso a faixa usual fica mais ou menos entre 1 kΩ e 100 kΩ:

| Circuito | R_in / R_f | Carga | Situação |
|---|---|---|---|
| U1 | 10 kΩ / 100 kΩ | 1 kΩ | dentro da faixa |
| U2 | 5 Ω / 50 Ω | 1 kΩ | muito abaixo da faixa (R_in é 200 vezes menor que 1 kΩ) |
| U3 | 10 kΩ / 100 kΩ | 300 Ω | resistores ok, mas carga abaixo dos 2 kΩ do datasheet |

### Valores esperados com Vp = 1 V (saída ideal de 10 V)

| Circuito | $I_{out}$ ideal (mA) | Limite atingido | $V_{out}$ esperado |
|----------|:---:|:---:|:---:|
| U1 | $10 \times (1/1k + 1/100k) = 10{,}1$ | nenhum (10,1 mA < 25 mA; 10 V < 13 V) | **−10 V** (linear) |
| U2 | $10 \times (1/1k + 1/50) = 210$ | corrente | $25m / (1/1k+1/50) \approx$ **−1,19 V** |
| U3 | $10 \times (1/300 + 1/100k) = 33{,}4$ | corrente | $25m / (1/300+1/100k) \approx$ **−7,48 V** |

Mesmo com sinal pequeno, U2 e U3 já passam do limite de corrente. Só U1 fica linear.

### Valores esperados com Vp = 3 V (saída ideal de 30 V)

| Circuito | Limite atingido | $V_{out}$ esperado | Tipo |
|----------|:---:|:---:|:---:|
| U1 | tensão (em 13 V a corrente é 13,1 mA, abaixo de 25 mA) | **≈ ±13 V** (onda ceifada) | saturação de tensão |
| U2 | corrente (mesmo cálculo de antes) | **≈ −1,19 V** | saturação de corrente |
| U3 | corrente (mesmo cálculo de antes) | **≈ −7,48 V** | saturação de corrente |

Para U2 e U3 o nível de saída deveria ser o mesmo em 1 V e em 3 V, porque o limite de corrente não depende da entrada. Aumentar a entrada só deixa a parte achatada da onda mais larga. U1 é o único que se comporta como o esperado nos livros: linear em 1 V e ceifado em ±13 V só em 3 V.

---

## 1.3 Simulação (Proteus, LM741)

A Parte 1 foi feita na teoria e na simulação. No osciloscópio do Proteus o canal A (amarelo, 2,07 V/div) é a saída de U1, o B (azul, 0,5 V/div) é U2 e o C (rosa, 1,2 V/div) é U3. A base de tempo é 0,1 ms/div. Os valores foram lidos na tela e conferidos com os cursores das Figuras 4 e 5.

![Figura 2](imgs/simulacao/U1_U2_U3_VP1V.png)

*Figura 2 – Simulação com Vp = 1 V. U1 = 10 V de pico, U3 = 9,54 V e U2 sobe até ≈ 1,5 V e depois cai para ≈ 0,75 V no pico da entrada.*

![Figura 3](imgs/simulacao/U1_U2_U3_VP3V.png)

*Figura 3 – Simulação com Vp = 3 V. U1 ceifa em +13,9/−13,6 V, U3 ceifa em ±9,78 V e U2 fica com ≈ 1,1 V de pico, em fase com a entrada.*

![Figura 4](imgs/simulacao/vp1.png)

*Figura 4 – Vp = 1 V, zoom no pico com cursores: U1 = 9,93 V, U3 = 9,54 V e U2 = 0,75 V.*

![Figura 5](imgs/simulacao/VP_U1.png)

*Figura 5 – Vp = 1 V, outra posição de cursor: U1 = 9,93 V e U3 = 9,51 V no pico; U2 = 1,50 V no "ombro" da onda.*

## 1.4 Resultados

| Circuito | Vp entrada | V_out teórico (I_sc = 25 mA) | V_out simulado | O que limitou |
|----------|:----------:|:--------------:|:---------------:|:---:|
| U1 | 1 V | −10 V | ±9,99 V | nada (linear) |
| U1 | 3 V | −13 V | +13,9 / −13,6 V | tensão |
| U2 | 1 V | −1,19 V | ±1,47 V, caindo para ±0,75 V no pico da entrada | corrente |
| U2 | 3 V | −1,19 V | ≈ ±1,1 V, em fase com a entrada | corrente |
| U3 | 1 V | −7,48 V | ±9,54 V (pico achatado) | corrente (começando) |
| U3 | 3 V | −7,48 V | ±9,78 V (topo plano) | corrente |

## 1.5 Análise

**U1** funcionou como esperado. Em 1 V de pico a saída é uma senoide de 10 V. Em 3 V ela ceifa em ≈ ±13,8 V, uns 1,2 V abaixo da alimentação. Nesse ponto a corrente é só $13{,}9 \times (1/1k + 1/100k) \approx 14$ mA, então a limitação é de tensão.

**U3** chegou a 9,54 V com 1 V de pico (o ideal era 10 V) e a 9,78 V com 3 V, com o topo plano. U1 e U3 têm a mesma alimentação e a mesma realimentação; a única diferença é a carga (1 kΩ e 300 Ω). Se U3 ceifa em 9,78 V enquanto U1 vai até 13,8 V, a diferença só pode vir da corrente puxada pela carga. Então é limite de corrente e não de tensão. O nível quase não mudou entre 1 V e 3 V, como a teoria previa.

Com 1 V de pico isso já aparece de leve: nos cursores da Figura 4, no mesmo instante, U1 marca 9,93 V e U3 marca 9,54 V, mesmo com o mesmo ganho. Na Figura 2 o pico de U3 fica mais achatado que uma senoide normal, enquanto o de U1 fica redondo.

O valor simulado ficou maior que os 7,48 V calculados. Isso acontece porque o modelo do 741 no Proteus aguenta mais corrente que os 25 mA usados na conta. Dá para calcular esse limite com os próprios resultados:

| Onde | Cálculo | I_sc |
|---|---|:---:|
| U3 com Vp = 3 V | $9{,}78 \times (1/300 + 1/100k)$ | 32,7 mA |
| U3 com Vp = 1 V | $9{,}54 \times (1/300 + 1/100k)$ | 31,9 mA |
| U2 no início da limitação | $1{,}47 \times (1/1k + 1/50)$ | 30,9 mA |

Usando I_sc ≈ 32 mA, a fórmula dá:

$$V_{out,max,U2} = \frac{32m}{1/1k + 1/50} \approx 1{,}52\ \text{V} \qquad V_{out,max,U3} = \frac{32m}{1/300 + 1/100k} \approx 9{,}57\ \text{V}$$

Isso bate com a simulação. Então a teoria estava certa, só o valor de I_sc era diferente.

**U2** teve um comportamento que não estava previsto. A saída sobe até ≈ 1,5 V e depois cai para 0,75 V justamente quando a entrada está no máximo. Com 3 V a saída fica em fase com a entrada, sendo que o circuito é inversor.

O motivo é que, quando o ampop entra no limite de corrente, ele deixa de manter o terra virtual. Como R4 + R3 = 55 Ω é um valor muito baixo, a própria fonte V1 passa a jogar corrente direto na saída.

Isso é consequência direta das impedâncias vistas na teoria. A impedância de entrada de U2 é de só 5 Ω, e a carga que a saída enxerga (47,6 Ω) é menor que o próprio r_o do 741. Enquanto o ampop consegue fornecer a corrente, a realimentação segura a saída. Quando ele chega no limite, quem manda na saída é a fonte, através dos resistores de 55 Ω. Em U1 e U3 isso não acontece: com R_in = 10 kΩ, a corrente que vem da fonte é desprezível.

## Conclusão – Parte 1

Os três circuitos têm o mesmo ganho, mas cada um se comportou de um jeito:

- U1 foi o único "normal": linear com sinal pequeno e ceifado na tensão da alimentação com sinal grande.
- U3 saturou por corrente por causa da carga de 300 Ω. A carga também limita o circuito, não só a alimentação.
- U2 saturou por corrente logo com sinal pequeno. Além disso, com resistores tão baixos a fonte de entrada acabou controlando a saída, a ponto de inverter a fase com 3 V.

Na simulação o limite de corrente do 741 ficou em ≈ 32 mA. Com esse valor as contas batem com o que foi visto.

O valor dos resistores importa, e não só a razão entre eles. Resistores muito baixos (como em U2) pedem corrente demais da fonte e do ampop. Resistores muito altos esbarram na resistência de entrada (≈ 2 MΩ) e no erro por corrente de polarização. Com o 741, uma faixa segura fica entre 1 kΩ e 100 kΩ, com carga de 2 kΩ ou mais, como pede o datasheet. U1 está dentro dessa faixa, U2 está muito abaixo e U3 tem uma carga pequena demais.

---

# PARTE 2 – Slew Rate (SR)

## 2.1 Circuito

![Figura 6](imgs/enunciado/figura2_slew_rate.png)

*Figura 6 – Circuito da Parte 2.*

São dois seguidores de tensão (ganho 1) ligados na mesma entrada, alimentados com ±12 V:

| | U1 | U2 |
|---|:---:|:---:|
| CI | TL082 | LM741 |
| Configuração | seguidor (ganho = 1) | seguidor (ganho = 1) |
| Alimentação | ±12 V | ±12 V |
| Entrada | a mesma nos dois | a mesma nos dois |

**Testes feitos:**

| Teste | Simulação (Proteus) | Bancada |
|---|---|---|
| Pulso de 0 a 5 V | 100 kHz a 1 MHz | 1, 10, 25 e 30 kHz |
| Pulso de 0 a 3 V | 1 kHz e 50 kHz | 1, 10, 25, 30 e 50 kHz |
| Senoide | 3 V de pico (6 Vpp), 10 kHz a 1 MHz | 3 Vpp (1,5 V de pico), 25 kHz a 2 MHz |

## 2.2 Teoria

O slew rate é a velocidade máxima com que a saída do ampop consegue variar:

$$SR = \left. \frac{dV_{out}}{dt} \right|_{max}$$

Ele depende da corrente que carrega o capacitor de compensação interno do CI. Se a entrada muda mais rápido que isso (como um pulso com bordas de 10 ns), a saída sobe em rampa e o tempo de subida passa a depender só do SR:

$$\Delta t = \frac{\Delta V}{SR}$$

Para os dois pulsos usados:

$$\Delta t_{741}(5\ V) = \frac{5}{0{,}5} = 10\ \mu s \qquad \Delta t_{TL082}(5\ V) = \frac{5}{13} \approx 0{,}385\ \mu s$$

$$\Delta t_{741}(3\ V) = \frac{3}{0{,}5} = 6{,}0\ \mu s \qquad \Delta t_{TL082}(3\ V) = \frac{3}{13} \approx 0{,}231\ \mu s$$

Em 1 kHz o semiperíodo é de 500 µs, então os dois chegam no valor final. A diferença é que a rampa do 741 aparece no osciloscópio e a do TL082 fica quase vertical.

**Onda quadrada:** quando o tempo de subida fica perto do semiperíodo, a saída não chega mais no valor final e a onda vira um triângulo. O limite é:

$$f_{max} = \frac{SR}{2 \cdot \Delta V}$$

$$f_{max,741}(5\ V) = 50\ \text{kHz} \qquad f_{max,TL082}(5\ V) = 1{,}3\ \text{MHz}$$

$$f_{max,741}(3\ V) \approx 83\ \text{kHz} \qquad f_{max,TL082}(3\ V) \approx 2{,}17\ \text{MHz}$$

**Senoide:** para $v(t) = V_p \sin(\omega t)$ a maior inclinação é $\omega V_p$. A frequência máxima sem distorção (FPBW) é:

$$f_{FPBW} = \frac{SR}{2\pi V_p}$$

Na simulação a senoide foi de 3 V de pico e na bancada de 1,5 V de pico (3 Vpp):

$$f_{FPBW,741}(V_p = 3\ V) \approx 26{,}5\ \text{kHz} \qquad f_{FPBW,TL082}(V_p = 3\ V) \approx 689{,}7\ \text{kHz}$$

$$f_{FPBW,741}(V_p = 1{,}5\ V) \approx 53{,}1\ \text{kHz} \qquad f_{FPBW,TL082}(V_p = 1{,}5\ V) \approx 1{,}38\ \text{MHz}$$

Acima da FPBW a senoide fica triangular, mesmo sem chegar perto da alimentação. O triângulo tem amplitude $\Delta V_{pp} = SR \cdot T/2$, que diminui conforme a frequência aumenta. Então aqui a limitação é de velocidade e não de tensão como na Parte 1.

| Parâmetro | LM741 | TL082 | TL082 / 741 |
|-----------|:-----:|:-----:|:---:|
| Slew rate | 0,5 V/µs | 13 V/µs | 26× |
| Δt para 5 V | 10 µs | 0,385 µs | 26× menor |
| Δt para 3 V | 6,0 µs | 0,231 µs | 26× menor |
| f_max onda quadrada de 5 V | 50 kHz | 1,3 MHz | 26× |
| f_max onda quadrada de 3 V | 83 kHz | 2,17 MHz | 26× |
| FPBW senoide de 3 Vp (simulação) | 26,5 kHz | 689,7 kHz | 26× |
| FPBW senoide de 1,5 Vp (bancada) | 53,1 kHz | 1,38 MHz | 26× |
| Entrada | bipolar | JFET | – |
| GBW | 1 MHz | 3 MHz | 3× |

## 2.3 Simulação (Proteus)

Nas telas da simulação aparecem a entrada (canal A, amarelo) e a saída do TL082 (canal C, rosa). A entrada da simulação tem bordas ideais, então a rampa que aparece na saída é só do TL082. O 741 foi avaliado pelas medidas de bancada (item 2.4).

O SR foi medido entre 10 % e 90 % da subida e da descida, contando os pixels na tela (20 px por divisão). Cada pixel vale entre 25 e 39 ns, dependendo da base de tempo, então cada medida tem erro de uns ±10 %.

**Pulso:**

| f | Amplitude (escala) | Base de tempo | Saída do TL082 | SR 10–90 % (subida / descida) | Figura |
|:---:|:---:|:---:|---|:---:|:---:|
| 1 kHz | 0 → 3 V (0,2 V/div) | 77,9 µs/div | igual à entrada (a rampa de 0,3 µs não aparece nessa escala) | – | 7 |
| 50 kHz | 0 → 3 V (0,2 V/div) | 0,78 µs/div | rampa de ≈ 0,25 µs com um pequeno overshoot | 12,3 / 12,3 V/µs | 8 |
| 100 kHz | 0 → 5 V (0,5 V/div) | 0,62 µs/div | trapézio, ≈ 0,47 µs da base ao topo | 12,8 / 14,2 V/µs | 9 |
| 200 kHz | 0 → 5 V (0,5 V/div) | 0,62 µs/div | trapézio | 11,6 / 12,8 V/µs | 10 |
| 500 kHz | 0 → 5 V (0,5 V/div) | 0,5 µs/div | trapézio com topo de só ≈ 0,5 µs | 12,3 / 13,3 V/µs | 11 |
| 1 MHz | 0 → 5 V (0,5 V/div) | 0,5 µs/div | triângulo que mal chega em 5 V | 13,3 / 13,3 V/µs | 12 |
| **Média** | | | | **12,8 V/µs** | |

**Senoide de 3 V de pico (6 Vpp, 0,5 V/div):**

| f | Inclinação máxima exigida ($2\pi f V_p$) | Saída do TL082 | Figura |
|:---:|:---:|---|:---:|
| 10 kHz | 0,19 V/µs | igual à entrada | 13 |
| 100 kHz | 1,9 V/µs | igual à entrada | 14 |
| 200 kHz | 3,8 V/µs | igual à entrada | 15 |
| 500 kHz | 9,4 V/µs | igual, com um atraso bem pequeno | 16 |
| 1 MHz | 18,8 V/µs | atrasada, com os lados mais retos e ≈ 5,5 Vpp (−8 %) | 17 |

![Figura 7](imgs/simulacao/sr_pulso_TL082_741_1khz.png)

*Figura 7 – Simulação, pulso de 1 kHz. Entrada (amarelo) e TL082 (rosa) coincidem nessa escala.*

![Figura 8](imgs/simulacao/sr_pulso_TL082_741_50khz.png)

*Figura 8 – Simulação, pulso de 50 kHz (0,78 µs/div). Rampa do TL082 de ≈ 12 V/µs.*

![Figura 9](imgs/simulacao/sr_pulso_TL082_741_100khz.png)

*Figura 9 – Simulação, pulso de 5 V em 100 kHz. Bordas do TL082 com ≈ 0,47 µs.*

![Figura 10](imgs/simulacao/sr_pulso_TL082_741_200khz.png)

*Figura 10 – Simulação, pulso de 5 V em 200 kHz.*

![Figura 11](imgs/simulacao/sr_pulso_TL082_741_500khz.png)

*Figura 11 – Simulação, pulso de 5 V em 500 kHz. O topo fica mais curto.*

![Figura 12](imgs/simulacao/sr_pulso_TL082_741_1Mhz.png)

*Figura 12 – Simulação, pulso de 5 V em 1 MHz. A saída do TL082 vira triângulo.*

![Figura 13](imgs/simulacao/sr_senoide_3vp_10khz.png)

*Figura 13 – Simulação, senoide de 3 Vp em 10 kHz.*

![Figura 14](imgs/simulacao/sr_senoide_3vp_100khz.png)

*Figura 14 – Simulação, senoide de 3 Vp em 100 kHz.*

![Figura 15](imgs/simulacao/sr_senoide_3vp_200khz.png)

*Figura 15 – Simulação, senoide de 3 Vp em 200 kHz.*

![Figura 16](imgs/simulacao/sr_senoide_3vp_500khz.png)

*Figura 16 – Simulação, senoide de 3 Vp em 500 kHz. O TL082 ainda acompanha a entrada.*

![Figura 17](imgs/simulacao/sr_senoide_3vp_1Mhz.png)

*Figura 17 – Simulação, senoide de 3 Vp em 1 MHz. Saída atrasada e menor por causa do slew rate.*

## 2.4 Bancada

Os testes foram feitos em 31/08/2026, com os dois seguidores montados em protoboard. Equipamentos: osciloscópio Tektronix TDS 2024C, gerador de funções Tektronix e fonte simétrica (o display mostrava 11,9 V e 11,6 V).

![Figura 18](imgs/protoboard/parte2_bancada.jpeg)

*Figura 18 – Montagem da Parte 2 na bancada.*

Canais usados em todas as fotos:

| Canal | Cor | Sinal |
|:---:|:---:|---|
| CH1 | amarelo | saída do LM741 |
| CH2 | ciano | saída do TL082 |
| CH3 | roxo | entrada (só no teste com senoide) |

O SR foi calculado como ΔV/Δt entre os dois cursores, colocados na parte reta da rampa de subida.

### Pulso de 0 a 5 V

| f | Canal | Δt (µs) | ΔV (V) | ΔV/Δt (V/µs) | Figura |
|:---:|---|:---:|:---:|:---:|:---:|
| 1 kHz | CH1 – 741 | 6,30 | 2,15 | 0,341 | 20 |
| 1 kHz | CH2 – TL082 | 6,30 | 2,62 | 0,416 | 21 |
| 10 kHz | CH1 – 741 | 6,30 | 2,15 | 0,341 | 23 |
| 10 kHz | CH2 – TL082 | 6,30 | 2,59 | 0,411 | 24 |
| 25 kHz | CH1 – 741 | 7,40 | 2,53 | 0,342 | 26 |
| 25 kHz | CH2 – TL082 | 7,40 | 3,00 | 0,405 | 27 |
| 30 kHz | CH1 – 741 | 7,40 | 2,53 | 0,342 | 28 |
| 30 kHz | CH2 – TL082 | 7,40 | 3,00 | 0,405 | 29 |
| **Média** | **CH1 – 741** | | | **0,342** | |
| **Média** | **CH2 – TL082** | | | **0,409**¹ | |

¹ No CH2 a inclinação medida não é o SR do TL082 (ver item 2.6).

Em 1 kHz o osciloscópio mediu 5,02 Vpp no CH1, 5,06 Vpp no CH2 e média de 2,53 V no CH2 (duty de 50 %), confirmando o ganho 1 dos dois seguidores. Em 25 kHz o topo do 741 fica com uns 5 µs e em 30 kHz com uns 2 µs.

![Figura 19](imgs/protoboard/5V/p2_5V_1kHz_visao_geral.jpeg)

*Figura 19 – Pulso de 5 V, 1 kHz, visão geral (250 µs/div). CH1 = 5,02 Vpp e CH2 = 5,06 Vpp.*

![Figura 20](imgs/protoboard/5V/p2_5V_1kHz_ch1_741.jpeg)

*Figura 20 – Pulso de 5 V, 1 kHz, subida (2,5 µs/div). Cursores no CH1 (741): 2,15 V / 6,3 µs = 0,341 V/µs.*

![Figura 21](imgs/protoboard/5V/p2_5V_1kHz_ch2_tl082.jpeg)

*Figura 21 – Pulso de 5 V, 1 kHz. Cursores no CH2 (TL082): 2,62 V / 6,3 µs = 0,416 V/µs.*

![Figura 22](imgs/protoboard/5V/p2_5V_10kHz_visao_geral.jpeg)

*Figura 22 – Pulso de 5 V, 10 kHz, visão geral (10 µs/div).*

![Figura 23](imgs/protoboard/5V/p2_5V_10kHz_ch1_741.jpeg)

*Figura 23 – Pulso de 5 V, 10 kHz. Cursores no CH1 (741): 2,15 V / 6,3 µs = 0,341 V/µs.*

![Figura 24](imgs/protoboard/5V/p2_5V_10kHz_ch2_tl082.jpeg)

*Figura 24 – Pulso de 5 V, 10 kHz. Cursores no CH2 (TL082): 2,59 V / 6,3 µs = 0,411 V/µs.*

![Figura 25](imgs/protoboard/5V/p2_5V_25kHz_visao_geral.jpeg)

*Figura 25 – Pulso de 5 V, 25 kHz, visão geral (5 µs/div). O topo do 741 (amarelo) já é mais curto que o do TL082.*

![Figura 26](imgs/protoboard/5V/p2_5V_25kHz_ch1_741.jpeg)

*Figura 26 – Pulso de 5 V, 25 kHz. Cursores no CH1 (741): 2,53 V / 7,4 µs = 0,342 V/µs.*

![Figura 27](imgs/protoboard/5V/p2_5V_25kHz_ch2_tl082.jpeg)

*Figura 27 – Pulso de 5 V, 25 kHz. Cursores no CH2 (TL082): 3,00 V / 7,4 µs = 0,405 V/µs.*

![Figura 28](imgs/protoboard/5V/p2_5V_30kHz_ch1_741.jpeg)

*Figura 28 – Pulso de 5 V, 30 kHz. Cursores no CH1 (741): 2,53 V / 7,4 µs = 0,342 V/µs. O topo do 741 dura só uns 2 µs.*

![Figura 29](imgs/protoboard/5V/p2_5V_30kHz_ch2_tl082.jpeg)

*Figura 29 – Pulso de 5 V, 30 kHz. Cursores no CH2 (TL082): 3,00 V / 7,4 µs = 0,405 V/µs.*

### Pulso de 0 a 3 V

| f | Canal | Δt (µs) | ΔV (V) | ΔV/Δt (V/µs) | Figura |
|:---:|---|:---:|:---:|:---:|:---:|
| 1 kHz | CH1 – 741 | 48,0 | 1,06 | 0,022² | 31 |
| 1 kHz | CH2 – TL082 | 48,0 | 1,92 | 0,040² | 32 |
| 10 kHz | CH1 – 741 | 5,20 | 1,78 | 0,342 | 34 |
| 10 kHz | CH2 – TL082 | 5,20 | 2,16 | 0,415 | 35 |
| 25 kHz | CH1 – 741 | 4,96 | 1,58 | 0,319 | 37 |
| 25 kHz | CH2 – TL082 | 4,56 | 1,80 | 0,395 | 38 |
| 30 kHz | CH1 – 741 | 6,00 | 2,04 | 0,340 | 39 |
| 30 kHz | CH2 – TL082 | 4,20 | 1,70 | 0,405 | 40 |
| 50 kHz | CH1 – 741 | 4,20 | 1,49 | 0,355 | 41 |
| 50 kHz | CH2 – TL082 | 4,20 | 1,75 | 0,417 | 42 |
| **Média (10 a 50 kHz)** | **CH1 – 741** | | | **0,339** | |
| **Média (10 a 50 kHz)** | **CH2 – TL082** | | | **0,408**¹ | |

¹ No CH2 a inclinação medida não é o SR do TL082 (ver item 2.6).
² Em 1 kHz as duas saídas ficaram iguais, com bordas arredondadas de uns 90 µs (Figuras 30 a 32). Quem limitou ali foi a borda do próprio sinal de entrada, e não os ampops: o 741 subiria 3 V em uns 9 µs. Por isso essas duas medidas ficaram fora da média.

Em 1 kHz o osciloscópio mediu 3,02 Vpp nos dois canais (média do CH2 = 1,41 V). Em 25 kHz mediu 3,30 Vpp no CH1 e 3,34 Vpp no CH2 (contando os picos das transições), com média do CH2 = 1,28 V. Em 50 kHz a saída do 741 já é quase triangular.

![Figura 30](imgs/protoboard/3V/p2_3V_1kHz_visao_geral.jpeg)

*Figura 30 – Pulso de 3 V, 1 kHz, visão geral (250 µs/div). CH1 = CH2 = 3,02 Vpp, com bordas arredondadas iguais nos dois canais.*

![Figura 31](imgs/protoboard/3V/p2_3V_1kHz_ch1_741.jpeg)

*Figura 31 – Pulso de 3 V, 1 kHz (100 µs/div). Cursores no CH1 (741): 1,06 V / 48 µs. A transição é lenta nos dois canais.*

![Figura 32](imgs/protoboard/3V/p2_3V_1kHz_ch2_tl082.jpeg)

*Figura 32 – Pulso de 3 V, 1 kHz. Cursores no CH2 (TL082): 1,92 V / 48 µs.*

![Figura 33](imgs/protoboard/3V/p2_3V_10kHz_visao_geral.jpeg)

*Figura 33 – Pulso de 3 V, 10 kHz, visão geral (25 µs/div).*

![Figura 34](imgs/protoboard/3V/p2_3V_10kHz_ch1_741.jpeg)

*Figura 34 – Pulso de 3 V, 10 kHz (2,5 µs/div). Cursores no CH1 (741): 1,78 V / 5,2 µs = 0,342 V/µs.*

![Figura 35](imgs/protoboard/3V/p2_3V_10kHz_ch2_tl082.jpeg)

*Figura 35 – Pulso de 3 V, 10 kHz. Cursores no CH2 (TL082): 2,16 V / 5,2 µs = 0,415 V/µs.*

![Figura 36](imgs/protoboard/3V/p2_3V_25kHz_visao_geral.jpeg)

*Figura 36 – Pulso de 3 V, 25 kHz, visão geral (10 µs/div). CH1 = 3,30 Vpp e CH2 = 3,34 Vpp.*

![Figura 37](imgs/protoboard/3V/p2_3V_25kHz_ch1_741.jpeg)

*Figura 37 – Pulso de 3 V, 25 kHz (1 µs/div). Cursores no CH1 (741): 1,58 V / 4,96 µs = 0,319 V/µs.*

![Figura 38](imgs/protoboard/3V/p2_3V_25kHz_ch2_tl082.jpeg)

*Figura 38 – Pulso de 3 V, 25 kHz. Cursores no CH2 (TL082): 1,80 V / 4,56 µs = 0,395 V/µs.*

![Figura 39](imgs/protoboard/3V/p2_3V_30kHz_ch1_741.jpeg)

*Figura 39 – Pulso de 3 V, 30 kHz (5 µs/div). Cursores no CH1 (741): 2,04 V / 6,0 µs = 0,340 V/µs.*

![Figura 40](imgs/protoboard/3V/p2_3V_30kHz_ch2_tl082.jpeg)

*Figura 40 – Pulso de 3 V, 30 kHz. Cursores no CH2 (TL082): 1,70 V / 4,2 µs = 0,405 V/µs.*

![Figura 41](imgs/protoboard/3V/p2_3V_50kHz_ch1_741.jpeg)

*Figura 41 – Pulso de 3 V, 50 kHz (5 µs/div). Cursores no CH1 (741): 1,49 V / 4,2 µs = 0,355 V/µs. A onda já é quase triangular.*

![Figura 42](imgs/protoboard/3V/p2_3V_50kHz_ch2_tl082.jpeg)

*Figura 42 – Pulso de 3 V, 50 kHz. Cursores no CH2 (TL082): 1,75 V / 4,2 µs = 0,417 V/µs.*

### Senoide de 3 Vpp (0 a 3 V, 1,5 V de pico)

Nesse teste o CH3 (roxo) mostra a entrada. A amplitude de 3 Vpp foi lida na tela.

| f | Inclinação máxima exigida ($2\pi f V_p$) | LM741 (CH1) | TL082 (CH2) | Figura |
|:---:|:---:|---|---|:---:|
| 25 kHz | 0,24 V/µs | senoide sem distorção, em cima da entrada | sem distorção | 43 |
| 50 kHz | 0,47 V/µs | lados retos (começa a triangular); cursores: 2,20 V / 6,4 µs = **0,344 V/µs** | igual à entrada | 44 |
| 100 kHz | 0,94 V/µs | triângulo de ≈ 1,7 Vpp; cursores: 1,28 V / 3,7 µs = **0,346 V/µs** | igual à entrada | 45 |
| 500 kHz | 4,71 V/µs | triângulo de ≈ 0,3 Vpp | senoide com amplitude cheia; 2,36 V / 580 ns = 4,1 V/µs | 46 |
| 1 MHz | 9,42 V/µs | quase uma linha reta | senoide com amplitude cheia e pequeno atraso; 1,80 V / 210 ns = 8,6 V/µs | 47 |
| 2 MHz | 18,8 V/µs | linha reta | lados começando a ficar retos e atraso visível; 2,34 V / 156 ns = **15,0 V/µs** | 48 |

![Figura 43](imgs/protoboard/SEN/p2_sen_25kHz_visao_geral.jpeg)

*Figura 43 – Senoide de 3 Vpp, 25 kHz (5 µs/div). Entrada (roxo), 741 (amarelo) e TL082 (ciano) um em cima do outro, sem distorção.*

![Figura 44](imgs/protoboard/SEN/p2_sen_50kHz_ch1_741.jpeg)

*Figura 44 – Senoide de 3 Vpp, 50 kHz (2,5 µs/div). O 741 começa a ficar triangular. Cursores no CH1: 2,20 V / 6,4 µs = 0,344 V/µs.*

![Figura 45](imgs/protoboard/SEN/p2_sen_100kHz_ch1_741.jpeg)

*Figura 45 – Senoide de 3 Vpp, 100 kHz. O 741 vira um triângulo de ≈ 1,7 Vpp. Cursores no CH1: 1,28 V / 3,7 µs = 0,346 V/µs. O TL082 continua igual à entrada.*

![Figura 46](imgs/protoboard/SEN/p2_sen_500kHz_ch2_tl082.jpeg)

*Figura 46 – Senoide de 3 Vpp, 500 kHz (250 ns/div). O 741 cai para ≈ 0,3 Vpp e o TL082 segue a entrada (cursores no CH2: 2,36 V / 580 ns).*

![Figura 47](imgs/protoboard/SEN/p2_sen_1MHz_ch2_tl082.jpeg)

*Figura 47 – Senoide de 3 Vpp, 1 MHz (250 ns/div). O 741 fica praticamente parado e o TL082 mantém a amplitude, com um pequeno atraso (cursores no CH2: 1,80 V / 210 ns).*

![Figura 48](imgs/protoboard/SEN/p2_sen_2MHz_ch2_tl082.jpeg)

*Figura 48 – Senoide de 3 Vpp, 2 MHz (100 ns/div). Os lados da onda do TL082 ficam retos (cursores no CH2: 2,34 V / 156 ns ≈ 15 V/µs). Ele está começando a ser limitado pelo slew rate.*

## 2.5 Resultados

**LM741** (tudo medido na bancada):

| Grandeza | Teórico | Obtido | Como foi obtido | Desvio |
|----------|:-------:|:------:|---|:------:|
| SR | 0,5 V/µs | **0,34 V/µs** | média de 10 medidas com cursor (pulso de 5 V, pulso de 3 V e senoide) | −32 % |
| Δt de subida (5 V) | 10 µs | 14,6 µs | 5 V ÷ SR medido | +46 % |
| Δt de subida (3 V) | 6,0 µs | 8,9 µs | 3 V ÷ SR medido | +48 % |
| f_max onda quadrada de 5 V | 50 kHz | ≈ 34 kHz | SR medido; em 30 kHz ainda chega em 5 V com ≈ 2 µs de topo | −32 % |
| f_max onda quadrada de 3 V | 83 kHz | ≈ 57 kHz | SR medido; em 50 kHz já é quase triangular | −32 % |
| FPBW senoide de 1,5 Vp | 53,1 kHz | entre 25 e 50 kHz (≈ 36 kHz pelo SR medido) | observado na senoide | ≈ −32 % |

**TL082** (simulação com pulso e senoide de 3 Vp; bancada com senoide de 1,5 Vp):

| Grandeza | Teórico | Obtido | Como foi obtido | Desvio |
|----------|:-------:|:------:|---|:------:|
| SR | 13 V/µs | **≈ 12,8 V/µs** | simulação, média de 10 bordas do pulso (10 a 90 %) | −2 % |
| SR | 13 V/µs | **≈ 15 V/µs** | bancada, inclinação da senoide de 2 MHz³ | ≈ +15 % |
| Δt de subida (5 V) | 0,385 µs | ≈ 0,39 µs | simulação, 5 V ÷ SR simulado (de 10 a 90 %: 0,31 µs) | ≈ +1 % |
| Δt de subida (3 V) | 0,231 µs | ≈ 0,24 µs | simulação, pulso de 3 V em 50 kHz | ≈ +4 % |
| f_max onda quadrada de 5 V | 1,3 MHz | ≈ 1 MHz | simulação; em 1 MHz a saída já é triangular | ≈ −23 % |
| FPBW senoide de 3 Vp | 689,7 kHz | entre 500 kHz e 1 MHz | simulação | dentro da faixa |
| FPBW senoide de 1,5 Vp | 1,38 MHz | entre 1 e 2 MHz | bancada | dentro da faixa |

³ Inclinação dos lados da senoide (2,34 V em 156 ns) na frequência em que eles começam a ficar retos. Como a saída ainda chega na amplitude cheia, é uma estimativa por baixo do SR.

**SR do LM741 em cada teste:**

| Teste | SR medido | Diferença para a média |
|---|:---:|:---:|
| Pulso de 5 V (4 medidas) | 0,342 V/µs | 0 % |
| Pulso de 3 V (4 medidas) | 0,339 V/µs | −1 % |
| Senoide de 3 Vpp (2 medidas) | 0,345 V/µs | +1 % |
| **Média** | **0,341 V/µs** | |
| Datasheet (típico) | 0,5 V/µs | |

## 2.6 Análise

**LM741.** O SR foi o mesmo nos três testes (0,339 a 0,345 V/µs), mesmo mudando a amplitude, a frequência e a forma de onda. Isso mostra que o SR é uma característica do CI e não do sinal. O valor ficou uns 32 % abaixo do típico do datasheet. O datasheet traz só o valor típico, medido com ±15 V (aqui foram ±12 V), e cada CI varia um pouco.

A amplitude só muda o tempo gasto na rampa: com 5 V o 741 leva 14,6 µs para subir e com 3 V leva 8,9 µs. Com isso a onda quadrada vira triângulo em ≈ 34 kHz com 5 V e em ≈ 57 kHz com 3 V. A bancada mostrou exatamente isso:
- com 5 V, em 30 kHz (semiperíodo de 16,7 µs), sobram só uns 2 µs de topo;
- com 3 V, em 50 kHz (semiperíodo de 10 µs), a onda já é quase triangular.

Ou seja, quanto menor a excursão, maior a frequência que o ampop consegue acompanhar.

Com a senoide de 1,5 V de pico, o 741 distorceu entre 25 e 50 kHz, o que bate com os ≈ 36 kHz calculados com o SR medido. Os triângulos em 100 kHz (≈ 1,7 Vpp) e em 500 kHz (≈ 0,3 Vpp) também batem com $SR \cdot T/2$: 0,341 × 5 µs = 1,71 Vpp e 0,341 × 1 µs = 0,34 Vpp. Isso é mais uma confirmação de SR ≈ 0,34 V/µs, agora pela amplitude e não pela inclinação.

**TL082 na simulação.** Com borda ideal na entrada, a média das 10 bordas deu 12,8 V/µs, praticamente o valor do datasheet. Em 1 MHz o semiperíodo (0,5 µs) é quase o tempo que o TL082 leva para subir 5 V, e a onda quadrada vira triângulo, perto dos 1,3 MHz calculados. Com a senoide de 3 V de pico, a saída acompanhou a entrada até 500 kHz (9,4 V/µs exigidos). Em 1 MHz, que exige 18,8 V/µs, ela ficou atrasada e menor. Então a FPBW simulada fica entre 500 kHz e 1 MHz, o que confere com os 689,7 kHz calculados.

**TL082 na bancada.** Com a senoide de 1,5 V de pico, a saída continuou senoidal até 1 MHz, o que exige pelo menos 9,4 V/µs. Em 2 MHz os lados começam a ficar retos, com inclinação de ≈ 15 V/µs, perto dos 13 V/µs do datasheet e dos 12,8 V/µs da simulação. A FPBW medida fica entre 1 e 2 MHz (teórica de 1,38 MHz). O atraso de fase que aparece em 1 e 2 MHz vem do GBW de 3 MHz do TL082: nessas frequências o seguidor já está perto do limite de banda.

No teste de pulso da bancada, a rampa do TL082 (CH2) ficou em ≈ 0,41 V/µs com 5 V e com 3 V, bem abaixo do que ele mostrou com a senoide e na simulação. Tudo indica que a borda do gerador já chegava como uma rampa de ≈ 0,4 V/µs. O TL082, que é rápido, só copiou essa borda. Já o 741, mais lento que ela, mostrou o seu próprio SR, e por isso o valor dele bateu com o da senoide.

Três detalhes apontam para isso:
- a inclinação do CH2 foi a mesma com 3 V e com 5 V;
- em 1 kHz/3 V as duas saídas ficaram lentas e iguais, mostrando que a borda da entrada não era ideal;
- na simulação, com borda ideal, o TL082 deu 12,8 V/µs.

Por isso o SR do TL082 na bancada foi tirado do teste com senoide, em que a entrada estava sendo vista no CH3. Esse ponto não afeta o 741, porque ele é mais lento que a borda do gerador.

**Comparação entre os dois.** O TL082 ficou de 38 a 44 vezes mais rápido que o 741 (12,8 ou 15 V/µs contra 0,34 V/µs). O datasheet dá 26 vezes. A diferença maior vem principalmente do 741, que ficou abaixo do típico.

**Teoria, simulação e bancada.** Os três concordam:
- O SR do TL082 ficou em 12,8 V/µs na simulação e ≈ 15 V/µs na bancada, contra 13 V/µs do datasheet.
- A FPBW caiu dentro da faixa calculada nos dois casos (3 Vp na simulação e 1,5 Vp na bancada).
- O 741 ficou uns 32 % abaixo do típico, mas com um valor bem repetitivo, que explica todos os tempos e frequências medidos.

## Conclusão – Parte 2

O slew rate foi a limitação que mais separou os dois CIs. Pelo datasheet, o TL082 (13 V/µs) é 26 vezes mais rápido que o LM741 (0,5 V/µs). Na prática a diferença ficou entre 38 e 44 vezes.

- **LM741:** o SR foi 0,34 V/µs em todos os testes, com pulso ou senoide e com 5 V ou 3 V. A amplitude só mudou o tempo de subida (14,6 µs e 8,9 µs) e a frequência em que a onda quadrada vira triângulo (≈ 34 kHz e ≈ 57 kHz). Com a senoide de 3 Vpp, ele distorceu entre 25 e 50 kHz.
- **TL082:** deu 12,8 V/µs na simulação e ≈ 15 V/µs na bancada. Com a senoide de 3 Vpp acompanhou até 1 MHz e só começou a distorcer em 2 MHz. Na simulação, com 3 V de pico, a FPBW ficou entre 500 kHz e 1 MHz, como previsto.
- **Pulso na bancada:** a rampa do TL082 seguiu a borda do gerador, então o SR dele foi tirado do teste com senoide. Para ver o SR com pulso, a borda da entrada precisa ser mais rápida que o próprio ampop.

Diferente da Parte 1, essa limitação não depende da alimentação nem da carga: é uma característica interna do CI. Por isso, ganho, excursão de tensão e velocidade precisam ser verificados separadamente na hora de escolher um ampop.

---

# Conclusão Geral

A atividade mostrou três limitações diferentes:

1. **Saturação de tensão** (Parte 1, U1): a saída não passa de uns 1 a 2 V abaixo da alimentação.
2. **Saturação de corrente** (Parte 1, U2 e U3): com resistores de realimentação ou carga de valor baixo, o ampop chega no limite de corrente antes de chegar no limite de tensão. Em U2, com resistores de só 55 Ω, a entrada chegou a controlar a saída.
3. **Slew rate** (Parte 2): mesmo dentro dos limites de tensão e corrente, a saída não consegue acompanhar sinais rápidos. O problema é maior quanto maiores forem a amplitude e a frequência.

A Parte 1 mostrou que o valor dos resistores precisa respeitar as impedâncias do ampop: nem tão baixo que exija corrente demais, nem tão alto que esbarre na resistência de entrada. Na Parte 2, comparando os dois CIs, o TL082 foi muito mais rápido que o 741.

---

## Referências

- Datasheet LM741 – Texas Instruments
- Datasheet µA741 – Texas Instruments, SLOS094 (valores clássicos da revisão G, 2018; a revisão H, 2026, traz outros valores típicos)
- Datasheet TL08x (TL081/TL082) – Texas Instruments
- SEDRA, A. S.; SMITH, K. C. *Microeletrônica*. 7ª ed. Pearson, 2015.
- Simulação: Proteus 8 Professional
