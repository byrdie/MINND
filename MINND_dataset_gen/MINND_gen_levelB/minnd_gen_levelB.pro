
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

  CLOSE, /ALL
  OPENW, test_fp, test_ind_fn
  OPENW, train_fp, train_ind_fn

  ; Select a random image for tesing purposes
  ;  i = LONG(N_ELEMENTS(levelA_list)*RANDOMU(seed,1))	; random index generation


  FOR i=0,N_ELEMENTS(levelA_list)-1 DO BEGIN
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
    idata /= 2^10
    tdata /= 2^10

    input_test = idata[*,*,0:79,*]
    input_train = idata[*,*,80:159,*]
    truth_test = tdata[*,0:79,*]
    truth_train = tdata[*,80:159,*]

    input_test = [input_test[*,*,0:19,*], input_test[*,*,20:39,*], input_test[*,*,40:59,*]]
    input_train = [input_train[*,*,0:19,*], input_train[*,*,20:39,*], input_train[*,*,40:59,*]]
    truth_test = [truth_test[*,0:19,*], truth_test[*,20:39,*], truth_test[*,40:59,*]]
    truth_train = [truth_train[*,0:19,*], truth_train[*,20:39,*], truth_train[*,40:59,*]]

    test_fn = levelB_dir + "test/" + next_fn_base + ".h5"
    train_fn = levelB_dir + "train/" + next_fn_base + ".h5"

    write_hdf5_dataset, test_fn, train_fn, input_test, input_train, truth_test, truth_train


    ; Write the filename to the index
    PRINTF, test_fp, test_fn
    PRINTF, train_fp, train_fn

  ENDFOR

  CLOSE, /ALL



END
