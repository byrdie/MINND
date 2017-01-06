;+
; :Author: roysmart
;-
; Created by: Roy Smart, Nicholas Bonham
; Date: 11-08-2016
; Purpose: This procedure is a driver for the iris-seqeunce-read function.


pro iris_datset_gen

	; Location to save variables to restart computation
	vars_dir = 'minnd_levelA_vars.sav'

	; Logic to determine state variables for restart computation
	IF FILE_TEST(vars_dir) EQ 0 THEN BEGIN	; If the file does not exist, initialize to zero
		start_ind = 0
		tnfk = 0	; Total number of frames retained
		tnfe = 0	; Total number of frames eliminated
		
	ENDIF ELSE BEGIN	; Otherwise restore the state of the variables from the .sav file
		RESTORE, vars_dir
	ENDELSE

	IF start_ind EQ !NULL THEN start_ind = 0


	; Specifiy location to save the files to
	base_dir = '/mnt/roy/iris_siIV/'

	; Find rasters based on correct criteia
	dir_list = find_rasters('/exports/fi1/IRIS/archive/level2/')
	print, 'Number of matches ', n_elements(dir_list)

	; Select a random image for tesing purposes
	;rand_ind = long(n_elements(dir_list)*RANDOMU(seed,1))	; random index generation

	FOR i=start_ind,n_elements(dir_list) DO BEGIN

		; Back up program state for restarting computation
		start_ind = i
		SAVE, start_int, tnfk, tnfe, FILENAMe=vars_dir

		nextdir=dir_list[i]
		PRINT, "_______________________________________________________"
		PRINT,"IRIS image index", i

		; Call procedure to read selected iris data into program memory
		data = iris_sequence_read(nextdir, num_frames_kept, num_frames_elim) 
		tnfk += num_frames_kept
		tnfe += num_frames_elim

		IF N_ELEMENTS(data) EQ 1 THEN CONTINUE
		help,data
		PRINT, "Number of frames retained", num_frames_kept
		PRINT, "Number of frames eliminated", num_frames_elim
		PRINT, "Total number of frames retained", tnfk
		PRINT, "Total Number of frames eliminated", tnfe
		

		; Save data to the storage space
		nfn = STRSPLIT(nextdir, '/', /EXTRACT)	; Use the filename provided by IRIS level 2
		sfn = base_dir + nfn[-1] + '.dat'
		PRINT, 'Saving:', sfn
		SAVE, data, FILENAME = sfn	; Save image stack to disk
	

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
