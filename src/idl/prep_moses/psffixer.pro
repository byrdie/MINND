;Author: Shane Atwood
;Purpose: This  program uses the filters calculated in mosespsf.pro and applies
;them to three arrays, typically MOSES images. Since the program calls
;mosespsf.pro, it also takes and infinite order vector and jlambda0 in its
;inputs.

pro psffixer, minus, zero, plus,infinord, jlambda0

help, minus

foo=size(minus)
Nx=foo[1]
Ny=foo[2]

hannwindow=hanning(Nx,Ny,/double)

;moses_nan_smoothing, minus, NANDICES=a_nandices, GOODINDICES=a_goodindices, /iterate
;moses_nan_smoothing, zero, NANDICES=b_nandices, GOODINDICES=b_goodindices, /iterate
;moses_nan_smoothing, plus, NANDICES=c_nandices, GOODINDICES=c_goodindices, /iterate

af=minus
bf=zero
cf=plus

SA=where(~finite(af), /NULL)
MaskA=replicate(1.0,Nx,Ny)
MaskA[SA]=0
af[SA] = 0

SB=where(~finite(bf), /NULL)
MaskB=replicate(1.0,Nx,Ny)
MaskB[SB]=0
bf[SB] = 0

SC=where(~finite(cf), /NULL)
MaskC=replicate(1.0,Nx,Ny)
MaskC[SC]=0
cf[SC] = 0


Mask=MaskA*MaskB*MaskC


rad=50
kernel = GAUSSIAN_FUNCTION([rad, rad], WIDTH=5 * rad, /NORMALIZE)
mask = CONVOL_FFT(mask, kernel)
ss=where(mask lt (TOTAL(kernel)-1e-3), /NULL)
mask[ss]=0
mask = CONVOL_FFT(mask, kernel)

af*=mask
bf*=mask
cf*=mask

;TESTING!

atwid=fft(af,/double)
btwid=fft(bf,/double)
ctwid=fft(cf,/double)

;atwid=ftransformer(af,20)
;btwid=ftransformer(bf,20)
;ctwid=ftransformer(cf,20)
filter=mosespsf(af, bf, cf,infinord,jlambda0)


 
afilter=filter(*,*,0)
bfilter=filter(*,*,1)
cfilter=filter(*,*,2)


 
count=(mean(minus))
 
gain=10

afilter=afilter/(1.+(abs(afilter)/(2*gain))^2)
bfilter=bfilter/(1.+(abs(bfilter)/(2*gain))^2)
cfilter=cfilter/(1.+(abs(cfilter)/(2*gain))^2)

atwid*=afilter
btwid*=bfilter
ctwid*=cfilter

minus=float(fft(atwid,/inverse))
zero=float(fft(btwid,/inverse))
plus=float(fft(ctwid,/inverse))



;images=[[[minus]],[[zero]],[[plus]]]
;message, 'debug'
;return, images

end
