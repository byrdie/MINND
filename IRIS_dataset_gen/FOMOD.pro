;NAME:
;  FOMOD
;PURPOSE:
;  Given an inverted spatial-spectral data array of dimension 
;  (Nx, Ny, Nlambda) measured in pixels, generates images with dispersion
;  along the x-dimension such that output images are a function of 
;  Nx + ms*Nlambda where ms is the spectral order of the image. 
;CALLING SEQUENCE:
;  i2 = FOMOD(guess, ms, jlambda0)
;INPUTS:
;  guess = inverted spatial-spectral data array of dimension (Nx, Ny, Nlambda)
;    where Nx is along the dispersion direction and Nlambda is the depth of the 
;    inversion result in the lambda dimension (integer).  Nx, Ny, Nlambda are
;    given in pixels.
;  ms = Signed integer or floating point array that gives the spectral orders 
;    used to create the guess image.
;  jlamda0 = index within the lambda dimension corresponding to zero shift
;    on dispersion.  
;OUTPUT:
;  i2 = stack of images, a float array of dimensions (Nx, Ny, Nm) where
;    Nx is along the dispersion direction and Nm is the number of spectral 
;    orders. 
;HISTORY:
;  H Courrier 2011 Sep 22
FUNCTION FOMOD, guess, ms, jlambda0, margin

;  Get size of guess inversion.
gsize = SIZE(guess)
Nx = gsize[1]
Ny = gsize[2]
Nlambda = gsize[3]

;  Get number of spectral orders and max order.
Nm = (SIZE(ms))[1]
Nm_max = MAX(ABS(ms))
max_shift = Nm_max*Nlambda

;  Create output array large enough to hold shift from largest dispersion
;  order.
i2 = FLTARR((Nx+(2*max_shift)), Ny, Nm)

;  Shift/sum operation
FOR k = 0,Nm-1 DO BEGIN
	;  Zero pad guess array so that shift wrap does not affect images.  
	image = FLTARR((Nx+(2*max_shift)), Ny, Nlambda)
	image[(max_shift):(Nx-1+max_shift),*,*] = guess
	IF (ms(k) NE 0) THEN BEGIN	;Skip shifting m=0 case
		FOR i = 0,Nlambda-1 DO BEGIN
    		;  Shift along Nx, with jlambda0 index unshifted
    		image(*,*,i) = SHIFT(image[*,*,i],[ms(k)*(jlambda0-i),0])
 		ENDFOR
 	ENDIF
	i2[*,*,k] = TOTAL(image,3)
ENDFOR
;  Resize arrays to that of unshifted index
RETURN, i2[(max_shift):(Nx-1+max_shift),*,*]
END  	