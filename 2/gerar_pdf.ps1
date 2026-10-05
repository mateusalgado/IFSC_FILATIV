# Gera o PDF do relatorio a partir do .md (pandoc -> HTML com MathML -> Edge headless -> PDF).
# Uso: powershell -ExecutionPolicy Bypass -File gerar_pdf.ps1
$ErrorActionPreference = 'Stop'
$dir  = $PSScriptRoot
$md   = Join-Path $dir 'atividade_02_resposta_em_frequencia.md'
$html = Join-Path $dir '_build.html'
$pdf  = Join-Path $dir 'atividade_02_resposta_em_frequencia.pdf'
$head = Join-Path $env:TEMP 'relatorio_head.html'
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'

"<style>" + (Get-Content (Join-Path $dir 'estilo_pdf.css') -Raw) + "</style>" |
    Set-Content $head -Encoding utf8

# hard_line_breaks mantem as quebras do cabecalho; mathml dispensa JavaScript externo
pandoc $md -f markdown+hard_line_breaks -t html5 --standalone --math-method=mathml `
    --metadata pagetitle="Atividade 02" -H $head -o $html
# o HTML fica na pasta do projeto para os caminhos relativos de imgs/ funcionarem
& $edge --headless=new --disable-gpu --no-pdf-header-footer "--print-to-pdf=$pdf" "file:///$($html -replace '\','/')" 2>$null
Remove-Item $html, $head -ErrorAction SilentlyContinue
"PDF gerado: $pdf  ($([Math]::Round((Get-Item $pdf).Length / 1MB, 1)) MB)"
