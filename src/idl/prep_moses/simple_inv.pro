function simple_inv, img, ms, jlambda0, Nlambda

  ;  Get size of guess inversion.
  gsize = SIZE(img)
  Nx = gsize[1]
  Ny = gsize[2]
  Nt = gsize[3]

  ;  Get number of spectral orders and max order.
  Nm = (SIZE(ms))[1]
  Nm_max = MAX(ABS(ms))
  max_shift = Nm_max*Nlambda


  i2 = FLTARR(Nx, (Ny+(2*max_shift)), Nt)
  i2[*,max_shift:-(max_shift+1),*] = img

  isz = SIZE(i2)
  i2 = REFORM(i2, isz[1], isz[2], isz[3], 1)
  i2 = REBIN(i2, isz[1], isz[2], isz[3], Nlambda)

  FOR k = 0,Nm-1 DO BEGIN

    IF (ms(k) NE 0) THEN BEGIN  ;Skip shifting m=0 case
      FOR i = 0,Nlambda-1 DO BEGIN
        ;  Shift along Nx, with jlambda0 index unshifted
        i2[*,*,*,i] = SHIFT(i2[*,*,*,i],[0,(-1)*ms(k)*(jlambda0-i),0])
      ENDFOR
    ENDIF

  ENDFOR

  RETURN, i2[*,(max_shift):(Ny-1+max_shift),*,*]

end