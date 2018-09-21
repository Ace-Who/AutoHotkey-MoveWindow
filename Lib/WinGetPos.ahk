WinGetPos(WinTitle := "", WinText := "", ExcludeTitle := ""
        , ExcludeText := "") {
  WinGetPos, x, y, width, height, %WinTitle%, %WinText%, %ExcludeTitle%
           , %ExcludeText%
  return { x: x
      , y: y
      , width: width
      , height: height }
}
