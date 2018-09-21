resizeWindow(dLeft:=0, dRight:=0, dTop:=0, dBottom:=0
            , winTitle:="A", winText:="", holdKeys:="") {
  WinGetPos, x, y, width, height, %winTitle%
  if (holdKeys = "") {
    WinMove, %winTitle%, %winText%, % x + dLeft, % y + dTop
                                  , % width + dRight - dLeft
                                  , % height + dBottom - dTop
    return
  }
  ; Get coordinates of screens' edges and store them in an array.
  monitors := []
  monitorWorkAreas := []
  SysGet, MonitorCount, MonitorCount 
  Loop, %MonitorCount% {
    monitors.Push(monitor(A_Index))
    monitorWorkAreas.Push(monitorWorkArea(A_Index))
  } 
  sidePairs := [ ["left", "right"], ["top", "bottom"] ]
  dArgs := [[dLeft, dRight], [dTop, dBottom]]
  disps := [[0, 0], [0, 0]]
  adsorb := []
  adsorbRange := 16 ; used for screen edges adsorption function.
  r := 0, rateCap := 60
  SetWinDelay 10
  resizeWindow:
  While keyStateOfAll(holdKeys, "P") {
    r := (r < rateCap) ? (1.2 * r + 0.08) : rateCap
    WinGetPos, x, y, width, height, %winTitle%
    bds := [[x, x + width], [y, y + height]]
    /* As WinMove ignores the decimal part of coordinates, an offset is needed
     * for some situation to make a random r result same displacement in both
     * directions.
     */
    for i, dispPair in disps {
      for j, disp in dispPair {
        if dArgs[i][j] {
          d := dArgs[i][j]
          ; b := bds[i][j]
          ; disps[i][j] := (b<>0) * ((b>0) - 0.5) + Max(1, r) * d
          disps[i][j] := Round(r * d + (bds[i][j] * d >= 0) * d/Abs(d))
        }
      }
    }
    WinMove, %winTitle%, %winText%, % bds[1][1] + disps[1][1]
                                  , % bds[2][1] + disps[2][1]
                    , % bds[1][2] + disps[1][2] - (bds[1][1] + disps[1][1])
                    , % bds[2][2] + disps[2][2] - (bds[2][1] + disps[2][1])
  }
  WinGetPos, x, y, width, height, %winTitle%
  if (dArgs[1][1] || dArgs[2][1]) {
    ToolTip, resize anchor`nW*H: %width%`, %height%, 0, 0
  } else {
    ToolTip, resize anchor`nW*H: %width%`, %height%, % width, % height
  }
}
