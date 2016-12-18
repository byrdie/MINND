;+
; :Author: roysmart
;-
; Created by: Roy Smart, Nicholas Bonham
; Date: 11-08-2016
; Purpose: This procedure is a driver for the iris-seqeunce-read function.


pro iris_datset_gen


a=find_rasters('/exports/fi1/IRIS/archive/level2/')
print, 'Number of matches ', n_elements(a)
f= long(n_elements(a)*RANDOMU(seed,1))
print,'Random image index:', f 
nextdir=a[f]

split=strpos(nextdir, 'iris')
path=strmid(nextdir,0,split)
filename=strmid(nextdir, split,strlen(nextdir)-3-split)
print, filename
data=iris_sequence_read(path, filename) 
img1=data[*,*,0]

print, mean(img1)




;core_val=mean(img[core_ind,*])
;print, core_val
atv, img1
end
