# Gera o PDF do relatorio a partir do .md (pandoc -> HTML com MathML -> Edge/Playwright -> PDF).
# Uso: powershell -ExecutionPolicy Bypass -File gerar_pdf.ps1
$ErrorActionPreference = 'Stop'
$dir  = $PSScriptRoot
$md   = Join-Path $dir 'atividade_02_resposta_em_frequencia.md'
$html = Join-Path $dir '_build.html'
$pdf  = Join-Path $dir 'atividade_02_resposta_em_frequencia.pdf'
$head = Join-Path $env:TEMP 'relatorio_head.html'

"<style>" + (Get-Content (Join-Path $dir 'estilo_pdf.css') -Raw) + "</style>" |
    Set-Content $head -Encoding utf8

# hard_line_breaks mantem as quebras do cabecalho; mathml dispensa JavaScript externo
pandoc $md -f markdown+hard_line_breaks -t html5 --standalone --math-method=mathml `
    --metadata pagetitle="Atividade 02" -H $head -o $html
# o HTML fica na pasta do projeto para os caminhos relativos de imgs/ funcionarem
# O Edge nao sobrescreve um PDF existente: apaga antes para nao gerar sucesso falso
Remove-Item $pdf -ErrorAction SilentlyContinue
if (Test-Path -LiteralPath $pdf) { throw "Nao foi possivel apagar o PDF anterior (arquivo aberto?): $pdf" }

# Com node disponivel usa o render_pdf.cjs (Playwright); senao, imprime pelo Edge headless
if (Get-Command node -ErrorAction SilentlyContinue) {
    node (Join-Path $dir 'render_pdf.cjs') $html $pdf
} else {
    $edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
    & $edge --headless=new --disable-gpu --no-pdf-header-footer "--print-to-pdf=$pdf" "file:///$($html -replace '\\','/')" 2>$null
}
# O Edge devolve o prompt antes de terminar a escrita: espera o arquivo estabilizar
$tamanho = -1
for ($i = 0; $i -lt 60; $i++) {
    Start-Sleep -Milliseconds 500
    if (-not (Test-Path -LiteralPath $pdf)) { continue }
    $atual = (Get-Item -LiteralPath $pdf).Length
    if ($atual -gt 0 -and $atual -eq $tamanho) { break }
    $tamanho = $atual
}
if (-not (Test-Path -LiteralPath $pdf) -or (Get-Item -LiteralPath $pdf).Length -eq 0) {
    throw "Falha ao gerar o PDF: $pdf"
}
Remove-Item $html, $head -ErrorAction SilentlyContinue
"PDF gerado: $pdf  ($([Math]::Round((Get-Item $pdf).Length / 1MB, 1)) MB)"
