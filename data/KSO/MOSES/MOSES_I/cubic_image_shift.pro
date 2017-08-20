;+
;NAME:
;  CUBIC_IMAGE_SHIFT
;PURPOSE:
;  Shift images to sub-pixel accuracy by cubic convolution
;	interpolation. Treat NaN as missing. Note that the POLY_2D
;	bug in IDL 6 may fail to mark some edge pixels as missing.
;CALLING SEQUENCE:
;  shifted_image = cubic_image_shift(image, dx, dy) 
;INPUTS:
;	image --- 2d float or double array to be shifted.
;  dx --- shift in x.
;	dy --- shift in y.
;HISTORY:
;  2006-Jun-21 C. Kankelborg
;	2006-Jun-22 C. Kankelborg.  Forgot to define NaN. Fixed.
;-
function cubic_image_shift, image, dx, dy

NaN = !values.f_nan

isize = size(image)
Nx = isize[1]
Ny = isize[2]

Kx = [[-dx, 0], [1, 0]]
Ky = [[-dy, 1], [0, 0]]
image_shifted = poly_2d(image, Kx, Ky, 2, cubic=-0.5, missing=NaN)

return, image_shifted

end
