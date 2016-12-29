; Created by: Roy Smart, Nicholas Bonham
; Date: 11-08-2016
;Purpose: This function reads and unzips IRIS Si IV data and copies it to a specified directory.
function iris_sequence_read, dir

	; Find all the files in this sequence
	orig_fn = FILE_SEARCH(dir, "iris_l2_????????_??????_??????????_raster_t???_r?????.fits.gz")

	; Define the location where the files will be unzipped to
	split=strpos(orig_fn[0], 'iris')
	base_fn = strmid(orig_fn, split,strlen(orig_fn[0])-3-split)
	out_fn = "/disk/data/roysmart/MINND/" + base_fn

	; Decompress the .gz file into the output directory
	FILE_GUNZIP, orig_fn, out_fn, /VERBOSE 

	; Load the sequence using the provided iris_load procedure                   
	data = []        
	FOREACH elem, out_fn DO BEGIN        
	   d = iris_load(elem)    
	   iwin = d->getwindx(1403)
	   next_data = TRANSPOSE(d->getvar(iwin, /load))
	   help, next_data
	   nsz = SIZE(next_data)
	   next_data = REFORM(next_data, 1, nsz[1], nsz[2], nsz[3])
	   data=[data, next_data]
	   help, data
	ENDFOREACH

	FILE_DELETE, out_fn

	return, data

 end
