;Author: Shane Atwood
;Purpose: This code is designed to take three data files of images of an object
;with the same power spectra. It smoothes pixel area where the data is deemed to
;be bad and then processes data via the intermediate kernel method.
;The program needs three specified files as input arguments. To run original
;MOSES data, set your working directory to /disk/data/kankel/MOSESflight, and
;open idl. Type restore, "mosesLevelOne.sav" and assign minus, zero, and plus as desired
;flight sequence images.
;Additionally, the program requires a specified infinite order vector. This is
;the spectral line profile expected as m goes to infinity, or equivalently the
;line profile were we measuring with a slit rather than an extended object. This
;vector is called "infinord" in the user inputs.
;The user is required to specify the pixel in infinord corresponding to peak or
;desired wavelength. This is called "Ndesired"
;A separate program will call generated data to test this program.

function mosespsf, minus,zero,plus,infinord,Ndesired


;The next few lines take the size of the arrays input, then window the data.

foominus=size(minus)

Nx=foominus[1]
Ny=foominus[2]

hanning=hanning(Nx,Ny,/double)

af=hanning*minus
bf=hanning*zero
cf=hanning*plus


;The following finds where the data has been labeled bad, sets these pixels to
;zero, and smoothes the areas around them as to avoid ringing.




;This section of code calculates filters as per the MOSES proposal.(See page 10)

;atwid=fft(af,/double)
;btwid=fft(bf,/double)
;ctwid=fft(cf,/double)
;TESTING!!!
atwid=ftransformer(af,20)
btwid=ftransformer(bf,20)
ctwid=ftransformer(cf,20)




;;This pads infinord with 0's, making it as long as the x dimension of the data
;arrays

blank=lonarr(Nx)
ss=where(infinord ne -1)
blank(ss)=infinord(ss)

;This shifts the desired pixel of infinord to the origin and reverses the vector
;for the minus order

Pvecplus=shift(blank,-Ndesired)
Pvecminusinitial=reverse(Pvecplus)
Pvecminus=shift(Pvecminusinitial,1)

;;This section makes blank arrays of the same dimensions as the arrays minus,
;zero, and plus. It then inserts the vectors along the bottom row of the blank
;arrays

Pplus=dblarr(Nx,Ny)
Pminus=dblarr(Nx,Ny)

Pplus(*,0)=Pvecplus
Pminus(*,0)=Pvecminus


;Here are the Fourier transform of the P quantities. Note that the line profile
;of the zero order is assumed to be a delta function, so its FT is just an array
;of ones. Therefore, it is ignored in the following.

Pplustwid=fft(Pplus,/double)
Pminustwid=fft(Pminus,/double)


;;Here are the correction filters, calculated on page 10 of the MOSES flight proposal
afilter=(abs(Pminustwid)^(2./3))*(abs(Pplustwid)^(-1./3))*((abs(btwid)*abs(ctwid)))^(1./3)/(abs(atwid))^(2./3)
bfilter=(abs(Pminustwid)^(-1./3))*(abs(Pplustwid)^(-1./3))*((abs(atwid)*abs(ctwid))^(1./3))/(abs(btwid))^(2./3)
cfilter=(abs(Pplustwid)^(2./3))*(abs(Pminustwid)^(-1./3))*((abs(atwid)*abs(btwid))^(1./3))/(abs(ctwid))^(2./3)

afilter /= afilter[0,0]
bfilter /= bfilter[0,0]
cfilter /= cfilter[0,0]

;Iatwid=afilter*atwid
;Ibtwid=bfilter*btwid
;Ictwid=cfilter*ctwid


;;Here are the final images. The minus, zero and plus in the names correspond to the original minus, zero
;plus designation input into this file

;Iminusdoubleprime=fft(Iatwid,/inverse)
;Izerodoubleprime=fft(Ibtwid,/inverse)
;Iplusdoubleprime=fft(Ictwid,/inverse)

hamster = [[[afilter]],[[bfilter]],[[cfilter]]]
return, hamster

end







