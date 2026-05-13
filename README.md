# Madagascar Widescreen Fix - Linux CLI recreation with FPS patch

This is a Linux command-line recreation of the Windows widescreen patcher for the PC version of **Madagascar**.

It patches the Windows `Game.exe` directly from Linux so the game can render with Hor+ widescreen behavior. This version also includes an optional FPS timer patch.

This version intentionally does **not** write the game's registry resolution value. For Wine, the recommended approach is still to patch `Game.exe` with this tool and set the resolution manually in the Wine registry.

## What this tool does

- Patches `Game.exe` for widescreen / Hor+ behavior.
- Uses your chosen width and height to calculate the target aspect ratio.
- Optionally raises the game's internal FPS timer from `60.0f` to another value.
- Creates a backup named `Game.exe.bak` by default.
- Supports `basic` and `advanced` widescreen patch modes.
- Does not require the game to be launched from Windows.

## What this tool does not do

- It does **not** write the Windows registry resolution value.
- It does **not** install Wine, Lutris, DXVK, dgVoodoo2, or any wrapper.
- It does **not** replace your game configuration files.

For Wine, set the resolution manually here:

```text
HKEY_CURRENT_USER\Software\Activision\Madagascar\Settings\Display
```

Value:

```text
Name: Resolution
Type: REG_SZ
Data: 2560x1440
```

Change `2560x1440` to the resolution you want.

---

## FPS patch notes

The uploaded original `Game.exe` initializes the frame timer by pushing `60.0f` twice. This tool can overwrite those two float values.

The practical unlocked mode uses `1000.0f`, which removes the normal 60 FPS pacing limit without needing a bigger code cave or a runtime DLL.

**Important:** the FPS patch is **not recommended for normal play**. Testing showed that the game speed is tied to the FPS timer, so values above 60 can make the game run too fast. Keep this option only for experiments, debugging, or future research. For normal gameplay, use the widescreen patch without `--unlock-fps` or `--fps`.

---

## Using the precompiled Linux binary

Put the patcher somewhere convenient, for example in the same folder as `Game.exe`, then make it executable:

```bash
chmod +x madagascar-widescreen-fix-linux-fps
```

Patch the default `./Game.exe` or `./Game/Game.exe` to 1920x1080 using the default advanced Hor+ patch:

```bash
./madagascar-widescreen-fix-linux-fps --width 1920 --height 1080
```

Patch widescreen and unlock FPS at the same time:

```bash
./madagascar-widescreen-fix-linux-fps \
  --game "/path/to/Madagascar/Game.exe" \
  --width 2560 \
  --height 1440 \
  --level advanced \
  --unlock-fps
```

Patch widescreen and set a specific FPS timer value:

```bash
./madagascar-widescreen-fix-linux-fps \
  --game "/path/to/Madagascar/Game.exe" \
  --width 2560 \
  --height 1440 \
  --fps 240
```

Apply only the FPS patch and leave the existing widescreen state unchanged:

```bash
./madagascar-widescreen-fix-linux-fps \
  --game "/path/to/Madagascar/Game.exe" \
  --fps-only \
  --unlock-fps
```

Use only the basic FOV patch:

```bash
./madagascar-widescreen-fix-linux-fps \
  --game "/path/to/Madagascar/Game.exe" \
  --width 1920 \
  --height 1080 \
  --level basic
```

Apply an extra FOV multiplier:

```bash
./madagascar-widescreen-fix-linux-fps \
  --game "/path/to/Madagascar/Game.exe" \
  --width 3440 \
  --height 1440 \
  --fov-multiplier 1.05
```

## Command-line options

```text
--game PATH              Path to Game.exe. Defaults to ./Game.exe or ./Game/Game.exe
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

## Recommended order on Wine / Lutris

1. Make a backup of the original `Game.exe`.
2. Run the widescreen patcher against `Game.exe`.
3. Do **not** use `--unlock-fps` or `--fps` for normal play, because it speeds up the game.
4. Manually set the Wine registry resolution value.
5. Launch the game through Wine or Lutris.

Example:

```bash
cp "/path/to/Madagascar/Game.exe" "/path/to/Madagascar/Game.exe.original"

./madagascar-widescreen-fix-linux-fps \
  --game "/path/to/Madagascar/Game.exe" \
  --width 2560 \
  --height 1440 \
  --level advanced \
  --unlock-fps
```

Then set this Wine registry value:

```text
HKEY_CURRENT_USER\Software\Activision\Madagascar\Settings\Display
"Resolution"="2560x1440"
```

---

# Manually editing the Wine registry resolution

The game stores the selected display resolution in the current user's registry area:

```text
HKEY_CURRENT_USER\Software\Activision\Madagascar\Settings\Display
```

The value should be:

```text
Resolution = WIDTHxHEIGHT
```

For example:

```text
Resolution = 2560x1440
```

## Method 1: Wine regedit GUI

This is usually the safest method.

For the default Wine prefix:

```bash
wine regedit
```

For a specific Lutris or custom Wine prefix:

```bash
WINEPREFIX="/path/to/wine-prefix" wine regedit
```

In Registry Editor:

1. Go to `HKEY_CURRENT_USER`.
2. Open or create `Software`.
3. Open or create `Activision`.
4. Open or create `Madagascar`.
5. Open or create `Settings`.
6. Open or create `Display`.
7. Create or edit a **String Value** named `Resolution`.
8. Set the value data to your target resolution, for example:

```text
2560x1440
```

Close Registry Editor, then launch the game.

## Method 2: Wine command line

For the default Wine prefix:

```bash
wine reg add 'HKCU\Software\Activision\Madagascar\Settings\Display' \
  /v Resolution \
  /t REG_SZ \
  /d 2560x1440 \
  /f
```

For a specific prefix:

```bash
WINEPREFIX="/path/to/wine-prefix" wine reg add 'HKCU\Software\Activision\Madagascar\Settings\Display' \
  /v Resolution \
  /t REG_SZ \
  /d 2560x1440 \
  /f
```

You can confirm the value with:

```bash
WINEPREFIX="/path/to/wine-prefix" wine reg query 'HKCU\Software\Activision\Madagascar\Settings\Display'
```

## Method 3: Edit `user.reg` manually

Only do this while the game and all Wine processes for that prefix are closed.

First, locate the Wine prefix. Common examples:

```text
~/.wine
~/Games/madagascar
/path/to/lutris/prefix
```

The file to edit is:

```text
/path/to/wine-prefix/user.reg
```

Make a backup first:

```bash
cp "/path/to/wine-prefix/user.reg" "/path/to/wine-prefix/user.reg.bak"
```

Open `user.reg` in a text editor and search for:

```text
[Software\\Activision\\Madagascar\\Settings\\Display]
```

If it exists, make sure it contains:

```text
"Resolution"="2560x1440"
```

If it does not exist, add this block:

```reg
[Software\\Activision\\Madagascar\\Settings\\Display]
"Resolution"="2560x1440"
```

Save the file, then launch the game through the same Wine prefix.

Important: do not edit `user.reg` while Wine is running for that prefix, because Wine may overwrite your manual changes when it exits.

---

# Compiling from source on Linux

## Requirements

You need a C++17-capable compiler and `make`.

On Debian / Ubuntu:

```bash
sudo apt install build-essential
```

On Fedora:

```bash
sudo dnf install gcc-c++ make
```

On Arch Linux:

```bash
sudo pacman -S base-devel
```

## Build

Extract the source package, then run:

```bash
make
```

This creates:

```text
madagascar-widescreen-fix
```

Run it like this:

```bash
./madagascar-widescreen-fix --game "/path/to/Game.exe" --width 2560 --height 1440 --unlock-fps
```

## Clean build files

```bash
make clean
```

---

# Compiling from source on Windows

The source is standard C++17 and can be compiled on Windows too.

## Option A: MSYS2 / MinGW-w64

Install MSYS2, then open the **MSYS2 UCRT64** shell and install the compiler:

```bash
pacman -S --needed mingw-w64-ucrt-x86_64-gcc make
```

Go to the extracted source folder:

```bash
cd /c/path/to/madagascar-widescreen-fix-source
```

Compile with:

```bash
make CXX=g++
```

This creates:

```text
madagascar-widescreen-fix.exe
```

If the Makefile produces a binary without `.exe`, you can also compile directly:

```bash
g++ -std=c++17 -O2 -Wall -Wextra -o madagascar-widescreen-fix.exe src/main.cpp
```

Use it from Command Prompt, PowerShell, or the MSYS2 shell:

```powershell
.\madagascar-widescreen-fix.exe --game "C:\Path\To\Madagascar\Game.exe" --width 1920 --height 1080 --unlock-fps
```

## Option B: Microsoft Visual Studio Build Tools

Open **x64 Native Tools Command Prompt for VS** in the extracted source folder.

Compile with:

```bat
cl /std:c++17 /O2 /EHsc src\main.cpp /Fe:madagascar-widescreen-fix.exe
```

Run it:

```bat
madagascar-widescreen-fix.exe --game "C:\Path\To\Madagascar\Game.exe" --width 1920 --height 1080 --unlock-fps
```

---

# Restoring the original executable

By default, the patcher creates:

```text
Game.exe.bak
```

To restore it on Linux:

```bash
cp "/path/to/Madagascar/Game.exe.bak" "/path/to/Madagascar/Game.exe"
```

To restore it on Windows Command Prompt:

```bat
copy "C:\Path\To\Madagascar\Game.exe.bak" "C:\Path\To\Madagascar\Game.exe"
```

---

# Notes

- `--layout auto` checks the same byte locations the uploaded patcher used to distinguish supported executable layouts.
- If auto-detection fails but you know the executable is compatible, try `--layout a`, `--layout b`, or `--force`.
- The FPS patch changes two float values at the game's frame-timer initialization site from `60.0f` to your chosen value.
- `--unlock-fps` is implemented as a high internal timer value of `1000.0f`.
- The included source is not the original author's exact source code. It is a reconstructed, readable C++17 implementation of the patch logic recovered from the uploaded executable.
- The EXE patch and the registry resolution value are separate. The EXE patch changes widescreen/FPS behavior; the registry value tells the game which resolution to use.
