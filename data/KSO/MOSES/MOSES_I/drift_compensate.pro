;+
;NAME:
;  DRIFT_COMPENSATE
;PURPOSE:
;  Compensate for drift in a movie. Works to sub-pixel precision.
;  The data cube is aligned to the central image or to a specified
;  image.
;CALLING SEQUENCE:
;  newcube = drift_compensate(cube [, offsets=offsets])
;INPUTS:
;  cube --- A float or double data cube, dimensions (Nx,Ny,Nimages).
;OUTPUTS:
;  newcube --- a new data cube, of somewhat smaller dimensions than
;     the input one, with all the images registered to match the 
;     central image.
;OPTIONAL KEYWORD INPUTS
;  alignto --- index of image to align the rest to. Default value
;     is Nimages/2.
;OPTIONAL KEYWORD OUTPUTS
;  offsets --- floating point array of offsets, with Nimages elments.
;HISTORY:
;  2006-Mar-29 CCK
;  2006-Apr-14 CCK Reset direction set with each call to Powell's method.
;  2006-Apr-15 CCK Substituted Amoeba instead of Powell, added timing stuff.
;	2006-Jun-21 CCK Added prefiltering of image2 to prevent shift-dependent
;		contribution of noise to the badness.
;-

;**************************
;* This is the function   *
;* to be minimized.       *
;**************************
function badness, offset
common driftcomp, image1, image2, Nx, Ny
dx = offset[0]
dy = offset[1]

;Calculate shifted image:
image2shift = double( fourier_image_shift(image2, dx, dy) )

;Rounded versions of offsets:
dxr = round(dx)
dyr = round(dy)

;Calculate the cross-covariance.
;Note the restricted range of subscripts.
i1avg = mean(      image1[(dxr>0):Nx-1+(dxr<0), (dyr>0):Ny-1+(dyr<0)] )
i2avg = mean( image2shift[(dxr>0):Nx-1+(dxr<0), (dyr>0):Ny-1+(dyr<0)] )
covariance = total( (      image1[(dxr>0):Nx-1+(dxr<0), (dyr>0):Ny-1+(dyr<0)] - i1avg ) $
                  * ( image2shift[(dxr>0):Nx-1+(dxr<0), (dyr>0):Ny-1+(dyr<0)] - i2avg ) )

print, "...offset ",dx,", ",dy,", covariance = ",covariance

return, -covariance  ;Cross-covariance is to be MAXIMIZED.
end


;***********************************
;*                                 *
;*    M A I N    P R O G R A M     *
;*                                 *
;***********************************
function drift_compensate, cube, offsets=offsets, alignto=alignto
common driftcomp, image1, image2, Nx, Ny
cubesize = size(cube)
Nx = cubesize[1]
Ny = cubesize[2]
Nimages = cubesize[3]
newcube = fltarr(Nx,Ny,Nimages) ;Result goes here.

if n_elements(alignto) ne 1 then alignto = Nimages/2.

xoff = fltarr(Nimages)
yoff = fltarr(Nimages)

image1 = double(cube[*,*,alignto])  ;The reference image
offset = [0.0,0.0] ;initial guess

;Define prefiltering kernel
kernel = [[1,2,1],[2,4,2],[1,2,1]]/16.0d

started = systime()
message,' Started '+started, /informational
for i =0, Nimages-1 do begin
   print,"Drift compensation: aligning image ",i
   image2 = ck_convol(cube[*,*,i],kernel,/edge_truncate)
		;Note filtering to prevent alignment bias.
   itmax = 100
   ;Xi = [[0.0, 1.0],[1.0,0.0]] ;initial direction set for Powell's method
   ;powell, offset, Xi, 1e-4, Fmin, "badness", $
   ;   iter=iter, itmax=itmax
   offset = amoeba(1e-6, function_name="badness", ncalls=iter, nmax=itmax, $
      P0=offset, scale=[1.0,1.0])
   xoff[i] = offset[0]
   yoff[i] = offset[1]
   print," ...returned after ",iter," iterations, offset [",xoff[i],",",yoff[i],"]"
   newcube[*,*,i] = float( fourier_image_shift(image2,xoff[i],yoff[i]) )
   ;print,"      direction set = ",Xi  ;diagnostic for Powell's method
endfor

message,' Started '+started,/informational
message,' Completed '+systime(),/informational

print,"*** offsets found for control image: [",xoff[alignto],",",yoff[alignto],"] ***"
print

offsets = {x:xoff, y:yoff}
return, newcube
end
