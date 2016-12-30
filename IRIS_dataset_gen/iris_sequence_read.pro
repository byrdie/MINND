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
	max_lambda_ind = 0
	min_lambda_ind = 0  
	max_x_ind = 0;
	min_x_ind = 0; 

	; Data for missing values
	m_cols = 0;
	m_rows = 0;
	m_frames = 0;
   
	FOREACH elem, out_fn DO BEGIN   

		d = iris_load(elem)   ; Load the next data cube object into memory 
		iwin = d->getwindx(1403)	; Find the Si IV window in the object

		; Load the data object into memory
		next_data = d->getvar(iwin, /load)	; Copy the Si IV data from the object
		help, next_data

		; Determine the line center and range for this hypercube
		IF i EQ 0 THEN BEGIN
	
			line_center = 1402.85	; Theoretical center of Si IV line
			sol = 2.998e18		; Speed of Light in Angstroms/s
			doppler_range = 3e15	; Range of doppler shifts to extract from IRIS data in Angstroms/s

			lambda=d->getlam(iwin)	; Load the list of wavelengths corresponding to each index
			near = Min(Abs(lambda - line_center), core_ind)	; Find the index closest to line center
			
			; Store the value of missing pixels
			iris_missing = d->missing()

			; Determine the change in wavelenght associated with +/- 300 km/s range
			dl = doppler_range * line_center / sol	; Doppler equation
			print, "Change in wavelength:", dl
			near = Min(Abs(line_center + dl - lambda), max_lambda_ind)	; Find the maximum range of the window
			near = Min(Abs(line_center - dl - lambda), min_lambda_ind)	; Find the minimum range of the window
			print, max_lambda_ind, core_ind, min_lambda_ind			
			
		ENDIF
    
		; Take only the data from the MOSES range
		next_data = next_data[min_lambda_ind:max_lambda_ind,*,*]	; Crop the data into +/- 300 km/s range
		nsz = SIZE(next_data)
		help, next_data

		; Find the remaining missing values
		IF i EQ 0 THEN BEGIN
			
			; Find remaining missing values and remove
			;half1 = next_data[*,0:nsz[2]/2,*]
			;half2 = next_data[*,nsz[2]/2:*,*]

			;h1sz = SIZE(half1)
			;h2sz = SIZE(half2)

			;help, half1
			;help, half2
  
			;missing1 = WHERE(half1 EQ iris_missing)	; missing values on first half of image
			;missing2 = WHERE(half2 EQ iris_missing)	; missing values on second half of image

			;m1_row = (missing1 / h1sz[1]) mod h1sz[2]		; rows with missing values on first half of image
			;m2_row = (missing2 / h2sz[1]) mod h2sz[2] + h1sz[2]	; rows with missing values on second half of image
			
			missing = WHERE(next_data[*,*,0] EQ iris_missing)

			m_row = (missing / nsz[1]) mod nsz[2]
			m1_row = m_row[WHERE(m_row LE nsz[2]/2)]
			m2_row = m_row[WHERE(m_row GT nsz[2]/2)]

			m1_pix = REFORM(next_data[*,*,0])
			m1_pix[*,*] = 0
			m1_pix[missing] = 1
			atv, m1_pix

			pmm, m1_row
			pmm, m2_row

			min_x_ind = max(m1_row) + 2	; the minimum range index is the maximum missing value on the first half plus one
			max_x_ind = min(m2_row) - 2	; the maximum range index is the minimum missing value on the second half minus one
			
			print,"MIN/MAX X INDEX:", min_x_ind, max_x_ind

			i++	; Increment the index so this only runs once
			
			
	
		ENDIF
		
		; Take only the data from the MOSES range
		next_data = next_data[*,min_x_ind:max_x_ind,*]	; Crop the data into +/- 300 km/s range
		nsz = SIZE(next_data)
		help, next_data


		next_data = TRANSPOSE(next_data)	; Transpose the data so the dimensions are: slit spatial position, spatial, spectral
		nsz = SIZE(next_data)	; Store the size for the reform operation
		next_data = REFORM(next_data, 1, nsz[1], nsz[2], nsz[3], /OVERWRITE)	; Add a time dimension to the cube
		data=[data, next_data]	; Append cube to the hypercube



	ENDFOREACH

	dsz = SIZE(data)

	; Flatten the array into the time dimension
	data = REFORM(data, dsz[1]*dsz[2],dsz[3],dsz[4])
	

	; Determine the readout noise by taking the standard deviation of 
	; a constant spatial point in time
	
	; Determine the intensity by integrating along the line core

	; Delete the files from disk
	FILE_DELETE, out_fn

	; Return the hypercube
	return, data

 end
