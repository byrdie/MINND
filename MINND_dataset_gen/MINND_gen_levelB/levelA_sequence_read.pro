;+
; :Author: byrdie
;
; Reads in a singular IRIS sequence file prepares from minnd_gen_levelA,
; runs the MOSES forward model and saves the input and truth images to
; disk
;-

FUNCTION levelA_sequence_read, fn, inputd, truthd

  PRINT, fn

  ; Define variables to store the number of frames in the dataset
  num_frames_kept = 0
  num_frames_elim = 0

  ; Define variables to store the resolution of each instrument
  iris_spatial_res = 0.3327;
  iris_spectral_res = 5.4367265e13
  moses_spatial_res = 0.59 ; arcseconds
  moses_spectral_res = 29e13 ; angstroms/s

  ; Read data into memory
  RESTORE, fn
  HELP, data
  dsz = SIZE(data)

  core_ind = FLOOR(dsz[3]/2)
  PRINT, "Core Index:", core_ind

  ;XSTEPPER, REBIN(TRANSPOSE(data),3*dsz[3], 2*dsz[2], dsz[1])



  ; Determine the ratios between IRIS and MOSES pixels
  PRINT, "IRIS spatial resolution", iris_spatial_res
  PRINT, "IRIS spectral resolution", iris_spectral_res
  iris_aspect_ratio = iris_spatial_res / iris_spectral_res
  PRINT, "IRIS aspect ratio", iris_aspect_ratio
  moses_aspect_ratio = moses_spatial_res / moses_spectral_res
  PRINT, "MOSES aspect ratio", moses_aspect_ratio

  ; Find the ratio of the aspect ratio
  arr = iris_aspect_ratio / moses_aspect_ratio
  PRINT, "Relationship ratio", arr

  ; Determine the MOSES PSF
  moses_psf_fwhm = 9.0  ; MOSES pixels
  moses_psf_sigma = moses_psf_fwhm / 2.355  ; convert from FWHM to 1 standard deviation
  ksz = moses_psf_sigma * moses_spatial_res / iris_spatial_res ; convert to iris units
  print, "Spatial kernel size in IRIS pixels", ksz
  moses_psf = GAUSSIAN_FUNCTION(ksz)

  inputd = []
  truthd = []
  combod = []
  FOR k = 0, dsz[1]-1 DO BEGIN

    ; Adjust the data to have the same aspect ratio of MOSES
    next_tru = CONGRID(REFORM(data[k,*,*]), dsz[2],  FIX(dsz[3] / arr), CUBIC=-0.5)
    trsz = SIZE(next_tru)

    ;Run the MOSES forward model
    next_inp = fomod(REFORM(next_tru, 1, trsz[1], trsz[2]), [-1,0,1], core_ind)
    insz = SIZE(next_inp)

    ; Insert the MOSES PSF here

    ; Downsample the truth image into MOSES pixels
    next_tru = DOWNSAMPLE(next_tru, FIX(trsz[1] * iris_spatial_res / moses_spatial_res), FIX(trsz[2] * arr * iris_spectral_res / moses_spectral_res))
    trsz = SIZE(next_tru)

    ; Downsample the input image into MOSES pixels
    next_inp = DOWNSAMPLE(REFORM(next_inp), FIX(insz[2] * iris_spatial_res/moses_spatial_res), insz[3])
    insz = SIZE(next_inp)

    ; Combine into one image for viewing
    next_cmb = [BYTSCL(ROTATE(next_tru,1)), BYTSCL(ROTATE(next_inp,1))]
    cbsz = SIZE(next_cmb)



    inputd = [inputd, REFORM(next_inp, 1, insz[1], insz[2])]
    truthd = [truthd, REFORM(next_tru, 1, trsz[1], trsz[2])]
    combod = [combod, REFORM(next_cmb, 1, cbsz[1], cbsz[2])]

  ENDFOR

  help, inputd
  help, truthd

  cbsz = SIZE(combod)

  ;XSTEPPER, REBIN(TRANSPOSE(combod),10*cbsz[3], 10*cbsz[2], cbsz[1])

  ; Return the hypercube
  RETURN, combod

END
