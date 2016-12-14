; Created by: Roy Smart, Nicholas Bonham
; Date: 11-08-2016
; Purpose: This procedure is a driver for the iris-seqeunce-read function.

pro iris_datset_gen


a=find_rasters('/exports/fi1/IRIS/archive/level2/2016/09/08')
f= fix(n_elements(a)*RANDOMU(seed,1))
nextdir=a[f]
print,f 
split=strpos(nextdir, 'iris')
path=strmid(nextdir,0,split)
filename=strmid(nextdir, split,strlen(nextdir)-3-split)
data=iris_sequence_read(path, filename) 

end