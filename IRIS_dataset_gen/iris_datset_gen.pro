;+
; :Author: roysmart
;-
; Created by: Roy Smart, Nicholas Bonham
; Date: 11-08-2016
; Purpose: This procedure is a driver for the iris-seqeunce-read function.


pro iris_datset_gen

	; Find rasters based on correct criteia
	dir_list = find_rasters('/exports/fi1/IRIS/archive/level2/')
	print, 'Number of matches ', n_elements(dir_list)

	; Select a random image for tesing purposes
	rand_ind = long(n_elements(dir_list)*RANDOMU(seed,1))	; random index generation
	nextdir=dir_list[rand_ind]

	; Call procedure to read selected iris data into program memory
	data=iris_sequence_read(nextdir) 
	
	atv, REFORM(data[0,0,*,*])

	; Display video of data
	dsz = size(data)
	XINTERANIMATE, SET=[dsz[3], dsz[4], dsz[1]], /SHOWLOAD
	FOR I=0,dsz[1]-1 DO XINTERANIMATE, FRAME = I, IMAGE = REFORM(data[I,0,*,*])


end
