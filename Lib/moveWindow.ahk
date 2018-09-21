moveWindow(dx:=0, dy:=0, winTitle:="A", winText:="", holdKeys:="") {
  ; "holdKeys" should be an array if specified by user.
  WinGetPos, x, y, width, height, %winTitle%
  if (holdKeys = "") {
    WinMove, %winTitle%, %winText%, x + dx, y + dy
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
  d := [dx, dy]
  disp := []
  adsorb := []
  adsorbRange := 16 ; used for screen edges adsorption function.
  r := 0, rateCap := 60
  SetWinDelay 10
  moveWindow:
  While keyStateOfAll(holdkeys, "P") {
    r := (r < rateCap) ? (1.2 * r + 0.08) : rateCap

    WinGetPos, x, y, width, height, %winTitle%
    left := x, right := x + width
    top := y, bottom := y + height
    /* As WinMove ignores the decimal part of coordinates, an offset is needed
     * for some situation to make a random r result same displacement in both
     * directions.
     */
    ; disp.1 := (x<>0) * ((x>0) - 0.5) + Max(1, r) * dx
    ; disp.2 := (y<>0) * ((y>0) - 0.5) + Max(1, r) * dy
    disp.1 := dx ? r * dx + (x*dx>=0) * dx/Abs(dx) : 0
    disp.2 := dy ? r * dy + (y*dy>=0) * dy/Abs(dy) : 0

    ; Adsorb area edge.
    adsorb.1 := false
    adsorb.2 := false
    for i, sidePair in sidePairs {
      if d[i] {
        adsorb:
        for j, area in monitorWorkAreas {
          for k, side in sidePair {
            orthoSides := sidePairs[i+1] ? sidePairs[i+1] : sidePairs[1]
            oSide1 := orthoSides[1]
            oSide2 := orthoSides[2]
            if (1
                && %side% <> area[side] ; not on edge already
                && %side% < area[side] == d[i] > 0 ; appoaching edge
                && ( %oSide1% < area[oSide2]
                  && %oSide2% > area[oSide1] ) ; over edge
                && ( Abs(%side% - area[side]) <= adsorbRange ; near to edge
                  || Abs(%side% - area[side]) <= Abs(disp[i]) + 1 )
                                                             ; crossing edge
            && 1) {
              adsorb[i] := true
              disp[i] := area[side] - %side%
              adsAreaEdge := [area[oSide1], area[oSide2]]
              adsWinEdge := [%oSide1%, %oSide2%]
              break adsorb
            }
          }
        }
      }
    }

    WinMove, %winTitle%, %winText%, % x + disp.1, % y + disp.2
    ; WinGetPos, x, y, width, height, %winTitle%
    ; ToolTip ratio: %r%`nx`, y: %x%`, %y%`nW*H: %width%*%height%
    ; Make sound effect and delay moving window.
    if adsorb.1 || adsorb.2 {
      rf := Log(r/rateCap + 1)
      SoundBeep % Max((adsAreaEdge[2] - adsAreaEdge[1]) * rf, 80), 50
      SoundBeep % Max((adsWinEdge[2] - adsAreaEdge[1]) * rf, 80), 50
      Loop, 15 {
        Sleep 10
        if !keyStateOfAll(holdKeys, "P")
          break moveWindow
      }
    }

    ; Cycle back when off screens.
    offScreens := true
    for i, mon in monitors {
      offScreen := false
      for j, sidePair in sidePairs {
        side1 := sidePair.1
        side2 := sidePair.2
        if (%side1% >= mon[side2] || %side2% <= mon[side1]) {
          offScreen := true
          break
        }
      }
      if !offScreen {
        offScreens := false
        break
      }
    }
    if (offScreens) {
      ToolTip offScreens
      /* Find all monitor edges the window partly covers in moving direction.
       * Then find the nearest and appoaching one in them to jump into, or the
       * farthest in the back to cycle back to.
       */
      WinGetPos, x, y, width, height, %winTitle%
      jumpTo := [x, y]
      for i, sidePair in sidePairs {
        if !d[i]
          continue
        side1 := sidePair.1
        side2 := sidePair.2
        monEdgeAhead := monEdgeRear := ""
        for j, mon in monitors {
          orthoSides := sidePairs[i+1] ? sidePairs[i+1] : sidePairs[1]
          oSide1 := orthoSides[1]
          oSide2 := orthoSides[2]
          if (%oSide1% < mon[oSide2] && %oSide2% > mon[oSide1]) {
          ; through edge:
          ; The window covers part of the edge in the i-th direction.
            if (%side1% < mon[side1] == d[i] > 0) {
            ; appoaching edge
              monEdgeApproaching := d[i] > 0 ? mon[side1] : mon[side2]
              if (monEdgeAhead == ""
                  || d[i] > 0 == monEdgeApproaching < monEdgeAhead) {
                monEdgeAhead := monEdgeApproaching
              }
            } else if (monEdgeAhead == "") {
            ; deviating from edge
              monEdgeDeviating := d[i] > 0 ? mon[side1] : mon[side2]
              if (monEdgeRear == ""
                  || d[i] > 0 == monEdgeDeviating < monEdgeRear) {
                monEdgeRear := monEdgeDeviating
              }
            }
          }
        }
        if (monEdgeAhead == "" && monEdgeRear == "") {
        ; Normally, this function itself won't make this happen.
          continue
        }
        monEdgeJumpTo := monEdgeAhead == "" ? monEdgeRear : monEdgeAhead
        /* +1/-1 to make sure the window indeed has its border in the screen
         * and avoid endless off screens loop.
         */
        jumpTo[i] := d[i] > 0 ? monEdgeJumpTo - (%side2% - %side1%) + 1
                              : monEdgeJumpTo - 1
      }
      ; ToolTip % jumpTo[1] . ", " . jumpTo[2]
      WinMove, %winTitle%, %winText%, % jumpTo[1], % jumpTo[2]
    } else {
      ToolTip
    }
  }
  break_moveWindow:

  ; SetTimer removeToolTip, 2000
  return
}
