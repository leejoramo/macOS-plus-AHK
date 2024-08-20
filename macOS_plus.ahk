; LEE JORAMO'S AUTOHOTKEY CUSTOMIZATIONS #####################################

; !#r      reload this script while running

; Hotkeys: ^ = Control; ! = Alt; + = Shift; # = Windows key; * = Wildcard;
;          & = Combo keys; Others include ~, $, UP (see "Hotkeys" in Help)
;          +^!# = Hyper
;          +^! = Hyper

; I have used my hardware keyboard macros to remap the keys to the left of the
; spacebar to by `win`, `alt/opt`, `ctrl`

; The `ctrl` key mostly becomes the `cmd` key. But of course this is not a 
; perfect match. I had tried to use the `win` key to be `cmd` but found too 
; many issues.

; shortcuts in the file that are commented out have likely been moved to 
; hardware keyboard macros

;
; AHK SCRIPT RIGHT CLICK MENU ITEMS ##########################################
;

; edit this script in VSCode via AHK menu
EditWithVsCode()
    {
        MsgBox script path %A_ScriptFullPath%
        Run "C:\Users\YOURUSERNAME\AppData\Local\Programs\Microsoft VS Code\Code.exe " "%A_ScriptFullPath%"
    }
    Menu, Tray, Add
    Menu, Tray, Add, Edit with VS Code, EditWithVsCode
return


; MAKE WINDOWS KEYBOARD MORE MAC LIKE ########################################
;
;   Close to recreating macOS's excellent Command, Shift, Alt, Ctrl cursor operations
;
;   Much of this section was inspired by:

    ;John Walker, 2010-11-25
    ;walkerj@gmail.com
    ;http://www.inertreactants.com
    ;https://autohotkey.com/board/topic/60675-osx-style-command-keys-in-windows/


;WIN-P cannot be remapped, but can be disabled.  WIN-L cannot be changed at all.
;HINT: I now use a hardware keyboard with macros to get around WIN-key issues.
;#p::return

; OSX "DELETE" MODIFIERS
^BS::Send {LShift down}{Home}{LShift Up}{Del}
!BS::Send {LCtrl down}{BS}{LCtrl up}

#If !WinActive("ahk_exe" "excel.exe")
    ; OSX NAVIGATION AND SELECTION WITH CMD
    ; Excel is excluded because it interferes with native row/column navigation
    ^Up::Send {ctrl down}{Home}{ctrl up}
    ^Down::Send {ctrl down}{End}{ctrl up}
    ^+Up::Send {shift down}{ctrl down}{Home}{ctrl up}{shift up}
    ^+Down::Send {shift down}{ctrl down}{End}{ctrl up}{shift up}
    ^Left::Send {Home}
    ^Right::Send {End}
    ^+Left::Send {shift down}{Home}{shift up}
    ^+Right::Send {shift down}{End}{shift up}
    #If

; OSX NAVIGATION AND SELECTION WITH ALT
!Left::Send {ctrl down}{Left}{ctrl up}
!Right::Send {ctrl down}{Right}{ctrl up}
!+Left::Send {ctrl down}{shift down}{Left}{shift up}{ctrl up}
!+Right::Send {ctrl down}{shift down}{Right}{shift up}{ctrl up}

; OSX NAVIGATION Paging
#Up::Send {PgUp}
#+Up::Send {shift down}{PgUp}{shift up}
#Down::Send {PgDn}
#+Down::Send {shift down}{PgDn}{shift up}


; SIMULATE OSX CLOSE WINDOW AND QUIT APPLICATION BEHAVIOR
; ^w:: Send ^F4
;^w::return
;The following will be picked off by OSX, if employed in a virtualized environment.
;It should however work to mimic OSX functionality if employed in native Win.
^q::!F4

; SIMULATE OSX TEXT EDITING
;  ^a::Send {ctrl down}a{ctrl up}
;  ^s::Send {ctrl down}s{ctrl up}
;  ^z::Send {ctrl down}z{ctrl up}
;  ^c::Send {ctrl down}{Insert}{ctrl up}
;  ^v::Send {shift down}{Insert}{shift up}
;  ^x::Send {ctrl down}{Insert}{ctrl up}{Delete}

; Paste Unformated Text from clipboard
^+!v:: 		; paste text only; formatted version remains in clipboard
	OriginalClipboardContents = %ClipBoardAll%
	ClipBoard = %ClipBoard%                             ; Convert to text
	Send ^v
	Sleep 200                                           ; Don't change clipboard while it is pasted
	ClipBoard := OriginalClipboardContents              ; Restore original clipboard contents
	OriginalClipboardContents =                         ; Free memory
	Return

; DISABLES UNMODIFIED WIN-KEY IN FAVOR OF OSX SPOTLIGHT-LIKE BEHAVIOR
; #Space::Send {LWIN}

; REPLACES ALT-TAB APPLICATION SWITCHING WITH OSX CMD-TAB
; <#Tab::AltTab
; !Tab::return

; REMAPS CTRL-LEFT-CLICK TO CMD AND REPLICATES OSX CTRL-CLICK RIGHT-CLICK
; LWIN & LBUTTON::send {ctrl down}{LButton}{ctrl up}
; RWIN & LBUTTON::send {ctrl down}{LButton}{ctrl up}
; CTRL & LBUTTON::send {RButton}


; mostly macOS style diacritals and symbols
; using `hyper` in place of `alt`.

>#[::send “
+>#[::send ”
>#]::send ‘
+>#]::send ’
>#,::send «
>#.::send »


;
; GENERAL SYSTEMS WIDE KEYS ##################################################
;


; BRING FORWARD ALL WINDOWS OF THE CURRENT APPLICATION
; This is a generalized version of
; https://superuser.com/questions/113162/bring-to-front-all-windows-for-a-certain-application-in-windows-7#125985

^!`::
    WinGetClass, class, A
    WinGet, id, list, ahk_class  %class%
    Loop, %id%
    {
        this_id := id%A_Index%
        WinActivate, ahk_id %this_id%
        ; MsgBox, The active window's this_id is "%this_id%".
    }
return

; MINIMIZE ALL WINDOWS OF THE CURRENT APPLICATION
^!m::
    WinGetClass, class, A
    WinGet, id, list, ahk_class  %class%
    Loop, %id%
    {
        this_id := id%A_Index%
        WinMinimize, ahk_id %this_id%
    }
return


; CYCLE ALL WINDOWS OF CURRENT APPLICATION
; Pull bottom window to the top, and force it to display
^`::
    ; need Process and Class to restrict to current application
    ; most apps have unquie window classes, but Chromium based apps
    ; share their primary window class. Thus Google Chrome, VS Code and
    ; Electron based apps all looked the same using only `class`
    WinGet, Active_ID, ID, A
    WinGet, Active_Process, ProcessName, ahk_id %Active_ID%
    WinGetClass, class, A
    WinGet, id, list, ahk_class  %class% ahk_exe %Active_Process%
    lastItem := id%id0%
    lastItemId :=  id%lastItem%
    WinActivate, ahk_id %lastItemId%
    WinSet, Top,,  ahk_id %lastItemId%
    Winset, AlwaysOnTop, On
    Winset, AlwaysOnTop, Off
return

; CLOSE CURRENT WINDOW AND ACTIVATE NEXT WINDOW OF CURRENT APP
; similar to the CYLCE ALL WINDOWS OF CURRENT APP, but closes the
; current window.
;
; Because some Apps have Tabs that are closed via the same `^w` shortcut,
; we only switch to the next active window if the current window no longer
; exists after sending `^w`
;
; RATIONAL: This makes the Application Context a little more like macOS
; where closing windows leaves you in the current application, and not
; a random window that is the next in the stack.
$^w::
    ; need Process and Class to restrict to current application
    ; most apps have unquie window classes, but Chromium based apps
    ; share their primary window class. Thus Google Chrome, VS Code and
    ; Electron based apps all looked the same using only `class`
    WinGet, Active_ID, ID, A
    WinGet, Active_Process, ProcessName, ahk_id %Active_ID%
    WinGetClass, class, A
    WinGet, id, list, ahk_class  %class% ahk_exe %Active_Process%
    lastItem := id%id0%
    lastItemId :=  id%lastItem%
    Send ^w
    Sleep 50
    WinGet, Current_ID, ID, A
    If (Current_ID != Active_ID) {
        WinActivate, ahk_id %lastItemId%
        WinSet, Top,,  ahk_id %lastItemId%
        Winset, AlwaysOnTop, On
        Winset, AlwaysOnTop, Off
    }
return



; Make the Right Windows Key act as the App Key (Menu Key)
; The small keyboard I use doens't have a dedicated App Key
;RWin::AppsKey

; Make Mouse ambidextrous
; Treat both Left and Right Mouse buttons as Primary
; Treat middle button as Secondary (aka Right)
RButton::LButton
MButton::RButton


; Kill Switch
!^q::
    msgbox, Quit Autohotkey
    exitapp
return

; Reload Script
!#r::
    MsgBox, 1,, Reload macOS AutoHotKey Script? 
    IfMsgBox, Cancel
        Return
    Reload
    Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
    MsgBox, 0,, The script could not be reloaded.
return


;
; WINDOW MANAGEMENT HACKS ####################################################
;
; Move windows via the keyboard


; QUARTER/HALF/FULL SCREEN FOR CURRENT WINDOW --------------------------------
;
; Script to allow positioning of windows based on quadrants of the current monitor. 
; Inspired by 
; https://autohotkey.com/board/topic/108780-move-window-to-half-quarter-of-current-monitor/
;
; LEFT ALT key plus one of the letters in the grid to
;
;     1
;     QWE
;     ASD
;     ZXC
;

^Numpad1::
>!z::
	MoveIt(1)
	return

^Numpad2::
>!x::
	MoveIt(2)
	return

^Numpad3::
>!c::
	MoveIt(3)
	return

^Numpad4::
>!a::
	MoveIt(4)
	return

^Numpad5::
>!s::
	MoveIt(5)
	return

^Numpad6::
>!d::
	MoveIt(6)
	return

^Numpad7::
>!q::
	MoveIt(7)
	return

^Numpad8::
>!w::
	MoveIt(8)
	return

^Numpad9::
>!e::
	MoveIt(9)
	return

;

; Move Window to Other Display -----------------------------------------------
;
; Uses Windows built in key sequence to move to next monitor to the "left"
;
; LEFT ALT 1
^NumpadAdd::
>!1::
    MoveIt(11)
	return




; Move Window span 2 Displays ------------------------------------------------
;
; Will span window across two Displays. Unlike the other window placement options, this
; requires manual configuration based on the monitors sizes and relative placement to each other.
;
; LEFT ALT 2
^NumpadSub::
>!2::
	MoveIt(12)
	return

MoveIt(Q)
{
  ; Get the windows pos
	WinGetPos,X,Y,W,H,A,,,
	WinGet,M,MinMax,A

  ; Calculate the top center edge
  CX := X + W/2
  CY := Y + 20

  ; MsgBox, X: %X% Y: %Y% W: %W% H: %H% CX: %CX% CY: %CY%

  SysGet, Count, MonitorCount

  num = 1
  Loop, %Count%
  {
    SysGet, Mon, MonitorWorkArea, %num%

    if( CX >= MonLeft && CX <= MonRight && CY >= MonTop && CY <= MonBottom )
    {

        MW := (MonRight - MonLeft)
		MH := (MonBottom - MonTop)
		MHW := (MW / 2)
		MHH := (MH / 2)
		MMX := MonLeft + MHW
		MMY := MonTop + MHH

        ; check if window is wider than a display,
        ; if it is wider, resize to the width of a monitor
        ;
        ; this is done to deal with windows that span two Displays.
        ; which caused problems when moving the window between Displays
        ; the value 1448 was determined manually. current displays are
        ; actually 1440 wide, but there seems to be some extra padding that
        ; is included in AHK's WinGetPos function
        if(W > 1448)
        {
            W = 1440
			WinMove,A,,X,Y,W,H
        }

        ; window NOT maximzed
		if( M != 0 )
			WinRestore,A

        ; the following 'if' statements are for different
        ; window placements triggered by key strokes
		if( Q == 1 )
			WinMove,A,,MonLeft,MMY,MHW,MHH
		if( Q == 2 )
			WinMove,A,,MonLeft,MMY,MW,MHH
		if( Q == 3 )
			WinMove,A,,MMX,MMY,MHW,MHH
		if( Q == 4 )
			WinMove,A,,MonLeft,MonTop,MHW,MH
		if( Q == 5 )
		{
            ; maximize to full screen if not currently max
			if( M == 0 )
				WinMaximize,A
			else
				WinRestore,A
		}
		if( Q == 6 )
			WinMove,A,,MMX,MonTop,MHW,MH
		if( Q == 7 )
			WinMove,A,,MonLeft,MonTop,MHW,MHH
		if( Q == 8 )
			WinMove,A,,MonLeft,MonTop,MW,MHH
		if( Q == 9 )
			WinMove,A,,MMX,MonTop,MHW,MHH
		if( Q == 11 )
        {
           ; move window to next display to the left
            Send +#{Left}
        }
		if( Q == 12 )
        {
            ; span two displays. Uncomment 'MsgBox' to help determine manual configuration
            ; for current display setup.
            ; MsgBox, Q10 X: %X% -- Y: %Y% -- Width: %W% -- Height: %H%.
			WinMove,A,,-8,0,2896,2568
        }
        return
    }

    num += 1
  }

return
}

;
; Spaces/Virtual Desktops ----------------------------------------------------
;

; set current Virtual Desktop ------------------------------------------------
; this assumes ONLY two virtual desktops

switchedDesktop := false
switchDesktop()
{
  global switchedDesktop
	if switchedDesktop
	{
		SendEvent ^#{Right}
		switchedDesktop := false
	}
	else
	{
		SendEvent ^#{Left}
		switchedDesktop := true
	}
}

; jump to next Desktop -------------------------------------------------------
; WINDOW SLASH
#/::switchDesktop()



; move current window to next Desktop
; WINDOW ALT SLASH
#!/::
  WinGetTitle, Title, A
  WinSet, ExStyle, ^0x80, %Title%
  switchDesktop()
  sleep, 50
  WinSet, ExStyle, ^0x80, %Title%
  WinActivate, %Title%
Return

;
; APPLICATION SPECIFIC HACKS #################################################
;

; WINDOWS EXPLORER -----------------------------------------------------------
;
; ctrl-up
;    moves up a folder within the same window
; ctrl-down
;    moves into a folder within the same window,
;    or opens the item with the default app
; This is another Mac-like hack

currentPath := "C:\"
getCurrentPath() {
    If WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        WinHWND := WinActive()
        For win in ComObjCreate("Shell.Application").Windows
            If (win.HWND = WinHWND) {
                currentPath := SubStr(win.LocationURL, 9)
                currentPath := RegExReplace(currentPath, "%20", " ")
                currentPath := RegExReplace(currentPath, "/", "\")
                Break
            }

    }
    return currentPath
}
#If WinActive("ahk_exe" "explorer.exe")
    ^Up::Send {AltDown}{Up}{AltUp}
    ^Down::
        Send {AppsKey}
        Sleep 100
        Send {Down 1}
        Sleep 50
        Send {Return}
        return
;    ~LControl::
;        if (A_PriorHotkey <> "~LControl" or A_TimeSincePriorHotkey > 400)
;        {
;            ; Too much time between presses, so this isn't a double-press.
;            KeyWait, LControl
;            return
;        }
;        Send {AppsKey}
;        Sleep 100
;        Send {Down 1}
;        Sleep 50
;        Send {Return}
;        Return
    ^e::
        currentPath := getCurrentPath()
        MsgBox, currentPath:  "%currentPath%"
        Run "C:\Users\joramo\AppData\Local\Programs\Microsoft VS Code\Code.exe ", "%currentPath%\"
        return

#if

^F24::
    Send {AppsKey}
    Sleep 100
    Send, r
    Sleep 50
    Send, {Down}
    Sleep 50
    Send, {_}{r}{t}
    Send, {Return}
    Sleep 50
    Send, {Down}
    return

; FIREFOX --------------------------------------------------------------------

#If WinActive("ahk_exe" "firefox.exe")


   ; trigger Firefox Toolbar Bookmarks
   ; quickly open bookmarks/bookmarklets by typing
   ;
   ; alt-Number
   ;
   ; bookmarks must be named according to `#:name' for example
   ; the PinBoard bookmarklet: "1:Pin"

    bookmarkletHotKey(keyCode) {
        ; open the "Bookmarks Toolbar Menu"
        Send, {AltDown}}{b}{AltUp}}
        Sleep, 1
        Send, {Down}{Down}{Down}{Down}
        Sleep, 1
        Send, {Right}
        Sleep, 1
        Send, %keyCode%
        Sleep, 1
        Send, {CtrlUp}{Return}{CtrlUp}
        return
    }
    !1::
        bookmarkletHotKey(1)
    return
    !2::
        bookmarkletHotKey(2)
    return
    !3::
        bookmarkletHotKey(3)
    return
    !4::
        bookmarkletHotKey(4)
    return
    !5::
        bookmarkletHotKey(5)
    return
    !6::
        bookmarkletHotKey(6)
    return

#If


; VS CODE --------------------------------------------------------------------
; in VS Code allow alt-space to trigger "Show All Commands" palette
; while keeping ctrl-shift-p trigger
; since there is no way to bind two triggers to on command in VScode

#If WinActive("ahk_exe" "Code.exe")
    !Space::Send {CtrlDown}{ShiftDown}p{ShiftUp}{CtrlUp}
#if


;
; TEXT REPLACEMENT PHRASES ###################################################
;
; I generally use a semi-colon ; to signify a the start of a text expansion
;
; Use `r to signify a line break that will be typed
; or place multi-line in ( )

; Lorem Ipsum ----------------------------------------------------------------
:*:;lorem0::Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt
:*:;lorem1::Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

; Quick Brown Fox
:*:;qbf::The quick brown fox jumped over the lazy dog, under the sliver moon.

; Numberwang
:*:;nw::Hello and welcome to Numberwang, the maths quiz that simply everyone is talking about!

; Spam
:*:;spam::
(
Egg and bacon
Egg, sausage and bacon
Egg and Spam
Egg, bacon and Spam
Egg, bacon, sausage and Spam
Spam, bacon, sausage and Spam
Spam, egg, Spam, Spam, bacon and Spam
Spam, Spam, Spam, egg and Spam
Spam, Sausage, Spam, Spam, Spam, Bacon, Spam, Tomato and Spam
Spam, Spam, Spam, Spam, Spam, Spam, baked beans, Spam, Spam, Spam and Spam
Lobster Thermidor aux crevettes with a Mornay sauce, garnished with truffle pâté, brandy and a fried egg on top, and Spam.

)
return

; Space
:*:;space::Space: the final frontier. These are the voyages of the starship Enterprise. Its continuing mission: to explore strange new worlds. To seek out new life and new civilizations. To boldly go where no one has gone before!

; Thanks
:*:;thanks::So Long, and Thanks for All the Fish

; Step
:*:;step::That is one small step for a man, one giant leap for mankind.

; Turtles
:*:;turtles::It's Turtles all the way down.


; code fixes -----------------------------------------------------------------
:*:.lenght::.length

; personal -------------------------------------------------------------------

:*:;na::YOUR NAME

; contact info
:*:;phd::DIRECT PHONE 
:*:;phc::CELL PHONE
:*:;phx::PHONE EXTENSION
:*:;firm::YOUR FIRMS NAME
:*:;title::YOUR TITLE
:*:;id::YOUR EMPLOYEE ID
:*:;emw::YOUR WORK EMAIL


; signatures -----------------------------------------------------------------
; short signature 
:*:;sigs::-- YOUR NAME

; long signature
:*:;sigd::
(
--
Lee Joramo
Data Integrations Developer - Mesa County Valley School Dist. 51
work: 970-254-5104  x11556
)
return


; dates ----------------------------------------------------------------------
:*:;date::
FormatTime, CurrentDateTime,, yyyy-MM-dd
Sleep, 100
SendInput %CurrentDateTime%
return



; WARNINGS ###################################################################

; display CapsLock -----------------------------------------------------------

    SetCapsLockState, Off
    width := B_ScreenWidth - 202
    height := B_ScreenHeight - 70

    ~*CapsLock::

    Sleep, 100
    if GetKeyState("CapsLock", "T")
    {
    	Progress, B1 M W200 H42 ZH0 FS20 WS900 x%width% y%height% CTFF0000, CAPS LOCK ON,, caplockwarning
        WinSet, Transparent, 175, caplockwarning
    }
    else
    {
    	Progress, off
    }

    return

; display NumLock ------------------------------------------------------------

    SetNumLockState, Off
    width := B_ScreenWidth - 202
    height := B_ScreenHeight - 70

    ~*NumLock::

    Sleep, 100
    if GetKeyState("NumLock", "T")
    {
    	Progress, B1 M W200 H42 ZH0 FS20 WS900 x%width% y%height% CTFF0000, Num LOCK ON,, caplockwarning
        WinSet, Transparent, 175, caplockwarning
    }
    else
    {
    	Progress, off
    }

    return


; MOUSE SCROLLING ############################################################

Shift & WheelUp:: ;Scroll left
ControlGetFocus, fcontrol, A
Loop 3  ; <-- Increase this value to scroll faster.
SendMessage, 0x114, 0, 0, %fcontrol%, A ;0x114 es WM_HSCROLL (Windows Message Horizontal Scroll) and the 0 after it is SB_LINELEFT (Scroll Bar Line Left).
return

Shift & WheelDown:: ;Scroll right
ControlGetFocus, fcontrol, A
Loop 3  ; <-- Increase this value to scroll faster.
SendMessage, 0x114, 1, 0, %fcontrol%, A ;0x114 es WM_HSCROLL and the 1 after it is SB_LINERIGHT.
return



; DISABLE RIGHT WINDOWS KEY FROM DISPLAYING START MENU #######################
;
; I am doing this to use the right Windows key as a modifier key,
; left windows key is used to activate the Start Menu.
;
; I think this needs to be after all other macros that use RWin, so putting
; it at the end of the file

RWin Up:: return

; NOTHING BELOW HERE #########################################################
; ############################################################################
