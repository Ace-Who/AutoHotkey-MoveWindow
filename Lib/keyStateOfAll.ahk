keyStateOfAll(keylist, mode := "") {
  For index, keyName in keylist {
    state := GetKeyState(keyName, mode)
    if !state
      return state ; 0 or empty
  }
  return state ; 1
}

