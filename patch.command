#!/bin/bash
set -euo pipefail

APP="${OPENCODE_APP:-/Applications/OpenCode.app}"
ASAR="$APP/Contents/Resources/app.asar"
WORK="$(mktemp -d /tmp/opencode-rtl-fix.XXXXXX)"
BACKUP="$APP/Contents/Resources/app.asar.backup.$(date +%Y%m%d-%H%M%S)"

cleanup() {
  rm -rf "$WORK"
}
trap cleanup EXIT

echo "OpenCode RTL Fix"
echo "================"

if [ ! -f "$ASAR" ]; then
  echo "ERROR: app.asar not found at: $ASAR"
  echo "Set OPENCODE_APP to your OpenCode.app path if it is installed elsewhere."
  read -n 1 -s -r -p "Press any key to close..." || true
  exit 1
fi

if pgrep -x "OpenCode" >/dev/null 2>&1; then
  echo "Closing OpenCode..."
  osascript -e 'quit app "OpenCode"' >/dev/null 2>&1 || true
  sleep 2
fi

echo "Extracting app.asar..."
npx --yes @electron/asar extract "$ASAR" "$WORK/app"

JS_FILE="$(ls "$WORK/app/out/renderer/assets"/main-*.js | head -n 1)"
CSS_FILE="$(ls "$WORK/app/out/renderer/assets"/main-*.css | head -n 1)"
HTML_FILE="$WORK/app/out/renderer/index.html"

if [ ! -f "$JS_FILE" ] || [ ! -f "$CSS_FILE" ] || [ ! -f "$HTML_FILE" ]; then
  echo "ERROR: could not find renderer assets."
  read -n 1 -s -r -p "Press any key to close..." || true
  exit 1
fi

ALREADY_PATCHED=0
if grep -q "opencode-rtl-runtime-fix" "$HTML_FILE"; then
  ALREADY_PATCHED=1
fi

node - "$JS_FILE" "$CSS_FILE" "$HTML_FILE" <<'NODE'
const fs = require("fs")
const [jsFile, cssFile, htmlFile] = process.argv.slice(2)

function replaceAll(text, from, to) {
  return text.split(from).join(to)
}

let js = fs.readFileSync(jsFile, "utf8")
js = replaceAll(js, "<div data-component=markdown>", "<div data-component=markdown dir=auto>")
js = replaceAll(js, "<div data-component=prompt-input role=textbox", "<div data-component=prompt-input dir=auto role=textbox")
js = replaceAll(js, "<div data-slot=user-message-body><div data-slot=user-message-text>", "<div data-slot=user-message-body><div data-slot=user-message-text dir=auto>")
fs.writeFileSync(jsFile, js)

let css = fs.readFileSync(cssFile, "utf8")
if (!css.includes("font-family: 'Vazirmatn'")) {
  css = `@font-face { font-family: 'Vazirmatn'; font-style: normal; font-weight: 100 900; font-display: swap; src: url(https://fonts.gstatic.com/s/vazirmatn/v16/Dxxo8j6PP2D_kU2muijlGMWWMmk.woff2) format('woff2'); unicode-range: U+0600-06FF, U+0750-077F, U+0870-088E, U+0890-0891, U+0897-08E1, U+08E3-08FF, U+200C-200E, U+2010-2011, U+204F, U+2E41, U+FB50-FDFF, U+FE70-FE74, U+FE76-FEFC; }\n` + css
}
if (!css.includes("unicode-bidi: plaintext")) {
  css = replaceAll(css, "overflow-wrap: break-word;\n    min-width: 0;", "overflow-wrap: break-word;\n    unicode-bidi: plaintext;\n    min-width: 0;")
}
css = replaceAll(css, "margin-left: 0;", "margin-inline-start: 0;")
css = replaceAll(css, "padding-left: 32px;", "padding-inline-start: 32px;")
css = replaceAll(css, "padding-left: 2.25rem;", "padding-inline-start: 2.25rem;")
css = replaceAll(css, "padding-left: 1rem;", "padding-inline-start: 1rem;")
css = replaceAll(css, "padding-left: 1.75rem;", "padding-inline-start: 1.75rem;")
css = replaceAll(css, "border-left: .5px solid var(--v2-border-border-base);", "border-inline-start: .5px solid var(--v2-border-border-base);")
css = replaceAll(css, "padding-left: .5rem;", "padding-inline-start: .5rem;")
if (!css.includes('[data-component="markdown"] pre {\n    direction: ltr;')) {
  css = replaceAll(css, '[data-component="markdown"] pre {\n    scrollbar-width: none;', '[data-component="markdown"] pre {\n    direction: ltr;\n    text-align: left;\n    unicode-bidi: normal;\n    scrollbar-width: none;')
}
css = css.replace(
  /\[data-component="markdown"\] th, \[data-component="markdown"\] td \{([\s\S]*?)text-align: left;/,
  '[data-component="markdown"] th, [data-component="markdown"] td {$1text-align: start;',
)
fs.writeFileSync(cssFile, css)

let html = fs.readFileSync(htmlFile, "utf8")
const marker = "opencode-rtl-runtime-fix"
html = html.replace(new RegExp(`<script id="${marker}">[\\s\\S]*?<\\/script>`), "")
const script = `<script id="${marker}">
(() => {
  const rtl = /[\u0600-\u06FF\u0750-\u077F\u0870-\u08FF\uFB50-\uFDFF\uFE70-\uFEFC]/
  const selectors = [
    '[data-component="markdown"]',
    '[data-component="text-part"]',
    '[data-slot="text-part-body"]',
    '[data-slot="user-message-text"]',
    '[data-component="prompt-input"]',
    '[data-component="markdown"] blockquote',
    '[data-component="markdown"] blockquote p',
    '[data-component="markdown"] p',
    '[data-component="markdown"] li',
  ].join(',')

  function fixElement(el) {
    if (!(el instanceof HTMLElement)) return
    const text = el.innerText || el.textContent || ''
    if (!text.trim()) return
    const isRTL = rtl.test(text)
    el.setAttribute('dir', isRTL ? 'rtl' : 'ltr')
    el.style.textAlign = isRTL ? 'right' : 'left'
    el.style.unicodeBidi = 'plaintext'
    if (isRTL) el.style.fontFamily = "'Vazirmatn', var(--font-family-sans)"
    if (isRTL && el.matches('blockquote, blockquote *')) el.style.direction = 'rtl'

    el.querySelectorAll('pre, [data-component="markdown-code"]').forEach((codeBlock) => {
      if (!(codeBlock instanceof HTMLElement)) return
      const codeText = codeBlock.innerText || codeBlock.textContent || ''
      const codeIsRTL = rtl.test(codeText)
      codeBlock.setAttribute('dir', codeIsRTL ? 'rtl' : 'ltr')
      codeBlock.style.direction = codeIsRTL ? 'rtl' : 'ltr'
      codeBlock.style.textAlign = codeIsRTL ? 'right' : 'left'
      codeBlock.style.unicodeBidi = codeIsRTL ? 'plaintext' : 'normal'
      if (codeIsRTL) codeBlock.style.fontFamily = "'Vazirmatn', var(--font-family-mono)"
      codeBlock.querySelectorAll('code').forEach((code) => {
        if (!(code instanceof HTMLElement)) return
        code.setAttribute('dir', codeIsRTL ? 'rtl' : 'ltr')
        code.style.direction = codeIsRTL ? 'rtl' : 'ltr'
        code.style.textAlign = codeIsRTL ? 'right' : 'left'
        code.style.unicodeBidi = codeIsRTL ? 'plaintext' : 'normal'
        if (codeIsRTL) code.style.fontFamily = "'Vazirmatn', var(--font-family-mono)"
      })
    })

    el.querySelectorAll(':not(pre) > code').forEach((code) => {
      if (!(code instanceof HTMLElement)) return
      code.setAttribute('dir', 'ltr')
      code.style.direction = 'ltr'
      code.style.textAlign = 'left'
      code.style.unicodeBidi = 'normal'
    })
  }

  function run() {
    document.querySelectorAll(selectors).forEach(fixElement)
  }

  document.addEventListener('input', (event) => {
    const target = event.target
    if (target instanceof HTMLElement) {
      const el = target.closest(selectors)
      if (el) fixElement(el)
    }
  }, true)

  new MutationObserver(run).observe(document.documentElement, {
    childList: true,
    subtree: true,
    characterData: true,
  })

  run()
  setInterval(run, 1000)
})()
</script>`
html = html.replace("</body>", `${script}</body>`)
fs.writeFileSync(htmlFile, html)
NODE

echo "Packing patched app.asar..."
npx --yes @electron/asar pack "$WORK/app" "$WORK/app.asar"

if [ "$ALREADY_PATCHED" = "0" ]; then
  echo "Creating backup: $BACKUP"
  if cp "$ASAR" "$BACKUP" 2>/dev/null; then
    true
  else
    echo "Admin permission is required to modify $APP"
    sudo cp "$ASAR" "$BACKUP"
  fi
else
  echo "OpenCode already appears to be patched; skipping backup to avoid backing up a patched app.asar."
fi

if cp "$WORK/app.asar" "$ASAR" 2>/dev/null; then
  true
else
  echo "Admin permission is required to modify $APP"
  sudo cp "$WORK/app.asar" "$ASAR"
fi

echo "Done. Restart OpenCode."
if [ "$ALREADY_PATCHED" = "0" ]; then
  echo "Backup saved at: $BACKUP"
fi
read -n 1 -s -r -p "Press any key to close..." || true
