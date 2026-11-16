# Analise 01 - Filtros ativos. Gera os Bodes teoricos em SVG (imgs/geradas),
# os comparativos com o Proteus (quando os .DAT existem) e imprime as tabelas usadas no .md.
# Modelo do ampop: polo dominante, A(f) = A0 / (1 + j f A0/GBW).
# Nao inversor de ganho K: Acl = A / (1 + A/K).
# Sallen-Key de componentes iguais: H = Acl / (s^2 + (3 - Acl) s + 1), s = j f/fc.
# Uso: powershell -ExecutionPolicy Bypass -File scripts/gerar_graficos.ps1

Add-Type -ReferencedAssemblies System.Numerics -TypeDefinition @'
using System; using System.Numerics;
public static class FT {
  public static Complex PA(double f, double fc) { Complex s = new Complex(0, f / fc); return s / (1 + s); }
  public static Complex PB(double f, double fc) { return 1 / (new Complex(1, f / fc)); }
  public static Complex Amp(double f, double K, double gbw, double a0) {
    Complex A = a0 / (new Complex(1, f * a0 / gbw)); return A / (1 + A / K); }
  public static Complex SK(double f, double fc, Complex K) {
    Complex s = new Complex(0, f / fc); return K / (s * s + (3 - K) * s + 1); }
  public static Complex Mul(Complex a, Complex b) { return a * b; }
}
'@

$inv = [Globalization.CultureInfo]::InvariantCulture
$pt  = [Globalization.CultureInfo]::GetCultureInfo('pt-BR')
$raiz   = Split-Path $PSScriptRoot -Parent   # pasta da atividade
$outDir = Join-Path $raiz 'imgs/geradas'
$PI2 = 2 * [Math]::PI

# ---------- componentes ----------
$TL = @{ gbw = 3e6; a0 = 2e5 }      # TL082: GBW 3 MHz, A0 106 dB
$LM = @{ gbw = 1e6; a0 = 1e5 }      # LM324: GBW 1 MHz, A0 100 dB
$fcPA = 1 / ($PI2 * 6.8e3 * 100e-9) # itens 1 e 2
$fcPB = 1 / ($PI2 * 1.6e3 * 10e-9)  # item 3
$fc5  = 1 / ($PI2 * 16e3 * 10e-9)   # item 4
$K1 = 1 + 20e3 / 10e3               # item 1
$K2 = 1 + 29e3 / 1e3                # item 2
$K3 = 1 + 9e3 / 1e3                 # item 3
$Ka = 1 + 20e3 / 10e3               # 5a ordem, estagio 1
$Kb = 1 + 3.9e3 / 10e3              # estagio 2 (Q = 0,62)
$Kc = 1 + 13.8e3 / 10e3             # estagio 3 (Q = 1,61)

$curvas = @{
    rc_pa  = { param($f) [FT]::PA($f, $fcPA) }
    item1  = { param($f) [FT]::Mul([FT]::PA($f, $fcPA), [FT]::Amp($f, $K1, $TL.gbw, $TL.a0)) }
    item2  = { param($f) [FT]::Mul([FT]::PA($f, $fcPA), [FT]::Amp($f, $K2, $TL.gbw, $TL.a0)) }
    rc_pb  = { param($f) [FT]::PB($f, $fcPB) }
    item3_tl082 = { param($f) [FT]::Mul([FT]::PB($f, $fcPB), [FT]::Amp($f, $K3, $TL.gbw, $TL.a0)) }
    item3_lm324 = { param($f) [FT]::Mul([FT]::PB($f, $fcPB), [FT]::Amp($f, $K3, $LM.gbw, $LM.a0)) }
    e1 = { param($f) [FT]::Mul([FT]::PB($f, $fc5), [FT]::Amp($f, $Ka, $TL.gbw, $TL.a0)) }
    e2 = { param($f) [FT]::Mul((& $curvas.e1 $f), [FT]::SK($f, $fc5, [FT]::Amp($f, $Kb, $TL.gbw, $TL.a0))) }
    e3 = { param($f) [FT]::Mul((& $curvas.e2 $f), [FT]::SK($f, $fc5, [FT]::Amp($f, $Kc, $TL.gbw, $TL.a0))) }
}

# ---------- amostragem com fase desenrolada ----------
$lfMin = 0; $lfMax = [Math]::Log10(2e8); $NP = 1500
function Amostra($nome) {
    $fn = $curvas[$nome]; $ant = $null
    $r = New-Object 'Collections.Generic.List[double[]]'
    for ($i = 0; $i -le $NP; $i++) {
        $f = [Math]::Pow(10, $lfMin + ($lfMax - $lfMin) * $i / $NP)
        $h = & $fn $f
        $ph = $h.Phase * 180 / [Math]::PI
        if ($null -ne $ant) { while ($ph - $ant -gt 180) { $ph -= 360 }; while ($ph - $ant -lt -180) { $ph += 360 } }
        $ant = $ph
        $r.Add([double[]]@($f, (20 * [Math]::Log10($h.Magnitude)), $ph))
    }
    , $r
}
$dados = @{}
foreach ($k in $curvas.Keys) { $dados[$k] = Amostra $k }

# interpola a coluna $col em f (escala log)
function Em($d, $f, $col) {
    for ($i = 1; $i -lt $d.Count; $i++) {
        if ($d[$i][0] -ge $f) {
            $t = ([Math]::Log10($f) - [Math]::Log10($d[$i - 1][0])) / ([Math]::Log10($d[$i][0]) - [Math]::Log10($d[$i - 1][0]))
            return $d[$i - 1][$col] + $t * ($d[$i][$col] - $d[$i - 1][$col])
        }
    }
    $d[$d.Count - 1][$col]
}
# frequencias em que o ganho cruza $nivel (dB)
function Cruzamentos($d, $nivel) {
    for ($i = 1; $i -lt $d.Count; $i++) {
        $a = $d[$i - 1][1] - $nivel; $b = $d[$i][1] - $nivel
        if (($a -lt 0 -and $b -ge 0) -or ($a -ge 0 -and $b -lt 0)) {
            $t = $a / ($a - $b)
            [Math]::Pow(10, [Math]::Log10($d[$i - 1][0]) + $t * ([Math]::Log10($d[$i][0]) - [Math]::Log10($d[$i - 1][0])))
        }
    }
}
function Inclinacao($d, $fa, $fb) { ((Em $d $fb 1) - (Em $d $fa 1)) / ([Math]::Log10($fb) - [Math]::Log10($fa)) }

function N($x) { ([double]$x).ToString('0.##', $inv) }
function Fmt-Freq($f) {
    if ($f -ge 1e6) { return ($f / 1e6).ToString('0.##', $pt) + ' MHz' }
    if ($f -ge 1e3) { return ($f / 1e3).ToString('0.##', $pt) + ' kHz' }
    return $f.ToString('0.#', $pt) + ' Hz'
}

# ---------- desenho ----------
$W = 900; $x0 = 80; $x1 = 860; $gTop = 60; $gBot = 330; $pTop = 390; $pBot = 590; $H = 650
function X($f) { $x0 + ([Math]::Log10($f) - $lfMin) / ($lfMax - $lfMin) * ($x1 - $x0) }

# $series: lista de @{ d = dados; cor; nome; tracejado }
# $eixo: @{ gMin; gMax; gPasso; pMin; pMax; pPasso; legX; legY }
function Bode-Svg($arquivo, $titulo, $series, $eixo, [switch]$soGanho) {
    $gMin = $eixo.gMin; $gMax = $eixo.gMax; $pMin = $eixo.pMin; $pMax = $eixo.pMax
    $YG = { param($v) $gBot - ($v - $gMin) / ($gMax - $gMin) * ($gBot - $gTop) }
    $YP = { param($v) $pBot - ($v - $pMin) / ($pMax - $pMin) * ($pBot - $pTop) }
    $alt = if ($soGanho) { $gBot + 45 } else { $H }
    $paineis = if ($soGanho) { , @($gTop, $gBot) } else { @(, @($gTop, $gBot)) + @(, @($pTop, $pBot)) }
    $rot = @('1 Hz', '10 Hz', '100 Hz', '1 kHz', '10 kHz', '100 kHz', '1 MHz', '10 MHz', '100 MHz')
    $s = New-Object Text.StringBuilder
    [void]$s.AppendLine("<svg xmlns='http://www.w3.org/2000/svg' width='$W' height='$alt' viewBox='0 0 $W $alt' font-family='Arial, Helvetica, sans-serif'>")
    [void]$s.AppendLine("<rect width='100%' height='100%' fill='white'/>")
    [void]$s.AppendLine("<defs><clipPath id='cg'><rect x='$x0' y='$gTop' width='$($x1 - $x0)' height='$($gBot - $gTop)'/></clipPath><clipPath id='cp'><rect x='$x0' y='$pTop' width='$($x1 - $x0)' height='$($pBot - $pTop)'/></clipPath></defs>")
    [void]$s.AppendLine("<text x='$(($x0 + $x1) / 2)' y='30' font-size='15' font-weight='bold' text-anchor='middle' fill='#222'>$titulo</text>")
    foreach ($pan in $paineis) {
        for ($d = 0; $d -le 8; $d++) {
            for ($k = 2; $k -le 9; $k++) {
                $fv = $k * [Math]::Pow(10, $d); if ($fv -gt 2e8) { continue }
                $x = N (X $fv)
                [void]$s.AppendLine("<line x1='$x' y1='$($pan[0])' x2='$x' y2='$($pan[1])' stroke='#e6e6e6' stroke-width='1'/>")
            }
            $x = N (X ([Math]::Pow(10, $d)))
            [void]$s.AppendLine("<line x1='$x' y1='$($pan[0])' x2='$x' y2='$($pan[1])' stroke='#bdbdbd' stroke-width='1'/>")
            [void]$s.AppendLine("<text x='$x' y='$($pan[1] + 16)' font-size='11' text-anchor='middle' fill='#444'>$($rot[$d])</text>")
        }
        [void]$s.AppendLine("<rect x='$x0' y='$($pan[0])' width='$($x1 - $x0)' height='$($pan[1] - $pan[0])' fill='none' stroke='#555'/>")
    }
    for ($v = $gMin; $v -le $gMax; $v += $eixo.gPasso) {
        $y = N (& $YG $v)
        [void]$s.AppendLine("<line x1='$x0' y1='$y' x2='$x1' y2='$y' stroke='#bdbdbd' stroke-width='1'/><text x='$($x0 - 6)' y='$y' dy='4' font-size='11' text-anchor='end' fill='#444'>$v</text>")
    }
    [void]$s.AppendLine("<text x='22' y='195' font-size='12' text-anchor='middle' fill='#222' transform='rotate(-90 22 195)'>Ganho (dB)</text>")
    if (-not $soGanho) {
        for ($v = $pMin; $v -le $pMax; $v += $eixo.pPasso) {
            $y = N (& $YP $v)
            [void]$s.AppendLine("<line x1='$x0' y1='$y' x2='$x1' y2='$y' stroke='#bdbdbd' stroke-width='1'/><text x='$($x0 - 6)' y='$y' dy='4' font-size='11' text-anchor='end' fill='#444'>$v&#176;</text>")
        }
        [void]$s.AppendLine("<text x='22' y='490' font-size='12' text-anchor='middle' fill='#222' transform='rotate(-90 22 490)'>Fase (graus)</text>")
    }
    [void]$s.AppendLine("<text x='$(($x0 + $x1) / 2)' y='$($alt - 14)' font-size='12' text-anchor='middle' fill='#222'>Frequ&#234;ncia</text>")
    $leg = 0
    foreach ($c in $series) {
        $dash = if ($c.tracejado) { " stroke-dasharray='6 4'" } else { '' }
        $lg = if ($c.fino) { 1.5 } else { 2 }
        $pg = ($c.d | ForEach-Object { "$(N (X $_[0])),$(N (& $YG ([Math]::Max($_[1], $gMin - 50))))" }) -join ' '
        [void]$s.AppendLine("<g clip-path='url(#cg)'><polyline points='$pg' fill='none' stroke='$($c.cor)' stroke-width='$lg'$dash/></g>")
        if (-not $soGanho) {
            $pp = ($c.d | ForEach-Object { "$(N (X $_[0])),$(N (& $YP $_[2]))" }) -join ' '
            [void]$s.AppendLine("<g clip-path='url(#cp)'><polyline points='$pp' fill='none' stroke='$($c.cor)' stroke-width='$lg'$dash/></g>")
        }
        $ly = $eixo.legY + 18 * $leg
        [void]$s.AppendLine("<line x1='$($eixo.legX)' y1='$ly' x2='$($eixo.legX + 25)' y2='$ly' stroke='$($c.cor)' stroke-width='2'$dash/><text x='$($eixo.legX + 30)' y='$($ly + 4)' font-size='12' fill='#222'>$($c.nome)</text>")
        $leg++
    }
    [void]$s.AppendLine('</svg>')
    [IO.File]::WriteAllText((Join-Path $outDir $arquivo), $s.ToString(), (New-Object Text.UTF8Encoding $false))
}

$AZ = '#1f77b4'; $VD = '#2ca02c'; $VM = '#d62728'; $CZ = '#7f7f7f'; $RX = '#9467bd'

Bode-Svg 'bode_teorico_itens_1_2.svg' 'Passa-alta de 1&#170; ordem, fc = 234 Hz, TL082 (te&#243;rico)' @(
    @{ d = $dados.rc_pa; cor = $CZ; nome = 'antes da parte ativa (RC)'; tracejado = $true },
    @{ d = $dados.item1; cor = $AZ; nome = 'item 1: sa&#237;da, ganho 3' },
    @{ d = $dados.item2; cor = $VM; nome = 'item 2: sa&#237;da, ganho 30' }
) @{ gMin = -60; gMax = 40; gPasso = 20; pMin = -180; pMax = 90; pPasso = 45; legX = 380; legY = 270 }

Bode-Svg 'bode_teorico_item_3.svg' 'Passa-baixa de 1&#170; ordem, fc = 9,95 kHz, ganho 10 (te&#243;rico)' @(
    @{ d = $dados.rc_pb; cor = $CZ; nome = 'antes da parte ativa (RC)'; tracejado = $true },
    @{ d = $dados.item3_tl082; cor = $AZ; nome = 'sa&#237;da com TL082 (GBW 3 MHz)' },
    @{ d = $dados.item3_lm324; cor = $VM; nome = 'sa&#237;da com LM324 (GBW 1 MHz)' }
) @{ gMin = -120; gMax = 40; gPasso = 20; pMin = -180; pMax = 0; pPasso = 45; legX = 100; legY = 270 }

Bode-Svg 'bode_teorico_item_4.svg' 'Passa-baixa Butterworth de 5&#170; ordem, fc = 995 Hz, ganho 9,92 (te&#243;rico)' @(
    @{ d = $dados.e1; cor = $VD; nome = 'sa&#237;da do est&#225;gio 1 (1&#170; ordem)'; fino = $true },
    @{ d = $dados.e2; cor = $RX; nome = 'sa&#237;da do est&#225;gio 2 (Q = 0,62)'; fino = $true },
    @{ d = $dados.e3; cor = $VM; nome = 'sa&#237;da do filtro (est&#225;gio 3, Q = 1,61)' }
) @{ gMin = -160; gMax = 40; gPasso = 40; pMin = -720; pMax = 0; pPasso = 90; legX = 100; legY = 270 }

# ---------- simulacao x teoria (quando o .DAT existe) ----------
# Cada .DAT e o Export Data do grafico FREQUENCY: primeira coluna FREQ, depois ganho em dB
# e fase de cada ponta, na ordem informada em $colunas (indice da coluna de ganho e de fase).
function Le-Dat($arq, $colGanho, $colFase) {
    $r = New-Object 'Collections.Generic.List[double[]]'; $ant = $null
    foreach ($l in (Get-Content $arq | Select-Object -Skip 1)) {
        $c = $l.Split(','); if ($c.Count -le [Math]::Max($colGanho, $colFase)) { continue }
        $ph = [double]::Parse($c[$colFase], $inv)
        if ($null -ne $ant) { while ($ph - $ant -gt 180) { $ph -= 360 }; while ($ph - $ant -lt -180) { $ph += 360 } }
        $ant = $ph
        $r.Add([double[]]@([double]::Parse($c[0], $inv), [double]::Parse($c[$colGanho], $inv), $ph))
    }
    , $r
}
$sim = @{}
$mapa = Join-Path $PSScriptRoot 'colunas_dat.ps1'   # define $colunas depois de exportar os .DAT
if (Test-Path $mapa) {
    . $mapa
    foreach ($k in $colunas.Keys) {
        $c = $colunas[$k]; $arq = Join-Path $raiz "dados/$($c.arq)"
        if (Test-Path $arq) { $sim[$k] = Le-Dat $arq $c.ganho $c.fase }
    }
}
function Par($chave, $cor, $nome) {
    if ($sim.ContainsKey($chave)) { @{ d = $sim[$chave]; cor = $cor; nome = "$nome (Proteus)" } }
    @{ d = $dados[$chave]; cor = $cor; nome = "$nome (te&#243;rico)"; tracejado = $true; fino = $true }
}
if ($sim.ContainsKey('item1')) {
    Bode-Svg 'bode_sim_x_teoria_itens_1_2.svg' 'Passa-alta: Proteus (cont&#237;nuo) &#215; te&#243;rico (tracejado)' @(
        (Par 'rc_pa' $CZ 'RC') + (Par 'item1' $AZ 'ganho 3') + (Par 'item2' $VM 'ganho 30')
    ) @{ gMin = -60; gMax = 40; gPasso = 20; pMin = -180; pMax = 90; pPasso = 45; legX = 380; legY = 222 }
}
if ($sim.ContainsKey('item3_tl082')) {
    Bode-Svg 'bode_sim_x_teoria_item_3.svg' 'Passa-baixa: Proteus (cont&#237;nuo) &#215; te&#243;rico (tracejado)' @(
        (Par 'rc_pb' $CZ 'RC') + (Par 'item3_tl082' $AZ 'TL082') + (Par 'item3_lm324' $VM 'LM324')
    ) @{ gMin = -120; gMax = 40; gPasso = 20; pMin = -360; pMax = 0; pPasso = 45; legX = 100; legY = 222 }
}
if ($sim.ContainsKey('e3')) {
    Bode-Svg 'bode_sim_x_teoria_item_4.svg' '5&#170; ordem: Proteus (cont&#237;nuo) &#215; te&#243;rico (tracejado)' @(
        (Par 'e1' $VD 'est&#225;gio 1') + (Par 'e2' $RX 'est&#225;gio 2') + (Par 'e3' $VM 'sa&#237;da')
    ) @{ gMin = -160; gMax = 40; gPasso = 40; pMin = -720; pMax = 0; pPasso = 90; legX = 100; legY = 222 }
}

# ---------- tabelas para o .md ----------
function Linha($rot, $d, $tipo, $fcNom) {
    if ($tipo -eq 'pa') {
        $g = ($d | ForEach-Object { $_[1] } | Measure-Object -Maximum).Maximum
        $cr = @(Cruzamentos $d ($g - 3.0103))
        $inc = Inclinacao $d ($fcNom / 100) ($fcNom / 10)
        $sup = if ($cr.Count -gt 1) { Fmt-Freq $cr[1] } else { 'n/a' }
        "| $rot | $($g.ToString('0.00', $pt)) dB | $(Fmt-Freq $cr[0]) | $((Em $d $cr[0] 1).ToString('0.00', $pt)) dB | $((Em $d $cr[0] 2).ToString('0.0', $pt)) | $($inc.ToString('0.0', $pt)) dB/dec | $sup |"
    } else {
        $g = $d[0][1]
        $cr = @(Cruzamentos $d ($g - 3.0103))
        $inc = Inclinacao $d ($fcNom * 10) ($fcNom * 100)
        $inc2 = Inclinacao $d ($fcNom * 2) ($fcNom * 4)
        "| $rot | $($g.ToString('0.00', $pt)) dB | $(Fmt-Freq $cr[0]) | $((Em $d $cr[0] 1).ToString('0.00', $pt)) dB | $((Em $d $cr[0] 2).ToString('0.0', $pt)) | $($inc.ToString('0.0', $pt)) dB/dec (10fc a 100fc); $($inc2.ToString('0.0', $pt)) (2fc a 4fc) | |"
    }
}
"fc nominais: PA $($fcPA.ToString('0.00', $pt)) Hz; PB $($fcPB.ToString('0.0', $pt)) Hz; 5a ordem $($fc5.ToString('0.0', $pt)) Hz"
"Ganhos: K1=$K1 K2=$K2 K3=$K3 | 5a ordem: $Ka x $Kb x $Kc = $(($Ka*$Kb*$Kc).ToString('0.000', $pt)) ($((20*[Math]::Log10($Ka*$Kb*$Kc)).ToString('0.00', $pt)) dB); Q2=$((1/(3-$Kb)).ToString('0.000', $pt)) Q3=$((1/(3-$Kc)).ToString('0.000', $pt))"
"`n### Teorico"
'| Curva | Ganho na banda passante | fc (-3 dB) | Ganho em fc | Fase em fc | Taxa de atenuacao | Corte superior |'
Linha 'RC passa-alta' $dados.rc_pa 'pa' $fcPA
Linha 'Item 1' $dados.item1 'pa' $fcPA
Linha 'Item 2' $dados.item2 'pa' $fcPA
Linha 'RC passa-baixa' $dados.rc_pb 'pb' $fcPB
Linha 'Item 3 TL082' $dados.item3_tl082 'pb' $fcPB
Linha 'Item 3 LM324' $dados.item3_lm324 'pb' $fcPB
Linha '5a ordem estagio 1' $dados.e1 'pb' $fc5
Linha '5a ordem estagio 2' $dados.e2 'pb' $fc5
Linha '5a ordem saida' $dados.e3 'pb' $fc5
if ($sim.Count) {
    "`n### Proteus"
    '| Curva | Ganho na banda passante | fc (-3 dB) | Ganho em fc | Fase em fc | Taxa de atenuacao | Corte superior |'
    $tipos = @{ rc_pa = 'pa'; item1 = 'pa'; item2 = 'pa'; rc_pb = 'pb'; item3_tl082 = 'pb'; item3_lm324 = 'pb'; e1 = 'pb'; e2 = 'pb'; e3 = 'pb' }
    foreach ($k in 'rc_pa', 'item1', 'item2', 'rc_pb', 'item3_tl082', 'item3_lm324', 'e1', 'e2', 'e3') {
        if (-not $sim.ContainsKey($k)) { continue }
        $fn = if ($k -like 'e?') { $fc5 } elseif ($tipos[$k] -eq 'pa') { $fcPA } else { $fcPB }
        Linha $k $sim[$k] $tipos[$k] $fn
    }
}

# pontos da bancada do filtro de 5a ordem (Ve = 1 Vpp)
"`n### 5a ordem: previsao para a bancada (Ve = 1 Vpp)"
'| f | Ganho (V/V) | Ganho (dB) | Vs (Vpp) | Fase |'
foreach ($f in 100, 200, 500, 800, 1000, 1200, 1500, 2000, 3000) {
    $db = Em $dados.e3 $f 1; $g = [Math]::Pow(10, $db / 20)
    "| $(Fmt-Freq $f) | $($g.ToString('0.000', $pt)) | $($db.ToString('0.0', $pt)) | $($g.ToString('0.000', $pt)) | $((Em $dados.e3 $f 2).ToString('0', $pt)) |"
}
"`n### Comparacao de fase/ganho nos itens 1, 2 e 3"
'| f | item1 dB / fase | item2 dB / fase | TL082 dB / fase | LM324 dB / fase |'
foreach ($f in 10, 100, 234, 1e3, 1e4, 3e4, 1e5, 3e5, 1e6, 3e6, 1e7) {
    $c = foreach ($k in 'item1', 'item2', 'item3_tl082', 'item3_lm324') { "$((Em $dados[$k] $f 1).ToString('0.00', $pt)) / $((Em $dados[$k] $f 2).ToString('0.0', $pt))" }
    "| $(Fmt-Freq $f) | $($c -join ' | ') |"
}
