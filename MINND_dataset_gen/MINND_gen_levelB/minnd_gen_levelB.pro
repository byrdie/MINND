
;+
; :Description:
;    This procedure takes the files generated from the level A generation
;    and performs further manipulations on the dataset into HDF5 files
;
;    We expect later these hdf5 files may be converted to lmdb or similar
;    databases for more speed, but this should be sufficient for now
;
;
; :Author: Roy Smart
;-
PRO minnd_gen_levelB

  ; Location to save variables to restart computation
  vars_fn = 'minnd_levelB_vars.sav'

  ; Logic to determine state variables for restart computation
  ;	IF FILE_TEST(vars_fn) EQ 0 THEN BEGIN	; If the file does not exist, initialize to zero
  ;		start_ind = 0
  ;	ENDIF ELSE BEGIN	; Otherwise restore the state of the variables from the .sav file
  ;		RESTORE, vars_fn
  ;	ENDELSE

  ; Specify location to load the Level A data
  levelA_dir = '/home/byrdie/School/Research/MINND/datasets/levelA/'

  ; Specifiy location to save the files to
  levelB_dir = '/minnd/datasets/levelB/'


  ; Find rasters based on correct criteia
  levelA_list = FILE_SEARCH(levelA_dir, '*')
  PRINT, 'Number of matches ', N_ELEMENTS(levelA_list)

  levelB_list = FILE_SEARCH(levelB_dir, '*.h5')


  IF STRCMP("", levelB_list[0]) EQ 0  THEN BEGIN

    FILE_DELETE, levelB_list

  ENDIF


  ; Define test and train index filenames
  test_ind_fn = levelB_dir + 'test_index.txt'
  train_ind_fn = levelB_dir + 'train_index.txt'

  ; Define test and train index file pointers
  test_fp = 1
  train_fp = 2
  
  tot_test_img = 0
  tot_train_img = 0

  CLOSE, /ALL
  OPENW, test_fp, test_ind_fn
  OPENW, train_fp, train_ind_fn

  ; Select a random image for tesing purposes
;    i = LONG(N_ELEMENTS(levelA_list)*RANDOMU(seed,1))	; random index generation
;  i = 346

  FOR i=0,N_ELEMENTS(levelA_list)-2 DO BEGIN
    ;    FOR i=0,20 DO BEGIN

    ;		; Back up program state for restarting computation
    ;		start_ind = i
    ;		SAVE, start_ind, tnfk, tnfe, FILENAMe=vars_dir

    next_fn=levelA_list[i]
    PRINT, "_______________________________________________________"
    PRINT,"IRIS image index", i

    ; Extract the filename from the .dat files
    next_fn_split = STRSPLIT(next_fn, '/', /EXTRACT)
    next_fn_split = STRSPLIT(next_fn_split[-1], '.',/EXTRACT)
    next_fn_base = next_fn_split[0]

    ; Call procedure to read selected iris data into program memory
    cdata = levelA_sequence_read(next_fn, idata, tdata)

    help, idata, tdata

    input_test = idata[*,*,0:83,*]
    input_train = idata[*,*,84:167,*]
    truth_test = tdata[*,0:83,*]
    truth_train = tdata[*,84:167,*]
    
    help, input_test, input_train, truth_test, truth_train

    input_test = [input_test[*,*,0:20,*], input_test[*,*,21:41,*], input_test[*,*,42:62,*], input_test[*,*,63:83,*]]
    input_train = [input_train[*,*,0:20,*], input_train[*,*,21:41,*], input_train[*,*,42:62,*], input_train[*,*,63:83,*]]
    truth_test = [truth_test[*,0:20,*], truth_test[*,21:41,*], truth_test[*,42:62,*], truth_test[*,63:83,*]]
    truth_train = [truth_train[*,0:20,*], truth_train[*,21:41,*], truth_train[*,42:62,*], truth_train[*,63:83,*]]
    
    
    test_nz = WHERE(MAX(MAX(truth_test, DIMENSION = 3), DIMENSION = 2) > 0)
    train_nz = WHERE(MAX(MAX(truth_train, DIMENSION = 3), DIMENSION = 2) > 0)

    input_test = input_test[test_nz,*,*,*]
    input_train = input_train[train_nz,*,*,*]
    truth_test = truth_test[test_nz,*,*]
    truth_train = truth_train[train_nz,*,*]
    
    help, input_test, input_train, truth_test, truth_train
    
    test_snr = WHERE(TOTAL(REFORM(truth_test[*,*,10]), 2) GT 100)
    train_snr = WHERE(TOTAL(REFORM(truth_train[*,*,10]), 2) GT 100)
    
    input_test = input_test[test_snr,*,*,*]
    input_train = input_train[train_snr,*,*,*]
    truth_test = truth_test[test_snr,*,*]
    truth_train = truth_train[train_snr,*,*]
    
    help, input_test, input_train, truth_test, truth_train
    
   


    input_test /= MAX(input_test)
    input_train /= MAX(input_train)
    truth_test /= MAX(truth_test)
    truth_train /= MAX(truth_train)
    
    IF ((N_ELEMENTS(input_test) GT 1) AND (N_ELEMENTS(input_train) GT 1)) THEN BEGIN
      
       atv, REBIN(REFORM(truth_train[0,*,*]),21*10,21*10)
      
      tot_test_img += N_ELEMENTS(truth_test) / (21 * 21)
      tot_train_img += N_ELEMENTS(truth_train) / (21 * 21)
      print, tot_test_img, tot_train_img
      
      test_fn = levelB_dir + "test/" + next_fn_base + ".h5"
      train_fn = levelB_dir + "train/" + next_fn_base + ".h5"

      write_hdf5_dataset, test_fn, train_fn, input_test, input_train, truth_test, truth_train


      ; Write the filename to the index
      PRINTF, test_fp, test_fn
      PRINTF, train_fp, train_fn
      
      FLUSH, test_fp, train_fp
      
    ENDIF



  ENDFOR

  CLOSE, /ALL



END
