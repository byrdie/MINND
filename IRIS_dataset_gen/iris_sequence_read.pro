; Created by: Roy Smart, Nicholas Bonham
; Date: 11-08-2016
;Purpose: This function reads and unzips IRIS Si IV data and copies it to a specified directory.
function iris_sequence_read, dir

	; Find all the files in this sequence
	orig_fn = FILE_SEARCH(dir, "iris_l2_????????_??????_??????????_raster_t???_r?????.fits.gz")

	; Define the location where the files will be unzipped to
	out_fn = "/disk/data/roysmart/MINND/" + STRTRIM(STRING(INDGEN(n_elements(orig_fn))),1)

	; Decompress the .gz file into the output directory
	FILE_GUNZIP, orig_fn, "/disk/data/roysmart/MINND/", /VERBOSE 

	; Load the sequence using the provided iris_load procedure                   
	data = [ ]        
	FOREACH elem, out_fn DO BEGIN        
	   data = [data, iris_load(elem)]        
	ENDFOREACH
                            
	; Select the appropriate window for Si IV
	iwin=d->getwindx(1403)
	;print, iwin
	;lambda=d->getlam(iwin)
	;near = Min(Abs(lambda - 1402.85), core_ind)
	data=d->getvar(iwin, /load)

	help,data

	return, data

 end
