;+
;NAME:
;	moses_align_final
;PURPOSE:
;	Remove drift of MOSES m=0 images, and construction of new
;	data cubes in all orders based on this and the saved order
;	alignment data (mosesAlignOrders.sav). Movement of all images
;	is done from latest Level 1 data (mosesLevelOne.sav).
;	Results are saved to mosesAlignFinal.sav.
;CALLING SEQUENCE:
;	From IDL,
;  	IDL> .run moses_align_final
;	but it is better to run from the shell as a batch job,
;		% unlimit
;		% ssw_batch moses_align_final moses_align_final.log /date
;MODIFICATION HISTORY:
;	2006-Jun-21  C. Kankelborg
;	2006-Jun-22  C. Kankelborg. Fixed sign error in drift  
;		compensation of outboard orders.
;- 

set_plot,'z'
restore, 'mosesAlignOrders.sav' ;Retrieve alignment, refx, refy
restore, 'mosesLevelOne.sav'    ;Level1 data cubes
cubesize = size(cube_zero)
Nx = cubesize[1]
Ny = cubesize[2]
Nexp = cubesize[3]

;Find and remove drifts from cube_zero
alignto = 5 ;The 24s exposure is a good choice to align the rest to.
cube_zero = drift_compensate2(cube_zero, alignto=alignto, offsets=zeroOffsets)

;Find median control point alignments of outboard orders.
NcontrolPoints = n_elements(alignment[0].minus.cpoints.x)
degree = sqrt(NcontrolPoints) - 1  ;degree of warping polynomials.

for i=0, NcontrolPoints-1 do begin
	alignment[0:Nexp-1].minus.cpoints.x[i] = $
		median( alignment[0:Nexp-1].minus.cpoints.x[i] )
	alignment[0:Nexp-1].minus.cpoints.y[i] = $
		median( alignment[0:Nexp-1].minus.cpoints.y[i] )
		
	alignment[0:Nexp-1].plus.cpoints.x[i] = $
		median( alignment[0:Nexp-1].plus.cpoints.x[i] )
	alignment[0:Nexp-1].plus.cpoints.y[i] = $
		median( alignment[0:Nexp-1].plus.cpoints.y[i] )
endfor

;Align cube_minus to cube_zero
for i=0, Nexp-1 do begin
	imx = - zeroOffsets.x[i] + alignment[i].minus.cpoints.x
	imy = - zeroOffsets.y[i] + alignment[i].minus.cpoints.y
	polywarp, imx, imy, refx, refy, degree, Kx, Ky, /double
	cube_minus[*,*,i] = poly_2d(cube_minus[*,*,i], Kx, Ky, 2, $
		cubic=-0.5, missing=NaN)
endfor

;Align cube_plus to cube_zero
for i=0, Nexp-1 do begin
	imx = - zeroOffsets.x[i] + alignment[i].plus.cpoints.x
	imy = - zeroOffsets.y[i] + alignment[i].plus.cpoints.y
	polywarp, imx, imy, refx, refy, degree, Kx, Ky, /double
	cube_plus[*,*,i] = poly_2d(cube_plus[*,*,i], Kx, Ky, 2, $
		cubic=-0.5, missing=NaN)
endfor

save, file='mosesAlignFinal.sav'

end
