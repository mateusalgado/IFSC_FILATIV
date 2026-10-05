# Gera as curvas teoricas de Bode (ganho e fase) da Atividade 02 em SVG (imgs/geradas)
# e imprime as tabelas de valores teoricos usadas no .md.
# Modelo: polo dominante, A(f) = A0 / (1 + j f/fp), fp = GBW / A0.
# Nao inversor: Acl(f) = A / (1 + A*beta) = A0 / ((1 + A0*beta) + j f/fp), beta = Rg / (Rg + Rf).
# Uso: powershell -ExecutionPolicy Bypass -File gerar_graficos.ps1

$inv = [Globalization.CultureInfo]::InvariantCulture
$pt  = [Globalization.CultureInfo]::GetCultureInfo('pt-BR')
$outDir = Join-Path $PSScriptRoot 'imgs\geradas'

$ampops = @(
    @{ nome = 'LM741'; A0 = 200000.0; GBW = 1e6; arq = 'bode_teorico_lm741.svg' },
    @{ nome = 'TL081'; A0 = 200000.0; GBW = 3e6; arq = 'bode_teorico_tl081.svg' }
)
$circuitos = @(
    @{ n = 'U1'; Rg = 10e3; Rf = 10e3;  cor = '#1f77b4' },
    @{ n = 'U2'; Rg = 10e3; Rf = 100e3; cor = '#2ca02c' },
    @{ n = 'U3'; Rg = 10e3; Rf = 1e6;   cor = '#d62728' },
    @{ n = 'U4'; Rg = 1e3;  Rf = 10e6;  cor = '#9467bd' }
)

function Get-Acl($A0, $fp, $beta, $f) {
    $re = 1 + $A0 * $beta; $im = $f / $fp
    @{ mag = $A0 / [Math]::Sqrt($re * $re + $im * $im); fase = -[Math]::Atan2($im, $re) * 180 / [Math]::PI }
}
function Get-Aol($A0, $fp, $f) {
    @{ mag = $A0 / [Math]::Sqrt(1 + ($f / $fp) * ($f / $fp)); fase = -[Math]::Atan($f / $fp) * 180 / [Math]::PI }
}
function N($x) { $x.ToString('0.##', $inv) }
function Fmt-Freq($f) {
    if ($f -ge 1e6) { return ($f / 1e6).ToString('0.##', $pt) + ' MHz' }
    if ($f -ge 1e3) { return ($f / 1e3).ToString('0.#', $pt) + ' kHz' }
    return $f.ToString('0', $pt) + ' Hz'
}

# ---------- geometria do grafico ----------
$W = 900; $x0 = 80; $x1 = 860
$lfMin = 0; $lfMax = 7                   # 1 Hz a 10 MHz
$gTop = 60;  $gBot = 330; $gMin = -20; $gMax = 120
$pTop = 390; $pBot = 590; $pMin = -100; $pMax = 0
$H = 650
function X($f)  { $x0 + ([Math]::Log10($f) - $lfMin) / ($lfMax - $lfMin) * ($x1 - $x0) }
function YG($db){ $gBot - ($db - $gMin) / ($gMax - $gMin) * ($gBot - $gTop) }
function YP($ph){ $pBot - ($ph - $pMin) / ($pMax - $pMin) * ($pBot - $pTop) }

function Grid-Svg {
    $s = New-Object Text.StringBuilder
    $rotulos = @('1 Hz', '10 Hz', '100 Hz', '1 kHz', '10 kHz', '100 kHz', '1 MHz', '10 MHz')
    foreach ($pan in @(@($gTop, $gBot), @($pTop, $pBot))) {
        for ($d = $lfMin; $d -lt $lfMax; $d++) {
            for ($k = 2; $k -le 9; $k++) {
                $x = N (X ($k * [Math]::Pow(10, $d)))
                [void]$s.AppendLine("<line x1='$x' y1='$($pan[0])' x2='$x' y2='$($pan[1])' stroke='#e6e6e6' stroke-width='1'/>")
            }
        }
        for ($d = $lfMin; $d -le $lfMax; $d++) {
            $x = N (X ([Math]::Pow(10, $d)))
            [void]$s.AppendLine("<line x1='$x' y1='$($pan[0])' x2='$x' y2='$($pan[1])' stroke='#bdbdbd' stroke-width='1'/>")
        }
    }
    for ($d = $lfMin; $d -le $lfMax; $d++) {
        $x = N (X ([Math]::Pow(10, $d)))
        [void]$s.AppendLine("<text x='$x' y='$($gBot + 16)' font-size='11' text-anchor='middle' fill='#444'>$($rotulos[$d])</text>")
        [void]$s.AppendLine("<text x='$x' y='$($pBot + 16)' font-size='11' text-anchor='middle' fill='#444'>$($rotulos[$d])</text>")
    }
    for ($db = $gMin; $db -le $gMax; $db += 20) {
        $y = N (YG $db)
        [void]$s.AppendLine("<line x1='$x0' y1='$y' x2='$x1' y2='$y' stroke='#bdbdbd' stroke-width='1'/>")
        [void]$s.AppendLine("<text x='$($x0 - 6)' y='$y' dy='4' font-size='11' text-anchor='end' fill='#444'>$db</text>")
    }
    for ($ph = $pMin; $ph -le $pMax; $ph += 20) {
        $y = N (YP $ph)
        [void]$s.AppendLine("<line x1='$x0' y1='$y' x2='$x1' y2='$y' stroke='#bdbdbd' stroke-width='1'/>")
        [void]$s.AppendLine("<text x='$($x0 - 6)' y='$y' dy='4' font-size='11' text-anchor='end' fill='#444'>$ph&#176;</text>")
    }
    [void]$s.AppendLine("<rect x='$x0' y='$gTop' width='$($x1 - $x0)' height='$($gBot - $gTop)' fill='none' stroke='#555'/>")
    [void]$s.AppendLine("<rect x='$x0' y='$pTop' width='$($x1 - $x0)' height='$($pBot - $pTop)' fill='none' stroke='#555'/>")
    [void]$s.AppendLine("<text x='22' y='$(($gTop + $gBot) / 2)' font-size='12' text-anchor='middle' fill='#222' transform='rotate(-90 22 $(($gTop + $gBot) / 2))'>Ganho (dB)</text>")
    [void]$s.AppendLine("<text x='22' y='$(($pTop + $pBot) / 2)' font-size='12' text-anchor='middle' fill='#222' transform='rotate(-90 22 $(($pTop + $pBot) / 2))'>Fase (graus)</text>")
    [void]$s.AppendLine("<text x='$(($x0 + $x1) / 2)' y='$($pBot + 36)' font-size='12' text-anchor='middle' fill='#222'>Frequ&#234;ncia</text>")
    $s.ToString()
}

function Path-Svg($fn, $yfn, $cor, $tracejado) {
    $pts = New-Object Collections.Generic.List[string]
    for ($i = 0; $i -le 700; $i++) {
        $f = [Math]::Pow(10, $lfMin + ($lfMax - $lfMin) * $i / 700)
        $v = & $fn $f
        $y = & $yfn $v
        $pts.Add("$(N (X $f)),$(N $y)")
    }
    $dash = if ($tracejado) { " stroke-dasharray='6 4'" } else { '' }
    "<polyline points='$($pts -join ' ')' fill='none' stroke='$cor' stroke-width='2'$dash/>"
}

function Clip-Svg($id, $top, $bot) {
    "<clipPath id='$id'><rect x='$x0' y='$top' width='$($x1 - $x0)' height='$($bot - $top)'/></clipPath>"
}

# ---------- um grafico por ampop ----------
foreach ($a in $ampops) {
    $fp = $a.GBW / $a.A0
    $sb = New-Object Text.StringBuilder
    [void]$sb.AppendLine("<svg xmlns='http://www.w3.org/2000/svg' width='$W' height='$H' viewBox='0 0 $W $H' font-family='Arial, Helvetica, sans-serif'>")
    [void]$sb.AppendLine("<rect width='100%' height='100%' fill='white'/>")
    [void]$sb.AppendLine("<defs>$(Clip-Svg 'cg' $gTop $gBot)$(Clip-Svg 'cp' $pTop $pBot)</defs>")
    [void]$sb.AppendLine("<text x='$(($x0 + $x1) / 2)' y='30' font-size='15' font-weight='bold' text-anchor='middle' fill='#222'>Resposta em frequ&#234;ncia te&#243;rica &#8211; $($a.nome) (A0 = 106 dB, GBW = $(Fmt-Freq $a.GBW), polo dominante)</text>")
    [void]$sb.Append((Grid-Svg))

    $A0 = $a.A0
    [void]$sb.AppendLine("<g clip-path='url(#cg)'>" + (Path-Svg { param($f) (Get-Aol $A0 $fp $f).mag } { param($m) YG (20 * [Math]::Log10($m)) } '#7f7f7f' $true) + "</g>")
    [void]$sb.AppendLine("<g clip-path='url(#cp)'>" + (Path-Svg { param($f) (Get-Aol $A0 $fp $f).fase } { param($p) YP $p } '#7f7f7f' $true) + "</g>")

    $leg = 0
    foreach ($c in $circuitos) {
        $beta = $c.Rg / ($c.Rg + $c.Rf)
        $fc = $fp * (1 + $A0 * $beta)
        $G0 = $A0 / (1 + $A0 * $beta)
        [void]$sb.AppendLine("<g clip-path='url(#cg)'>" + (Path-Svg { param($f) (Get-Acl $A0 $fp $beta $f).mag } { param($m) YG (20 * [Math]::Log10($m)) } $c.cor $false) + "</g>")
        [void]$sb.AppendLine("<g clip-path='url(#cp)'>" + (Path-Svg { param($f) (Get-Acl $A0 $fp $beta $f).fase } { param($p) YP $p } $c.cor $false) + "</g>")
        $xc = N (X $fc); $yc = N (YG (20 * [Math]::Log10($G0) - 3.01)); $yp = N (YP -45)
        [void]$sb.AppendLine("<circle cx='$xc' cy='$yc' r='4' fill='$($c.cor)'/><circle cx='$xc' cy='$yp' r='4' fill='$($c.cor)'/>")
        [void]$sb.AppendLine("<text x='$xc' y='$(N ((YG (20 * [Math]::Log10($G0))) - 8))' font-size='11' text-anchor='middle' fill='$($c.cor)'>fc = $(Fmt-Freq $fc)</text>")
        $ly = $gTop + 18 + 18 * $leg
        [void]$sb.AppendLine("<line x1='$($x1 - 170)' y1='$ly' x2='$($x1 - 145)' y2='$ly' stroke='$($c.cor)' stroke-width='2'/><text x='$($x1 - 140)' y='$($ly + 4)' font-size='12' fill='#222'>$($c.n): G = $((1 / $beta).ToString('0', $inv)) ($((20 * [Math]::Log10($G0)).ToString('0.0', $pt)) dB)</text>")
        $leg++
    }
    $ly = $gTop + 18 + 18 * $leg
    [void]$sb.AppendLine("<line x1='$($x1 - 170)' y1='$ly' x2='$($x1 - 145)' y2='$ly' stroke='#7f7f7f' stroke-width='2' stroke-dasharray='6 4'/><text x='$($x1 - 140)' y='$($ly + 4)' font-size='12' fill='#222'>malha aberta A(f)</text>")
    [void]$sb.AppendLine("<text x='$($x1 - 170)' y='$($ly + 22)' font-size='11' fill='#555'>&#9679; ponto de &#8722;3 dB / &#8722;45&#176;</text>")
    [void]$sb.AppendLine('</svg>')
    [IO.File]::WriteAllText((Join-Path $outDir $a.arq), $sb.ToString(), (New-Object Text.UTF8Encoding $false))
}

# ---------- comparativo 741 x TL081 (mesmo circuito, dois ampops) ----------
$sb = New-Object Text.StringBuilder
[void]$sb.AppendLine("<svg xmlns='http://www.w3.org/2000/svg' width='$W' height='$H' viewBox='0 0 $W $H' font-family='Arial, Helvetica, sans-serif'>")
[void]$sb.AppendLine("<rect width='100%' height='100%' fill='white'/>")
[void]$sb.AppendLine("<defs>$(Clip-Svg 'cg' $gTop $gBot)$(Clip-Svg 'cp' $pTop $pBot)</defs>")
[void]$sb.AppendLine("<text x='$(($x0 + $x1) / 2)' y='30' font-size='15' font-weight='bold' text-anchor='middle' fill='#222'>Comparativo te&#243;rico &#8211; LM741 (cont&#237;nuo) &#215; TL081 (tracejado)</text>")
[void]$sb.Append((Grid-Svg))
$leg = 0
foreach ($c in $circuitos) {
    $beta = $c.Rg / ($c.Rg + $c.Rf)
    foreach ($a in $ampops) {
        $fp = $a.GBW / $a.A0; $A0 = $a.A0
        $tr = ($a.nome -eq 'TL081')
        [void]$sb.AppendLine("<g clip-path='url(#cg)'>" + (Path-Svg { param($f) (Get-Acl $A0 $fp $beta $f).mag } { param($m) YG (20 * [Math]::Log10($m)) } $c.cor $tr) + "</g>")
        [void]$sb.AppendLine("<g clip-path='url(#cp)'>" + (Path-Svg { param($f) (Get-Acl $A0 $fp $beta $f).fase } { param($p) YP $p } $c.cor $tr) + "</g>")
    }
    $ly = $gTop + 18 + 18 * $leg
    [void]$sb.AppendLine("<line x1='$($x1 - 170)' y1='$ly' x2='$($x1 - 145)' y2='$ly' stroke='$($c.cor)' stroke-width='3'/><text x='$($x1 - 140)' y='$($ly + 4)' font-size='12' fill='#222'>$($c.n): G = $((1 / $beta).ToString('0', $inv))</text>")
    $leg++
}
$ly = $gTop + 18 + 18 * $leg
[void]$sb.AppendLine("<line x1='$($x1 - 170)' y1='$ly' x2='$($x1 - 145)' y2='$ly' stroke='#222' stroke-width='2'/><text x='$($x1 - 140)' y='$($ly + 4)' font-size='12' fill='#222'>LM741 (GBW 1 MHz)</text>")
$ly += 18
[void]$sb.AppendLine("<line x1='$($x1 - 170)' y1='$ly' x2='$($x1 - 145)' y2='$ly' stroke='#222' stroke-width='2' stroke-dasharray='6 4'/><text x='$($x1 - 140)' y='$($ly + 4)' font-size='12' fill='#222'>TL081 (GBW 3 MHz)</text>")
[void]$sb.AppendLine('</svg>')
[IO.File]::WriteAllText((Join-Path $outDir 'comparativo_teorico_741_tl081.svg'), $sb.ToString(), (New-Object Text.UTF8Encoding $false))

# ---------- simulacao (Proteus, Export Data) x teoria, so ganho ----------
# Le <AMPOP>.DAT exportado do grafico FREQUENCY: "FREQ","U1(OP)",... em dB.
# O grafico usa o mesmo layout, mas corta a altura logo abaixo do painel de ganho.
foreach ($a in $ampops) {
    $dat = Join-Path $PSScriptRoot "$($a.nome).DAT"
    if (-not (Test-Path $dat)) { continue }
    $linhas = Get-Content $dat | Select-Object -Skip 1 | ForEach-Object { , ($_.Split(',') | ForEach-Object { [double]::Parse($_, $inv) }) }
    $fp = $a.GBW / $a.A0; $A0 = $a.A0
    $Hg = $gBot + 45
    $sb = New-Object Text.StringBuilder
    [void]$sb.AppendLine("<svg xmlns='http://www.w3.org/2000/svg' width='$W' height='$Hg' viewBox='0 0 $W $Hg' font-family='Arial, Helvetica, sans-serif'>")
    [void]$sb.AppendLine("<rect width='100%' height='100%' fill='white'/>")
    [void]$sb.AppendLine("<defs>$(Clip-Svg 'cg' $gTop $gBot)</defs>")
    [void]$sb.AppendLine("<text x='$(($x0 + $x1) / 2)' y='30' font-size='15' font-weight='bold' text-anchor='middle' fill='#222'>Ganho simulado no Proteus (cont&#237;nuo) &#215; te&#243;rico (tracejado) &#8211; $($a.nome)</text>")
    [void]$sb.Append((Grid-Svg))
    [void]$sb.AppendLine("<text x='$(($x0 + $x1) / 2)' y='$($gBot + 36)' font-size='12' text-anchor='middle' fill='#222'>Frequ&#234;ncia</text>")
    $leg = 0
    for ($k = 0; $k -lt $circuitos.Count; $k++) {
        $c = $circuitos[$k]; $beta = $c.Rg / ($c.Rg + $c.Rf)
        [void]$sb.AppendLine("<g clip-path='url(#cg)'>" + (Path-Svg { param($f) (Get-Acl $A0 $fp $beta $f).mag } { param($m) YG (20 * [Math]::Log10($m)) } $c.cor $true) + "</g>")
        $pts = ($linhas | ForEach-Object { "$(N (X $_[0])),$(N (YG $_[$k + 1]))" }) -join ' '
        [void]$sb.AppendLine("<g clip-path='url(#cg)'><polyline points='$pts' fill='none' stroke='$($c.cor)' stroke-width='2'/></g>")
        $ly = $gTop + 18 + 18 * $leg
        [void]$sb.AppendLine("<line x1='$($x1 - 170)' y1='$ly' x2='$($x1 - 145)' y2='$ly' stroke='$($c.cor)' stroke-width='3'/><text x='$($x1 - 140)' y='$($ly + 4)' font-size='12' fill='#222'>$($c.n): G = $((1 / $beta).ToString('0', $inv))</text>")
        $leg++
    }
    [void]$sb.AppendLine('</svg>')
    [IO.File]::WriteAllText((Join-Path $outDir "bode_sim_x_teoria_$($a.nome.ToLower()).svg"), $sb.ToString(), (New-Object Text.UTF8Encoding $false))
}

# ---------- tabelas para o .md ----------
foreach ($a in $ampops) {
    $fp = $a.GBW / $a.A0; $A0 = $a.A0
    "`n### $($a.nome) (fp = $($fp) Hz)"
    '| Circuito | G ideal | G real (A0 finito) | G (dB) | fc |'
    foreach ($c in $circuitos) {
        $beta = $c.Rg / ($c.Rg + $c.Rf)
        $G0 = $A0 / (1 + $A0 * $beta); $fc = $fp * (1 + $A0 * $beta)
        "| $($c.n) | $((1 / $beta).ToString('0', $pt)) | $($G0.ToString('0.####', $pt)) | $((20 * [Math]::Log10($G0)).ToString('0.00', $pt)) | $(Fmt-Freq $fc) |"
    }
}
$freqs = @(10, 100, 1e3, 2e3, 5e3, 10e3, 20e3, 50e3, 100e3, 200e3, 500e3, 1e6, 2e6)
foreach ($a in $ampops) {
    $fp = $a.GBW / $a.A0; $A0 = $a.A0
    "`n### Pontos $($a.nome): |G| (dB) / fase"
    '| f | ' + (($circuitos | % { $_.n }) -join ' | ') + ' |'
    foreach ($f in $freqs) {
        $cels = foreach ($c in $circuitos) {
            $beta = $c.Rg / ($c.Rg + $c.Rf); $r = Get-Acl $A0 $fp $beta $f
            "$($r.mag.ToString('0.##', $pt)) ($((20 * [Math]::Log10($r.mag)).ToString('0.0', $pt)) dB) / $($r.fase.ToString('0.0', $pt))°"
        }
        "| $(Fmt-Freq $f) | $($cels -join ' | ') |"
    }
}

# ---------- valores teoricos para a Tabela 1 (bancada, LM741, Ve = 50 mVpp) ----------
$Ve = 0.050
$bancada = @(
    @{ n = 'U3'; Rg = 10e3; Rf = 1e6;   fs = @(100, 500, 1e3, 2e3, 3e3, 5e3, 7e3, 10e3, 15e3, 20e3, 30e3, 50e3, 70e3, 100e3, 200e3, 300e3, 500e3, 1e6) },
    @{ n = 'U2'; Rg = 10e3; Rf = 100e3; fs = @(100, 1e3, 5e3, 10e3, 20e3, 30e3, 50e3, 70e3, 90e3, 100e3, 150e3, 200e3, 300e3, 500e3, 700e3, 1e6, 1.5e6, 2e6) }
)
$a = $ampops[0]; $fp = $a.GBW / $a.A0; $A0 = $a.A0
foreach ($c in $bancada) {
    $beta = $c.Rg / ($c.Rg + $c.Rf)
    "`n### Tabela 1 teorica - $($c.n) com LM741, Ve = 50 mVpp"
    foreach ($f in $c.fs) {
        $r = Get-Acl $A0 $fp $beta $f
        "| $(Fmt-Freq $f) | $(($Ve * $r.mag * 1000).ToString('0', $pt)) mVpp | $($r.mag.ToString('0.0', $pt)) ($((20 * [Math]::Log10($r.mag)).ToString('0.0', $pt)) dB) | $($r.fase.ToString('0', $pt))° |"
    }
}
