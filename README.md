# OpenCode RTL Fix for macOS

Languages: [فارسی](./README.fa.md) | [العربية](./README.ar.md)

Unofficial local patch for OpenCode Desktop on macOS. It improves Persian and Arabic text direction in chat, markdown, blockquotes, and code blocks that contain RTL text.

It also replaces Persian and Arabic text with a more readable font.

## Trust and scope

This project does not collect data, does not send analytics, and does not modify user projects. It only patches the installed OpenCode Desktop app.asar file and creates a local backup.

OpenCode is a separate project and is not affiliated with this repository. This license only applies to the patch scripts and files in this repository.

## Requirements

- macOS
- OpenCode Desktop installed in `/Applications/OpenCode.app`
- Node.js available in PATH
- Internet access for the first run, because the script uses `npx @electron/asar`

## Install

Download the latest release ZIP, extract it, then double-click:

```text
patch.command
```

Or run from Terminal:

```bash
./patch.command
```

If OpenCode is installed somewhere else:

```bash
OPENCODE_APP="/path/to/OpenCode.app" ./patch.command
```

After patching, fully quit and reopen OpenCode.

## Restore

Double-click:

```text
unpatch.command
```

Or run:

```bash
./unpatch.command
```

The patch creates a backup next to `app.asar` before modifying it.

## Test

Send this message in OpenCode:

```text
سلام، این یک تست فارسی است.
```

Expected result:

- Persian and Arabic text is right-aligned and RTL.
- Punctuation appears at the correct visual end of the sentence.
- English text, paths, and normal code remain LTR.

## Notes

- This modifies the installed OpenCode Desktop `app.asar` file.
- OpenCode updates can overwrite the patch. Run `patch.command` again after updates.
- This is an unofficial patch and is not affiliated with the OpenCode team.
