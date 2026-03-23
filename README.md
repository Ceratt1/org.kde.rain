# Rain

Rain is a KDE Plasma wallpaper with 3D rain particles, a configurable background image, and an overlay image that reacts to mouse movement.

This repository is an extension of the original `org.kde.rain` package:

https://github.com/vickoc911/org.kde.rain

I did not create the full original project. What I did here was extend it and adjust parts of the visual behavior, presentation, and package setup.

## Preview

![Rain Preview](git_gifs/example.gif)

## Requirements

To run this wallpaper properly, you should have:

1. KDE Plasma 6
2. KPackage support
3. Qt Quick
4. Qt Quick 3D
5. Qt5Compat GraphicalEffects support if you keep using effects from that module in future changes

On a regular Plasma 6 setup, most of this is usually already available.

## Installation

Place the project folder here:

`~/.local/share/plasma/wallpapers/org.kde.rain`

Then:

1. open your wallpaper settings in KDE Plasma
2. select `Rain`
3. choose a background image
4. choose an overlay image
5. test the interaction by moving the mouse

If you prefer to install it from the terminal, you can use:

```bash
kpackagetool6 --type Plasma/Wallpaper --install ~/.local/share/plasma/wallpapers/org.kde.rain
```

## Reloading After Changes

If you edit the QML files and want Plasma to pick up the changes, run:

```bash
plasmashell --replace
```

You can also switch to another wallpaper and then back to `Rain`.

## Project Structure

1. `contents/ui/main.qml`
Main wallpaper logic, including background, overlay interaction, and rain rendering

2. `contents/ui/config.qml`
Wallpaper configuration UI

3. `contents/config/main.xml`
Wallpaper configuration keys

4. `metadata.json`
Package metadata and author information

## Credits

Original package:

https://github.com/vickoc911/org.kde.rain

This version is my extension of that package.
