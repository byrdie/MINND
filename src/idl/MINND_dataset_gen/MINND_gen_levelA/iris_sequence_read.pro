; Created by: Roy Smart, Nicholas Bonham
; Date: 11-08-2016
;Purpose: This function reads and unzips IRIS Si IV data and copies it to a specified directory.
function iris_sequence_read, dir, num_frames_kept, num_frames_elim

	num_frames_kept = 0
	num_frames_elim = 0

	; Find all the files in this sequence
	orig_fn = FILE_SEARCH(dir, "iris_l2_????????_??????_??????????_raster_t???_r?????.fits.gz")

	; Define the location where the files will be unzipped to
	split=strpos(orig_fn[0], 'iris')	; Split the filename from the rest of the path
	base_fn = strmid(orig_fn, split,strlen(orig_fn[0])-3-split)	; Execute the split for all files in the list
	out_fn = "/disk/data/roysmart/MINND/" + base_fn	; Construct the path of the gunzipped location

	; Check if there are any files in this directory
	IF N_ELEMENTS(orig_fn) EQ 0 THEN return, 0

	; Decompress the .gz file into the output directory
	FILE_GUNZIP, orig_fn, out_fn

	; Load the sequence using the provided iris_load procedure 
	i = 0;                  
	data = []	; Define empty array to store hypercube
	core_ind = 0	; Define empty array to location of line centers 
	max_lambda_ind = 0
	min_lambda_ind = 0  
	max_x_ind = 0;
	min_x_ind = 0;

	iris_y_res = 0; 
	iris_spectral_res = 0 
	moses_spatial_res = 0.59 ; arcseconds
	moses_spectral_res = 29e13 ; angstroms/s  

	FOREACH elem, out_fn DO BEGIN   

		d = iris_load(elem)   ; Load the next data cube object into memory 
		iwin = d->getwindx(1403)	; Find the Si IV window in the object

		; Load the data object into memory
		next_data = d->getvar(iwin, /load)	; Copy the Si IV data from the object
		;help, next_data

		; Determine the line center and range for this hypercube
		IF i EQ 0 THEN BEGIN
	
			line_center = 1402.85	; Theoretical center of Si IV line
			sol = 2.998e18		; Speed of Light in Angstroms/s
			doppler_range = 3e15	; Range of doppler shifts to extract from IRIS data in Angstroms/s

			lambda=d->getlam(iwin)	; Load the list of wavelengths corresponding to each index
			near = Min(Abs(lambda - line_center), core_ind)	; Find the index closest to line center
			
			; Store the value of missing pixels
			iris_missing = d->missing()

			; Store the resolution along the slit direction
			iris_y_res = d->getresy(iwin)

			; Store resolution in th spectral direction
			iris_spectral_res_A = lambda[1] - lambda[0]
			iris_spectral_res = iris_spectral_res_A * sol / line_center

			; Determine the change in wavelenght associated with +/- 300 km/s range
			dl = doppler_range * line_center / sol	; Doppler equation
			;print, "Change in wavelength:", dl
			near = Min(Abs(line_center + dl - lambda), max_lambda_ind)	; Find the maximum range of the window
			near = Min(Abs(line_center - dl - lambda), min_lambda_ind)	; Find the minimum range of the window
			;print, max_lambda_ind, core_ind, min_lambda_ind			
			
		ENDIF
    
		; Take only the data from the MOSES range
		next_data = next_data[min_lambda_ind:max_lambda_ind,*,*]	; Crop the data into +/- 300 km/s range
		nsz = SIZE(next_data)
		;help, next_data

		

		; Find the remaining missing values
		IF i EQ 0 THEN BEGIN
			
			missing = WHERE(next_data[*,*,0] EQ iris_missing)

			m_row = (missing / nsz[1]) mod nsz[2]
			m1_row = m_row[WHERE(m_row LE nsz[2]/2)]
			m2_row = m_row[WHERE(m_row GT nsz[2]/2)]

			min_x_ind = max(m1_row) + 2	; the minimum range index is the maximum missing value on the first half plus one
			max_x_ind = min(m2_row) - 2	; the maximum range index is the minimum missing value on the second half minus one
			
			IF min_x_ind GE max_x_ind THEN RETURN, 0

			i++	; Increment the index so this only runs once
			
			
	
		ENDIF
		;help, next_data

		; Take only the data from the MOSES range
		next_data = next_data[*,min_x_ind:max_x_ind,*]	; Crop the data into +/- 300 km/s range
		nsz = SIZE(next_data)
		;help, next_data


		next_data = TRANSPOSE(next_data)	; Transpose the data so the dimensions are: slit spatial position, spatial, spectral
		nsz = SIZE(next_data)	; Store the size for the reform operation
		next_data = REFORM(next_data, 1, nsz[1], nsz[2], nsz[3], /OVERWRITE)	; Add a time dimension to the cube
		nsz = SIZE(next_data)	
		;help, next_data

		; Take only some factor times the width of the data
		width_factor = 3
		num_frames = nsz[3] / (width_factor * nsz[4])
		
		IF num_frames EQ 0 THEN return, 0

		FOR J = 1,num_frames DO BEGIN
			data = [data, next_data[*,*,(J-1)*width_factor*nsz[4]:J*width_factor*nsz[4],*]]
		ENDFOR

		;data=[data, next_data]	; Append cube to the hypercube



	ENDFOREACH
	;help, data
	dsz = SIZE(data)

	; Flatten the array into the time dimension
	data = REFORM(data, dsz[1]*dsz[2],dsz[3],dsz[4])
	dsz = SIZE(data)
	;help, data
	
	; Enforce positivity
	data = POSITIVITY(data)	

	; Determine the readout noise by taking the standard deviation of 
	; the edges of the image
	data_var = MEAN(VARIANCE(data[*,*,-1],DIMENSION=1))
	print, "Readout noise: ", data_var
	
	
	; Determine the intensity by integrating along the line core
	core_ind = core_ind - min_lambda_ind	; update the core index
	core_stripe = REFORM(data[*,*,core_ind])
	;data[*,*,core_ind] = MAX(data)
	help, core_stripe
	data_int = TOTAL(core_stripe,2)
	PRINT, "Time-averaged integrated intensity:", MEAN(data_int)

	; Determine the total noise
	gain = 15.3
	data_tot = SQRT(data_int/gain + data_var)
	; print, "Total noise", data_tot

	; Determine the signal to noise ratio
	data_mean = MEAN(core_stripe, DIMENSION=2)
	data_snr = data_mean / data_tot
	;PRINT, "The SNR is", data_snr
	PRINT, "SNR min/mean/max", MIN(data_snr), MEAN(data_snr), MAX(data_snr)


	; Eliminate images with low SNR
	data = data[WHERE(data_snr GT 0.05),*,*]
	old_num_frames = dsz[1]
	dsz = SIZE(data)
	num_frames_kept = dsz[1]
	num_frames_elim = old_num_frames - num_frames_kept
	;HELP, data

	;; Apply the MOSES PSF to the input data
	;;inputd = []
	;;moses_psf_fwhm = 9	; MOSES pixels
	;;moses_psf_sigma = moses_psf_fwhm / 2.355	; convert from FWHM to 1 standard deviation
	;;ksz_spatial = FIX(moses_psf_sigma * moses_spatial_res / iris_y_res)	; convert to iris units
	;;ksz_spectral = FIX(moses_psf_sigma * moses_spectral_res / iris_spectral_res)	; convert to iris units
	;;print, "Spatial kernel size in IRIS pixels", ksz_spatial
	;;print, "Spectral kernel size in IRIS pixels", ksz_spectral
	;;FOR K = 0, dsz[1] - 1 DO BEGIN

		;next_img = GAUSS_SMOOTH(REFORM(data[K,*,*]), 2, /EDGE_MIRROR)
	;;	next_img = GAUSS_SMOOTH(REFORM(data[K,*,*]), [ksz_spectral, ksz_spatial], /EDGE_MIRROR)
	;;	next_img = REFORM(next_img, 1, dsz[2], dsz[3])
	;;	inputd = [inputd, next_img]

	;;ENDFOR 


	; Adjust the image to have the same aspect ratio of MOSES
	;print, "IRIS spatial resolution", iris_y_res
	;print, "IRIS spectral resolution", iris_spectral_res
	;iris_aspect_ratio = iris_y_res / iris_spectral_res
	;print, "IRIS aspect ratio", iris_aspect_ratio
	
	;moses_spatial_res = 0.59 ; arcseconds
	;moses_spectral_res = 29e13 ; angstroms/s
	;moses_aspect_ratio = moses_spatial_res / moses_spectral_res
	;print, "MOSES aspect ratio", moses_aspect_ratio
	
	; Find the ratio of the aspect ratio
	;arr = iris_aspect_ratio / moses_aspect_ratio
	;print, "Relationship ratio", arr
	;pmm, data

	; Adjust the data array to have the same pixel aspect ratio as MOSES by shrinking the spectral dimension
	; Need to use FOR loop here to be able to use the cubic interpolation option
	;inputd = []
	;FOR k = 0, dsz[1]-1 DO BEGIN
		
	;	next_img = POSITIVITY(CONGRID(REFORM(data[k,*,*]), dsz[2],  FIX(dsz[3]/ arr), CUBIC=-0.5))
	;	nisz = SIZE(next_img)
	;	inputd = [inputd, REFORM(next_img, 1, nisz[1], nisz[2])]

	;ENDFOR
	;isz = SIZE(inputd)
	;HELP, inputd


	; Run the MOSES forward model
	;inputd = fomod(inputd, [-1,0,1], core_ind)
	;help, inputd



	; Delete the files from disk
	FILE_DELETE, out_fn

	; Return the hypercube
	return, data

 end
