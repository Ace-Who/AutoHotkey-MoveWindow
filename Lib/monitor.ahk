monitor(index := 0) {
  if index = 0
    index := IsFunc("getMonitorAt") ? getMonitorAt() : 1
  SysGet, Monitor, Monitor, %index%
  return { left: MonitorLeft
        , right: MonitorRight
        , top: MonitorTop
        , bottom: MonitorBottom
        , midX: (MonitorLeft + MonitorRight)/2
        , midY: (MonitorTop + MonitorBottom)/2 }
}

