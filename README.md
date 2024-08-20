# Joramo-AutoHotKey
Lee's keyboard bindings and macros

## AutoHotKey

`macOS_plus.ahk` collection of bindings and macros:

* macOS-like cursor keybindings
* windows controls
* ambidextrous mouse 
* text replacements
* window management 
  * move to upper left, bottom half, full screen, etc
  * move window to other Virtual Desktop
  * macOS style `cmd-tab` and `cmd-~` app/window cycling
* switch Virtual Desktop/Spaces, move windows between
* application specific hacks

## Kinesis Keyboard Macros

Some of the AHK keybindings might not make sense without knowing that I use a Kinesis Keyboard with the keyboard re-mappings. Compared to QMK/VIA, Kinesis uses a fairly limited and simple syntax that should be easy to port to other keyboards.

The AHK macros assume that you are using `layout3.txt` file. 

The `layout1.txt` file is for use on a Kinesis keyboard attached to MS Windows WITHOUT the AHK file. It provides a minimal set of macOS keyboard shortcuts.