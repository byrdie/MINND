
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
  levelA_dir = '/media/byrdie/RoyHDD/iris_siIV/'

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
  
  itrain = []
  itest = []
  ttrain = []
  ttest = []
  otrain = []
  otest = []

  ; Select a random image for tesing purposes
  ;    i = LONG(N_ELEMENTS(levelA_list)*RANDOMU(seed,1))	; random index generation
  ;  i = 346
  FOR i =0,500 DO BEGIN
;  FOR i=0,N_ELEMENTS(levelA_list)-2 DO BEGIN
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

    isz = SIZE(idata)
    tsz = SIZE(tdata)

    it = idata
    tt = tdata

    idata = []
    tdata = []

    FOR j=0,FIX(isz[3] / 21) - 1 DO BEGIN

      idata = [idata, it[*,*,21*j:21*(j + 1) - 1,*]]
      tdata = [tdata, tt[*,21*j:21*(j + 1) - 1,*]]

    ENDFOR



    help, idata, tdata


    nz = WHERE(MAX(MAX(tdata, DIMENSION = 3), DIMENSION = 2) > 0, /NULL)
    IF nz EQ !NULL THEN CONTINUE

    idata = idata[nz,*,*,*]
    tdata = tdata[nz,*,*]

    help, idata, tdata



    

    snr = WHERE((TOTAL(TOTAL(tdata[*,*,9:11],2),2) GT 20 * (TOTAL(TOTAL(tdata[*,*,0:5],2),2) + TOTAL(TOTAL(tdata[*,*,15:-1],2),2))) AND (TOTAL(REFORM(tdata[*,*,10]),2) GT 500), /NULL)
    IF snr EQ !NULL THEN CONTINUE
    
    idata = idata[snr,*,*,*]
    tdata = tdata[snr,*,*]

    help, idata, tdata

    isz = SIZE(idata)
    tsz = SIZE(tdata)


    IF isz[1] LT 4 THEN CONTINUE

    

    input_test = idata[0:FIX(isz[1] / 2) - 1,*,*,*]
    input_train = idata[FIX(isz[1] / 2):-1,*,*,*]
    truth_test = tdata[0:FIX(tsz[1] / 2) - 1,*,*]
    truth_train = tdata[FIX(tsz[1] / 2):-1,*,*]

    help, input_test, input_train, truth_test, truth_train


;    input_test /= MAX(input_test)
;    input_train /= MAX(input_train)
;    truth_test /= MAX(truth_test)
;    truth_train /= MAX(truth_train)

    

    atv, REBIN(REFORM(truth_test[0,*,*]),21*10,21*10, /SAMPLE)


    tot_test_img += N_ELEMENTS(truth_test) / (21 * 21)
    tot_train_img += N_ELEMENTS(truth_train) / (21 * 21)
    print, tot_test_img, tot_train_img
    
    ; Save the actual images
    orig_test = truth_test
    orig_train = truth_train
    
    ; Find the first moment of the truth dataset
    truth_test = doppler(truth_test)
    truth_train = doppler(truth_train)
    
    plot, truth_train[0,*,*]
    
    t_sz = SIZE(truth_test)
    n_sz = SIZE(truth_train)
    
    truth_test = REFORM(truth_test[*,10,*], t_sz[1], 1, t_sz[3])
    truth_train = REFORM(truth_train[*,10,*], n_sz[1], 1, n_sz[3])
    



;    write_hdf5_dataset, test_fn, train_fn, input_test, input_train, truth_test, truth_train
    itest = [itest, input_test]
    itrain = [itrain, input_train]
    ttest = [ttest, truth_test]
    ttrain = [ttrain, truth_train]
    otest = [otest, orig_test]
    otrain = [otrain, orig_train]
    
    

    help, itest, itrain, ttest, ttrain, otest, otrain







  ENDFOR
  
  print, mean(ttest)
  print, mean(ttrain)
  
;  atv, REBIN(REFORM(itest[9600,1,*,*]),21*10,21*10, /SAMPLE)
  
  test_fn = levelB_dir + "test/" + "database" + ".h5"
  train_fn = levelB_dir + "train/" + "database" + ".h5"

  write_hdf5_dataset, test_fn, train_fn, itest, itrain, ttest, ttrain, otest, otrain
  
  ; Write the filename to the index
  PRINTF, test_fp, test_fn
  PRINTF, train_fp, train_fn

  CLOSE, /ALL



END
