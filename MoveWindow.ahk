if !asPlugin {
  MsgBox, , MoveWindow via AutoHotkey,
    ( LTrim
      English Manual:

      Ctrl + Alt + Arrow keys: `tMove window
      Ctrl + Alt + Numpad 1-9: `tPut the window on 9-grid postions
      Ctrl + Alt + Numpad Enter: `tMove window to the next screen
      
      The window is adsorbed to the screen edge when near and approaching,
      with sound effect.
      The window cycles back into screen when moved out.
      
      Ctrl + Alt + s：`t`tEnter resize window mode until releasing Ctrl
                      `t`t`tor Alt.
                      `t`t`tPress "s" again to switch the resize anchor.
      Ctrl + Alt + Arrow keys: `tMove the resize anchor.
      (in resize window mode)
      


      Chinese Manual:

      Ctrl + Alt + 方向键：`t`t移动窗口
      Ctrl + Alt + 小键盘数字键：`t放置窗口到九宫格位置
      Ctrl + Alt + 小键盘回车键：`t移动窗口到下一个显示器
      
      靠近屏幕边缘会自动吸附，并有声效。
      移到屏幕外，会从另一边回来。
      
      Ctrl + Alt + s：`t`t进入调整窗口大小模式，直到放开 Ctrl 或 Alt；
                      `t`t`t重新按下 s 切换锚点。
      Ctrl + Alt + 方向键：`t`t移动锚点
      (在调整窗口模式下)
    )
}

#IfWinActive
^!Up::GoSub moveWindowUp
^!Down::GoSub moveWindowDown
^!Left::GoSub moveWindowLeft
^!Right::GoSub moveWindowRight
; Put the active window on 9 positions in the monitor work area
^!Numpad1::WinMove, A, , % monitorWorkArea().left
                       , % monitorWorkArea().bottom - WinGetPos("A").height
^!Numpad2::WinMove, A, , % monitorWorkArea().midX - WinGetPos("A").width / 2
                       , % monitorWorkArea().bottom - WinGetPos("A").height
^!Numpad3::WinMove, A, , % monitorWorkArea().right - WinGetPos("A").width
                       , % monitorWorkArea().bottom - WinGetPos("A").height
^!Numpad4::WinMove, A, , % monitorWorkArea().left
                       , % monitorWorkArea().midY - WinGetPos("A").height / 2
^!Numpad5::WinMove, A, , % monitorWorkArea().midX - WinGetPos("A").width / 2
                       , % monitorWorkArea().midY - WinGetPos("A").height / 2
^!Numpad6::WinMove, A, , % monitorWorkArea().right - WinGetPos("A").width
                       , % monitorWorkArea().midY - WinGetPos("A").height / 2
^!Numpad7::WinMove, A, , % monitorWorkArea().left
                       , % monitorWorkArea().top
^!Numpad8::WinMove, A, , % monitorWorkArea().midX - WinGetPos("A").width / 2
                       , % monitorWorkArea().top
^!Numpad9::WinMove, A, , % monitorWorkArea().right - WinGetPos("A").width
                       , % monitorWorkArea().top
^!NumpadEnter::SendInput +#{Right}
^!s::
  resizeWindowMode() {
    static anchors := ["top left", "bottom right"]
    anchors.InsertAt(1, anchors.Pop(anchors.Length()))
    Hotkey, IfWinActive
    if (anchors[1] == "top left") {
      TrayTip AutoHotkey, ResizeWindow Mode
      Hotkey, ^!Left, bringWindowLeftLeft
      Hotkey, ^!Right, bringWindowLeftRight
      Hotkey, ^!Up, bringWindowTopUp
      Hotkey, ^!Down, bringWindowTopDown
    } else if (anchors[1] == "bottom right") {
      TrayTip AutoHotkey, ResizeWindow Mode
      Hotkey, ^!Left, bringWindowRightLeft
      Hotkey, ^!Right, bringWindowRightRight
      Hotkey, ^!Up, bringWindowBottomUp
      Hotkey, ^!Down, bringWindowBottomDown
    }
    WinGetPos, x, y, width, height, A
    if (anchors[1] == "top left") {
      ToolTip, resize anchor`nW*H: %width%`, %height%, 0, 0
    } else {
      ToolTip, resize anchor`nW*H: %width%`, %height%, % width, % height
    }
    SetTimer, enableMoveWindowHotkeys, 100
  }

bringWindowLeftLeft:
resizeWindow(-1, 0, 0, 0, , , ["Ctrl", "Alt", "Left"])
return
bringWindowLeftRight:
resizeWindow(1, 0, 0, 0, , , ["Ctrl", "Alt", "Right"])
return
bringWindowRightLeft:
resizeWindow(0, -1, 0, 0, , , ["Ctrl", "Alt", "Left"])
return
bringWindowRightRight:
resizeWindow(0, 1, 0, 0, , , ["Ctrl", "Alt", "Right"])
return
bringWindowTopUp:
resizeWindow(0, 0, -1, 0, , , ["Ctrl", "Alt", "Up"])
return
bringWindowTopDown:
resizeWindow(0, 0, 1, 0, , , ["Ctrl", "Alt", "Down"])
return
bringWindowBottomUp:
resizeWindow(0, 0, 0, -1, , , ["Ctrl", "Alt", "Up"])
return
bringWindowBottomDown:
resizeWindow(0, 0, 0, 1, , , ["Ctrl", "Alt", "Down"])
return

enableMoveWindowHotkeys:
if !GetKeyState("Ctrl", "P") || !GetKeyState("Alt", "P") {
  ToolTip
  SetTimer, %A_ThisLabel%, Off
  Hotkey, ^!Left, moveWindowLeft
  Hotkey, ^!Right, moveWindowRight
  Hotkey, ^!Up, moveWindowUp
  Hotkey, ^!Down, moveWindowDown
}
return

moveWindowLeft:
moveWindow(-1, 0, , , ["Ctrl", "Alt", "Left"])
return
moveWindowRight:
moveWindow(1, 0, , , ["Ctrl", "Alt", "Right"])
return
moveWindowUp:
moveWindow(0, -1, , , ["Ctrl", "Alt", "Up"])
return
moveWindowDown:
moveWindow(0, 1, , , ["Ctrl", "Alt", "Down"])
return

