;+
; :Author: roysmart
;-
; Created by: Roy Smart, Nicholas Bonham
; Date: 11-08-2016
; Purpose: This procedure is a driver for the iris-seqeunce-read function.


pro iris_datset_gen, start_ind

	; Specifiy location to save the files to
	base_dir = '/mnt/roy/iris_siIV/'

	; Find rasters based on correct criteia
	dir_list = find_rasters('/exports/fi1/IRIS/archive/level2/')
	print, 'Number of matches ', n_elements(dir_list)

	; Select a random image for tesing purposes
	;rand_ind = long(n_elements(dir_list)*RANDOMU(seed,1))	; random index generation

	FOR i=start_ind,n_elements(dir_list) DO BEGIN

		nextdir=dir_list[i]
		PRINT,"IRIS image index", rand_ind

		; Call procedure to read selected iris data into program memory
		[num_frames_kept, num_frames_elim, data] = iris_sequence_read(nextdir) 

		IF data EQ 0 THEN CONTINUE
		;help,data
		;pmm, data
		PRINT, "Number of frames retained", num_frames_kept
		PRINT, "Number of frames eliminated", num_frames_elim

		; Save data to the storage space
		SAVE, 'data', FILENAME = base_dir + STRING(i) + '.dat'
	
		atv, REFORM(data[0,*,*])

		; Display video of data
		;dsz = size(data)
		;rdata = REBIN(data, dsz[1], 5 * dsz[2], 5*dsz[3])
		;rsz = SIZE(rdata)
		;XINTERANIMATE, SET=[rsz[2], rsz[3], rsz[1]], /SHOWLOAD
		;FOR I=0,rsz[1]-1 DO XINTERANIMATE, FRAME = I, IMAGE = REFORM(rdata[I,*,*])
		;XINTERANIMATE, /KEEP_PIXMAPS

	ENDFOR

	


end
