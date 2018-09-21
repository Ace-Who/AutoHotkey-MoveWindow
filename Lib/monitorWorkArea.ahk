monitorWorkArea(index := 0) {
  if index = 0
    index := IsFunc("getMonitorAt") ? getMonitorAt() : 1
  SysGet, Area, MonitorWorkArea, %index%
  return { left: AreaLeft
        , right: AreaRight
        , top: AreaTop
        , bottom: AreaBottom
        , midX: (AreaLeft + AreaRight)/2
        , midY: (AreaTop + AreaBottom)/2 }
}

