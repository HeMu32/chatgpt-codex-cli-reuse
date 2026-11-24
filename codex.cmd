@echo off
setlocal DisableDelayedExpansion

rem dsh 2026-11-24
rem Reuse the Codex CLI bundled with the ChatGPT/Codex Desktop installation.
rem Set CODEX_CLI_EXE to pin a specific complete desktop installation.
if defined CODEX_CLI_EXE goto use_override

set "EXE="
set "BIN=%LOCALAPPDATA%\OpenAI\Codex\bin"

for /f "delims=" %%d in ('dir /b /o-d /a:d "%BIN%" 2^>nul') do (
  if not defined EXE (
    if exist "%BIN%\%%d\codex.exe" (
      if exist "%BIN%\%%d\codex-code-mode-host.exe" (
        if exist "%BIN%\%%d\codex-command-runner.exe" (
          if exist "%BIN%\%%d\codex-windows-sandbox-setup.exe" (
            set "EXE=%BIN%\%%d\codex.exe"
          )
        )
      )
    )
  )
)

if not defined EXE (
  echo codex: no complete Codex Desktop CLI installation found under "%BIN%".>&2
  exit /b 127
)

goto launch

:use_override
for %%I in ("%CODEX_CLI_EXE%") do set "EXE=%%~fI"
for %%I in ("%EXE%") do set "EXE_DIR=%%~dpI"

if not exist "%EXE%" (
  echo codex: CODEX_CLI_EXE does not exist: "%CODEX_CLI_EXE%".>&2
  exit /b 127
)
if not exist "%EXE_DIR%codex-code-mode-host.exe" goto incomplete_override
if not exist "%EXE_DIR%codex-command-runner.exe" goto incomplete_override
if not exist "%EXE_DIR%codex-windows-sandbox-setup.exe" goto incomplete_override

goto launch

:incomplete_override
echo codex: CODEX_CLI_EXE does not point to a complete Codex Desktop installation: "%CODEX_CLI_EXE%".>&2
exit /b 127

:launch
"%EXE%" %*
exit /b %ERRORLEVEL%
