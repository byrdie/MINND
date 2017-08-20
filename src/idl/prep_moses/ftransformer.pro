function ftransformer, img, NS

;TESTING!

;ps1=FFT(img)
ps1=ABS(FFT(img))
ps1f=FFT(ps1)
;stop
kernel=ps1*0.0
kernel[0:NS-1,0:NS-1]=HANNING(NS,NS)
kernelf=ABS(FFT(kernel))
kernelf/=kernelf(0,0)
ps1f*=kernelf
ps1final=FFT(ps1f,/inv)
;stop

return, ps1final
end
