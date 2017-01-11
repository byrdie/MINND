
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

  FILE_DELETE, levelB_list

  ; Define test and train index filenames
  test_ind_fn = levelB_dir + 'test_index.txt'
  train_ind_fn = levelB_dir + 'train_index.txt'
  
  ; Define test and train index file pointers
  test_fp = 1
  train_fp = 2

  OPENW, test_fp, test_ind_fn
  OPENW, train_fp, train_ind_fn

  ; Select a random image for tesing purposes
  ;	i = LONG(N_ELEMENTS(levelA_list)*RANDOMU(seed,1))	; random index generation


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
    isz = SIZE(idata)
    tsz = SIZE(tdata)

    idata /= 2^14
    tdata /= 2^14

    input_test = idata[0:isz[1]/2 - 1,*,*]
    input_train = idata[isz[1]/2:-1,*,*]
    truth_test = tdata[0:tsz[1]/2 - 1,*,*]
    truth_train = tdata[tsz[1]/2:-1,*,*]

    ite_sz = SIZE(input_test)
    itr_sz = SIZE(input_train)
    tte_sz = SIZE(truth_test)
    ttr_sz = SIZE(truth_train)

    ; Reform to include channel dimension
    input_test = TRANSPOSE(REFORM(input_test, ite_sz[1], 1, ite_sz[2], ite_sz[3]))
    input_train = TRANSPOSE(REFORM(input_train, itr_sz[1], 1, itr_sz[2], itr_sz[3]))
    truth_test = TRANSPOSE(REFORM(truth_test, tte_sz[1], 1, tte_sz[2], tte_sz[3]))
    truth_train = TRANSPOSE(REFORM(truth_train, ttr_sz[1], 1, ttr_sz[2], ttr_sz[3]))


    ; Open the HDF5 files
    test_fn = levelB_dir + "test/" + next_fn_base + ".h5"
    train_fn = levelB_dir + "train/" + next_fn_base + ".h5"
    test_fid = H5F_CREATE(test_fn)
    train_fid = H5F_CREATE(train_fn)

    input_test_type_id = H5T_IDL_CREATE(input_test)
    input_train_type_id = H5T_IDL_CREATE(input_train)
    truth_test_type_id = H5T_IDL_CREATE(truth_test)
    truth_train_type_id = H5T_IDL_CREATE(truth_train)

    input_test_space_id = H5S_CREATE_SIMPLE(SIZE(input_test, /DIMENSIONS))
    input_train_space_id = H5S_CREATE_SIMPLE(SIZE(input_train, /DIMENSIONS))
    truth_test_space_id = H5S_CREATE_SIMPLE(SIZE(truth_test, /DIMENSIONS))
    truth_train_space_id = H5S_CREATE_SIMPLE(SIZE(truth_train, /DIMENSIONS))

    input_test_set_id = H5D_CREATE(test_fid, 'data', input_test_type_id, input_test_space_id)
    input_train_set_id = H5D_CREATE(train_fid, 'data', input_train_type_id, input_train_space_id)
    truth_test_set_id = H5D_CREATE(test_fid, 'label', truth_test_type_id, truth_test_space_id)
    truth_train_set_id = H5D_CREATE(train_fid, 'label', truth_train_type_id, truth_train_space_id)

    H5D_WRITE, input_test_set_id, input_test
    H5D_WRITE, input_train_set_id, input_train
    H5D_WRITE, truth_test_set_id, truth_test
    H5D_WRITE, truth_train_set_id, truth_train

    H5D_CLOSE, input_test_set_id
    H5D_CLOSE, input_train_set_id
    H5D_CLOSE, truth_test_set_id
    H5D_CLOSE, truth_train_set_id

    H5S_CLOSE, input_test_space_id
    H5S_CLOSE, input_train_space_id
    H5S_CLOSE, truth_test_space_id
    H5S_CLOSE, truth_train_space_id

    H5T_CLOSE, input_test_type_id
    H5T_CLOSE, input_train_type_id
    H5T_CLOSE, truth_test_type_id
    H5T_CLOSE, truth_train_type_id

    H5F_CLOSE, test_fid
    H5F_CLOSE, train_fid

    ; Write the filename to the index
    PRINTF, test_fp, test_fn
    PRINTF, train_fp, train_fn

  ENDFOR

  CLOSE, /ALL



END
