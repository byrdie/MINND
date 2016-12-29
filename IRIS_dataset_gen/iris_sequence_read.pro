; Created by: Roy Smart, Nicholas Bonham
; Date: 11-08-2016
;Purpose: This function reads and unzips IRIS Si IV data and copies it to a specified directory.
function iris_sequence_read, dir

	; Find all the files in this sequence
	orig_fn = FILE_SEARCH(dir, "iris_l2_????????_??????_??????????_raster_t???_r?????.fits.gz")

	; Define the location where the files will be unzipped to
	split=strpos(orig_fn[0], 'iris')	; Split the filename from the rest of the path
	base_fn = strmid(orig_fn, split,strlen(orig_fn[0])-3-split)	; Execute the split for all files in the list
	out_fn = "/disk/data/roysmart/MINND/" + base_fn	; Construct the path of the gunzipped location

	; Decompress the .gz file into the output directory
	FILE_GUNZIP, orig_fn, out_fn, /VERBOSE 

	; Load the sequence using the provided iris_load procedure 
	i = 0;                  
	data = [] 	; Define empty array to store hypercube
	core_ind = 0	; Define empty array to location of line centers 
	max_ind = 0
	min_ind = 0      
	FOREACH elem, out_fn DO BEGIN   

		d = iris_load(elem)   ; Load the next data cube object into memory 
		iwin = d->getwindx(1403)	; Find the Si IV window in the object

		; Determine the line center and range for this hypercube
		IF i EQ 0 THEN BEGIN
	
			line_center = 1402.85	; Theoretical center of Si IV line
			sol = 2.998e8			; Speed of Light
			doppler_range = 300e5	; Range of doppler shifts to extract from IRIS data

			lambda=d->getlam(iwin)	; Load the list of wavelengths corresponding to each index
  			near = Min(Abs(lambda - line_center), core_ind)	; Find the index closest to line center
			
			; Determine the change in wavelenght associated with +/- 300 km/s range
			dl = doppler_range * line_center / sol	; Doppler equation
			near = Min(Abs(line_center + dl - lambda), max_ind)	; Find the maximum range of the window
			near = Min(Abs(line_center - dl - lambda), min_ind)	; Find the minimum range of the window

			i++	; Increment the index so this only runs once
		ENDIF
     
		next_data = d->getvar(iwin, /load)	; Copy the Si IV data from the object
		next_data = next_data[min_ind:max_ind,*,*]	; Crop the data into +/- 300 km/s range
		next_data = TRANSPOSE(next_data)	; Transpose the data so the dimensions are: slit spatial position, spatial, spectral
		nsz = SIZE(next_data)	; Store the size for the reform operation
		next_data = REFORM(next_data, 1, nsz[1], nsz[2], nsz[3])	; Add a time dimension to the cube
		data=[data, next_data]	; Append cube to the hypercube



	ENDFOREACH

	

	; Determine the readout noise by taking the standard deviation of 
	; a constant spatial point in time
	
	; Determine the intensity by integrating along the line core

	; Delete the files from disk
	FILE_DELETE, out_fn

	; Return the hypercube
	return, data

 end
