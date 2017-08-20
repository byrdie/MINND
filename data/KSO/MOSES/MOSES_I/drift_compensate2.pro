;+
;NAME:
;  DRIFT_COMPENSATE2
;PURPOSE:
;  Compensate for drift in a movie. Works to sub-pixel precision.
;  The data cube is aligned to the central image or to a specified
;  image. Like the original DRIFT_COMPENSATE, but incorporates some
;	good ideas from COREGISTRATE such as input filtering, cubic
;	convolution interpolation, graceful handling of NaN values, and
;	a merit function based on squared residuals.
;CALLING SEQUENCE:
;  newcube = drift_compensate2(cube [, offsets=offsets] $
;			[, alignto=alignto])
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
;	2006-Jun-21 CCK Based on DRIFT_COMPENSATE and COREGISTRATE.
;  2012-Feb-02 CCK Having convergence issues, and have moved to straight
;     least squares; this is better but still not robust enough.
;-

;*******************************************************
;* This is the function to be minimized.               *
;* Modeled after chisq_badness() in coregistrate.pro.  *
;*******************************************************
function badness, offset
common driftcomp, image1, image2, Nx, Ny
dx = offset[0]
dy = offset[1]

;Calculate shifted image:
image2shift = double( cubic_image_shift(image2, dx, dy) )

;Find pixels that are good in both the reference and the shifted image.
ss = where(finite(image1) and finite(image2shift))
if ss[0] eq -1 then message,'Panic! Panic! There is no good data!'
Ndeg = n_elements(ss)

;Calculate renormalized reference image
mean_i2shift = mean(image2shift[ss])
mean_i1 = mean(image1[ss])
ref = image1 * mean_i2shift/mean_i1

;Badness is calculated like a chi squared statistic.
minvalue = 0.1 * mean_i2shift
   ;used to avoid really small denominator values in chisq below. After all,
   ;we don't really believe the low values so much because they are
   ;susceptible to errors in dark subtraction. (CCK 2012-Feb-02)
chisq = total( (image2shift[ss] - ref[ss])^2/mean_i2shift )/Ndeg
;chisq = total( (image2shift[ss] - ref[ss])^2/(image2shift[ss]>minvalue) )/Ndeg

print, "...offset [",dx,", ",dy,"], badness = ",chisq

return, chisq
end


;***********************************
;*                                 *
;*    M A I N    P R O G R A M     *
;*                                 *
;***********************************
function drift_compensate2, cube, offsets=offsets, alignto=alignto
common driftcomp, image1, image2, Nx, Ny
cubesize = size(cube)
Nx = cubesize[1]
Ny = cubesize[2]
Nimages = cubesize[3]
newcube = fltarr(Nx,Ny,Nimages) ;Result goes here.
NaN = !values.f_nan  ;used for missing data.

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
	if (i eq alignto) then begin
		message,'Test: Align the control image to a noised version of itself.', $
			/informational
		pnoise, image2
	endif
	;Mark data around the edges of Cimage missing, to prevent POLYWARP from
	;extrapolating at the edges.
	image2[0,*]    = NaN
	image2[Nx-1,*] = NaN
	image2[*,0]    = NaN
	image2[*,Ny-1] = NaN

   itmax = 100
   offset = amoeba(1e-6, function_name="badness", ncalls=iter, nmax=itmax, $
      P0=offset, scale=[1.0,1.0])
   xoff[i] = offset[0]
   yoff[i] = offset[1]
   print," ...returned after ",iter," iterations, offset [",xoff[i],",",yoff[i],"]"
   newcube[*,*,i] = float( cubic_image_shift(cube[*,*,i],xoff[i],yoff[i]) )
		;Go back to original cube!
endfor

message,' Started '+started,/informational
message,' Completed '+systime(),/informational

print,"*** offsets found for noised control image: [",xoff[alignto],",",yoff[alignto],"] ***"
print

;impose zero offsets for control image
xoff[alignto] = 0
yoff[alignto] = 0
newcube[*,*,alignto] = cube[*,*,alignto]

offsets = {x:xoff, y:yoff}
return, newcube

end
