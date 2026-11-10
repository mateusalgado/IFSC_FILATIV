const path = require('path');
const { pathToFileURL } = require('url');

const modules = path.join(
  process.env.USERPROFILE,
  '.cache', 'codex-runtimes', 'codex-primary-runtime',
  'dependencies', 'node', 'node_modules', 'playwright'
);
const { chromium } = require(modules);

(async () => {
  const [html, pdf] = process.argv.slice(2);
  if (!html || !pdf) throw new Error('Uso: node render_pdf.cjs entrada.html saida.pdf');

  const edge = path.join(
    process.env['ProgramFiles(x86)'] || 'C:\\Program Files (x86)',
    'Microsoft', 'Edge', 'Application', 'msedge.exe'
  );
  const browser = await chromium.launch({ executablePath: edge, headless: true });
  try {
    const page = await browser.newPage();
    await page.goto(pathToFileURL(path.resolve(html)).href, { waitUntil: 'load' });
    await page.pdf({
      path: path.resolve(pdf),
      format: 'A4',
      printBackground: true,
      preferCSSPageSize: true,
    });
  } finally {
    await browser.close();
  }
})().catch((error) => { console.error(error); process.exit(1); });
