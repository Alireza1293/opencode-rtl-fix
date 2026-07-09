param(
  [string]$AsarPath = ""
)

$ErrorActionPreference = "Stop"

function Find-AsarPath {
  param([string]$InputPath)

  if ($InputPath -and (Test-Path $InputPath)) {
    $Resolved = (Resolve-Path $InputPath).Path
    if (Test-Path $Resolved -PathType Leaf) {
      return $Resolved
    }

    $Direct = Join-Path $Resolved "resources\app.asar"
    if (Test-Path $Direct) {
      return (Resolve-Path $Direct).Path
    }

    $Nested = Get-ChildItem -Path $Resolved -Filter "app.asar" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($Nested) {
      return $Nested.FullName
    }
  }

  $processNames = @("OpenCode", "opencode", "opencode-desktop")
  foreach ($name in $processNames) {
    $processes = Get-Process -Name $name -ErrorAction SilentlyContinue
    foreach ($process in $processes) {
      try {
        $exe = $process.MainModule.FileName
        if ($exe) {
          $exeDir = Split-Path $exe -Parent
          $fromExe = Join-Path (Split-Path $exeDir -Parent) "resources\app.asar"
          if (Test-Path $fromExe) {
            return (Resolve-Path $fromExe).Path
          }
          $fromExeDir = Join-Path $exeDir "resources\app.asar"
          if (Test-Path $fromExeDir) {
            return (Resolve-Path $fromExeDir).Path
          }
        }
      } catch {}
    }
  }

  $candidates = @(
    "$env:LOCALAPPDATA\Programs\OpenCode\resources\app.asar",
    "$env:LOCALAPPDATA\Programs\opencode\resources\app.asar",
    "$env:LOCALAPPDATA\Programs\opencode-desktop\resources\app.asar",
    "$env:ProgramFiles\OpenCode\resources\app.asar",
    "$env:ProgramFiles\opencode\resources\app.asar",
    "$env:ProgramFiles\opencode-desktop\resources\app.asar",
    "${env:ProgramFiles(x86)}\OpenCode\resources\app.asar",
    "${env:ProgramFiles(x86)}\opencode\resources\app.asar",
    "${env:ProgramFiles(x86)}\opencode-desktop\resources\app.asar"
  )

  foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path $candidate)) {
      return (Resolve-Path $candidate).Path
    }
  }

  $searchRoots = @(
    "$env:LOCALAPPDATA\Programs",
    "$env:LOCALAPPDATA",
    "$env:ProgramFiles",
    "${env:ProgramFiles(x86)}"
  ) | Where-Object { $_ -and (Test-Path $_) }

  foreach ($root in $searchRoots) {
    $match = Get-ChildItem -Path $root -Filter "app.asar" -Recurse -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -match "(?i)opencode" } |
      Select-Object -First 1
    if ($match) {
      return $match.FullName
    }
  }

  throw "Could not find OpenCode app.asar. Start OpenCode and run this script again, or pass -AsarPath 'C:\Path\To\OpenCode\resources\app.asar'."
}

$AsarPath = Find-AsarPath $AsarPath
$ResourcesDir = Split-Path $AsarPath -Parent
$BackupPath = Join-Path $ResourcesDir ("app.asar.backup.{0}" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
$WorkDir = Join-Path $env:TEMP ("opencode-rtl-fix.{0}" -f ([guid]::NewGuid().ToString("N")))

Write-Host "OpenCode RTL Fix"
Write-Host "================"
Write-Host "Target: $AsarPath"

Get-Process OpenCode -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null

try {
  Write-Host "Extracting app.asar..."
  npx --yes @electron/asar extract $AsarPath (Join-Path $WorkDir "app")

  $AssetsDir = Join-Path $WorkDir "app\out\renderer\assets"
  $JsFile = Get-ChildItem $AssetsDir -Filter "main-*.js" | Select-Object -First 1
  $CssFile = Get-ChildItem $AssetsDir -Filter "main-*.css" | Select-Object -First 1
  $HtmlFile = Join-Path $WorkDir "app\out\renderer\index.html"

  if (-not $JsFile -or -not $CssFile -or -not (Test-Path $HtmlFile)) {
    throw "Could not find renderer assets."
  }

  $NodeScript = @'
const fs = require("fs")
const [jsFile, cssFile, htmlFile] = process.argv.slice(2)
const replaceAll = (text, from, to) => text.split(from).join(to)

let js = fs.readFileSync(jsFile, "utf8")
js = replaceAll(js, "<div data-component=markdown>", "<div data-component=markdown dir=auto>")
js = replaceAll(js, "<div data-component=prompt-input role=textbox", "<div data-component=prompt-input dir=auto role=textbox")
js = replaceAll(js, "<div data-slot=user-message-body><div data-slot=user-message-text>", "<div data-slot=user-message-body><div data-slot=user-message-text dir=auto>")
fs.writeFileSync(jsFile, js)

let css = fs.readFileSync(cssFile, "utf8")
if (!css.includes("font-family: 'Vazirmatn'")) {
  css = `@font-face { font-family: 'Vazirmatn'; font-style: normal; font-weight: 100 900; font-display: swap; src: url(https://fonts.gstatic.com/s/vazirmatn/v16/Dxxo8j6PP2D_kU2muijlGMWWMmk.woff2) format('woff2'); unicode-range: U+0600-06FF, U+0750-077F, U+0870-088E, U+0890-0891, U+0897-08E1, U+08E3-08FF, U+200C-200E, U+2010-2011, U+204F, U+2E41, U+FB50-FDFF, U+FE70-FE74, U+FE76-FEFC; }\n` + css
}
if (!css.includes("unicode-bidi: plaintext")) css = replaceAll(css, "overflow-wrap: break-word;\n    min-width: 0;", "overflow-wrap: break-word;\n    unicode-bidi: plaintext;\n    min-width: 0;")
css = replaceAll(css, "margin-left: 0;", "margin-inline-start: 0;")
css = replaceAll(css, "padding-left: 32px;", "padding-inline-start: 32px;")
css = replaceAll(css, "padding-left: 2.25rem;", "padding-inline-start: 2.25rem;")
css = replaceAll(css, "padding-left: 1rem;", "padding-inline-start: 1rem;")
css = replaceAll(css, "padding-left: 1.75rem;", "padding-inline-start: 1.75rem;")
css = replaceAll(css, "border-left: .5px solid var(--v2-border-border-base);", "border-inline-start: .5px solid var(--v2-border-border-base);")
css = replaceAll(css, "padding-left: .5rem;", "padding-inline-start: .5rem;")
if (!css.includes('[data-component="markdown"] pre {\n    direction: ltr;')) css = replaceAll(css, '[data-component="markdown"] pre {\n    scrollbar-width: none;', '[data-component="markdown"] pre {\n    direction: ltr;\n    text-align: left;\n    unicode-bidi: normal;\n    scrollbar-width: none;')
css = css.replace(/\[data-component="markdown"\] th, \[data-component="markdown"\] td \{([\s\S]*?)text-align: left;/, '[data-component="markdown"] th, [data-component="markdown"] td {$1text-align: start;')
fs.writeFileSync(cssFile, css)

let html = fs.readFileSync(htmlFile, "utf8")
const marker = "opencode-rtl-runtime-fix"
html = html.replace(new RegExp(`<script id="${marker}">[\\s\\S]*?<\\/script>`), "")
const script = `<script id="${marker}">
(() => {
  const rtl = /[\u0600-\u06FF\u0750-\u077F\u0870-\u08FF\uFB50-\uFDFF\uFE70-\uFEFC]/
  const selectors = ['[data-component="markdown"]','[data-component="text-part"]','[data-slot="text-part-body"]','[data-slot="user-message-text"]','[data-component="prompt-input"]','[data-component="markdown"] blockquote','[data-component="markdown"] blockquote p','[data-component="markdown"] p','[data-component="markdown"] li'].join(',')
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
  function run() { document.querySelectorAll(selectors).forEach(fixElement) }
  document.addEventListener('input', (event) => {
    const target = event.target
    if (target instanceof HTMLElement) {
      const el = target.closest(selectors)
      if (el) fixElement(el)
    }
  }, true)
  new MutationObserver(run).observe(document.documentElement, { childList: true, subtree: true, characterData: true })
  run()
  setInterval(run, 1000)
})()
</script>`
html = html.replace("</body>", `${script}</body>`)
fs.writeFileSync(htmlFile, html)
'@

  $NodeScriptPath = Join-Path $WorkDir "patch.js"
  Set-Content -Path $NodeScriptPath -Value $NodeScript -Encoding UTF8
  node $NodeScriptPath $JsFile.FullName $CssFile.FullName $HtmlFile

  Write-Host "Packing patched app.asar..."
  npx --yes @electron/asar pack (Join-Path $WorkDir "app") (Join-Path $WorkDir "app.asar")

  Write-Host "Creating backup: $BackupPath"
  Copy-Item $AsarPath $BackupPath -Force
  Copy-Item (Join-Path $WorkDir "app.asar") $AsarPath -Force
  Write-Host "Done. Restart OpenCode."
  Write-Host "Backup saved at: $BackupPath"
}
finally {
  Remove-Item $WorkDir -Recurse -Force -ErrorAction SilentlyContinue
}
