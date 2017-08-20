FUNCTION doppler, cube

  Dt = 1  ; Temporal dimension
  Dy = 2  ; Spatial dimension
  Dl = 3  ; Wavelength dimension

  sz = SIZE(cube)
  
  
  ; Find the center of mass in wavelength
  tm = TOTAL(cube, Dl)
  
  
  l_cm = REFORM(TOTAL(cube * REBIN(REFORM(FINDGEN(sz[Dl]) - 10, [1, 1, sz[Dl]]), sz[Dt], sz[Dy], sz[Dl]), Dl) / tm, [sz[Dt], sz[Dy], 1])
  
  
  help, FINITE(l_cm)
  
  l_cm[WHERE(~FINITE(l_cm))] = 0
  
  help, l_cm
  
  return, l_cm
  

END