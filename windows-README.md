# Madagascar Widescreen Fix - Windows package


## Included files

```text
madagascar-widescreen-fix-win64.exe   Windows 64-bit console build
madagascar-widescreen-fix-win32.exe   Windows 32-bit console build
source-go/main.go                     Windows-buildable source used for these .exe files
source-cpp/src/main.cpp               Updated C++ source from the Linux package
source-cpp/Makefile                   Original Linux Makefile from the source package
```

The Windows executables are native Windows builds. The patch logic matches the updated Linux/C++ FPS-note version. I also compared the patched output against the Linux/C++ patcher on the uploaded original `Game.exe`; both produced identical patched bytes for a 2560x1440 advanced patch with an FPS timer value of 60.

## Basic usage on Windows

Place `madagascar-widescreen-fix-win64.exe` in the same folder as the game's `Game.exe`, then open Command Prompt or PowerShell in that folder.

Patch the default `Game.exe` to 1920x1080:

```bat
madagascar-widescreen-fix-win64.exe --width 1920 --height 1080
```

Patch a specific executable to 2560x1440:

```bat
madagascar-widescreen-fix-win64.exe --game "C:\Games\Madagascar\Game.exe" --width 2560 --height 1440 --level advanced
```

Use the basic FOV patch instead of the advanced patch:

```bat
madagascar-widescreen-fix-win64.exe --game "C:\Games\Madagascar\Game.exe" --width 1920 --height 1080 --level basic
```

## FPS patch usage

For normal gameplay, do **not** use `--unlock-fps` or `--fps`.

The following options are only for testing:

```bat
madagascar-widescreen-fix-win64.exe --game "C:\Games\Madagascar\Game.exe" --width 2560 --height 1440 --unlock-fps
```

Set a specific FPS timer value:

```bat
madagascar-widescreen-fix-win64.exe --game "C:\Games\Madagascar\Game.exe" --width 2560 --height 1440 --fps 120
```

Apply only the FPS patch and leave the widescreen patch state unchanged:

```bat
madagascar-widescreen-fix-win64.exe --game "C:\Games\Madagascar\Game.exe" --fps-only --fps 60
```

## Command-line options

```text
--game PATH              Path to Game.exe. Defaults to .\Game.exe or .\Game\Game.exe
--width N                Target width
--height N               Target height
--level basic|advanced   Widescreen patch level. Default: advanced
--fov-multiplier N       Extra FOV multiplier. Default: 1.0
--unlock-fps             EXPERIMENTAL: raise the internal 60 FPS timer cap to 1000 FPS
--fps N                  EXPERIMENTAL: set the internal timer cap to N FPS, e.g. 120, 240
--fps-only               Apply only the FPS patch; width/height are not required
--layout auto|a|b        Executable layout. Default: auto
--no-backup              Do not create Game.exe.bak before patching
--force                  Patch even if auto-detection is inconclusive
--help                   Show help
```

## Registry resolution value on Windows

The patcher edits `Game.exe`; it does not write the game's registry value.

You can manually set the display resolution in Windows Registry Editor:

```text
HKEY_CURRENT_USER\Software\Activision\Madagascar\Settings\Display
```

Value:

```text
Name: Resolution
Type: REG_SZ
Data: 2560x1440
```

Or use Command Prompt:

```bat
reg add "HKCU\Software\Activision\Madagascar\Settings\Display" /v Resolution /t REG_SZ /d 2560x1440 /f
```

Change `2560x1440` to your desired resolution.

## Manual Wine registry method

If you are patching from Windows but later running the game through Wine/Lutris, you can still set the resolution manually inside the Wine prefix.

Using the Wine Registry Editor GUI:

```bash
WINEPREFIX="/path/to/wine-prefix" wine regedit
```

Go to:

```text
HKEY_CURRENT_USER\Software\Activision\Madagascar\Settings\Display
```

Create or edit this value:

```text
Resolution = 2560x1440
```

You can also use `wine reg add`:

```bash
WINEPREFIX="/path/to/wine-prefix" wine reg add \
  'HKCU\Software\Activision\Madagascar\Settings\Display' \
  /v Resolution /t REG_SZ /d 2560x1440 /f
```

Direct `user.reg` editing also works, but close Wine first. In the prefix's `user.reg`, add or update:

```reg
[Software\\Activision\\Madagascar\\Settings\\Display]
"Resolution"="2560x1440"
```

## Building the included Windows source again

The included Windows executable source is in `source-go/main.go` and can be rebuilt with Go:

```bat
go build -trimpath -ldflags="-s -w" -o madagascar-widescreen-fix-win64.exe .
```

Cross-compile from Linux:

```bash
GOOS=windows GOARCH=amd64 go build -trimpath -ldflags='-s -w' -o madagascar-widescreen-fix-win64.exe ./source-go
GOOS=windows GOARCH=386 go build -trimpath -ldflags='-s -w' -o madagascar-widescreen-fix-win32.exe ./source-go
```

The original updated C++ source is also included under `source-cpp/` for reference and Linux builds.
