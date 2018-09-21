; Get the index of the monitor containing the specified x and y co-ordinates. 
getMonitorAt(x := "", y := "", default := 1) { 
  if (x == "" || y == "")
    WinGetPos, x, y, , , A
  SysGet, m, MonitorCount 
  ; Iterate through all monitors. 
  Loop, %m% {  ; Check if the window is on this monitor. 
    SysGet, Mon, Monitor, %A_Index% 
      /* This bounding is semi open closed, meaning that Right and Bottom
       * are not in the area.
       */
    if (x >= MonLeft && x < MonRight && y >= MonTop && y < MonBottom) 
      return A_Index 
  } 
  return default 
}
