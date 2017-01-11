
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


  FILE_DELETE, levelB_dir + "test/levelB.h5", /ALLOW_NONEXISTENT
  FILE_DELETE, levelB_dir + "train/levelB.h5", /ALLOW_NONEXISTENT

  ; Open the HDF5 files
  test_fid = H5F_CREATE(levelB_dir + "test/levelB.h5")
  train_fid = H5F_CREATE(levelB_dir + "train/levelB.h5")

  ; Select a random image for tesing purposes
  ;	i = LONG(N_ELEMENTS(levelA_list)*RANDOMU(seed,1))	; random index generation

  old_ite = 0
  old_itr = 0
  old_tte = 0
  old_ttr = 0

  FOR i=0,N_ELEMENTS(levelA_list)-1 DO BEGIN
          ;FOR i=0,2 DO BEGIN

    ;		; Back up program state for restarting computation
    ;		start_ind = i
    ;		SAVE, start_ind, tnfk, tnfe, FILENAMe=vars_dir

    next_fn=levelA_list[i]
    PRINT, "_______________________________________________________"
    PRINT,"IRIS image index", i

    ; Call procedure to read selected iris data into program memory
    cdata = levelA_sequence_read(next_fn, idata, tdata)
    isz = SIZE(idata)
    tsz = SIZE(tdata)
    
    idata /= 2e14
    tdata /= 2e14



    ; Loop through time and save both input and truth
;        range = 1
;    range = isz[1] / 2 - 1
;    FOR j = 0, range DO BEGIN

      ; Select next time-slice of data
      input_test = idata[0:isz[1]/2 - 1,*,*]
      input_train = idata[isz[1]/2:-1,*,*]
      truth_test = tdata[0:tsz[1]/2 - 1,*,*]
      truth_train = tdata[tsz[1]/2:-1,*,*]

      ite_sz = SIZE(input_test)
      itr_sz = SIZE(input_train)
      tte_sz = SIZE(truth_test)
      ttr_sz = SIZE(truth_train)

      ; Reform to include channel dimension
      input_test = REFORM(input_test, ite_sz[1], 1, ite_sz[2], ite_sz[3])
      input_train = REFORM(input_train, itr_sz[1], 1, itr_sz[2], itr_sz[3])
      truth_test = REFORM(truth_test, tte_sz[1], 1, tte_sz[2], tte_sz[3])
      truth_train = REFORM(truth_train, ttr_sz[1], 1, ttr_sz[2], ttr_sz[3])
      
      help, input_test

      ite_sz = SIZE(input_test)
      itr_sz = SIZE(input_train)
      tte_sz = SIZE(truth_test)
      ttr_sz = SIZE(truth_train)

      ; If this is the first iteration, then set up the HDF5 database
      IF i EQ 0 THEN BEGIN

        input_test_type_id = H5T_IDL_CREATE(input_test)
        input_train_type_id = H5T_IDL_CREATE(input_train)
        truth_test_type_id = H5T_IDL_CREATE(truth_test)
        truth_train_type_id = H5T_IDL_CREATE(truth_train)

        input_test_space_id = H5S_CREATE_SIMPLE([ite_sz[1],ite_sz[2],ite_sz[3],ite_sz[4]], MAX_DIMENSIONS = [-1,ite_sz[2],ite_sz[3],ite_sz[4]])
        input_train_space_id = H5S_CREATE_SIMPLE([itr_sz[1],itr_sz[2],itr_sz[3],itr_sz[4]], MAX_DIMENSIONS = [-1,itr_sz[2],itr_sz[3],itr_sz[4]])
        truth_test_space_id = H5S_CREATE_SIMPLE([tte_sz[1],tte_sz[2],tte_sz[3],tte_sz[4]], MAX_DIMENSIONS = [-1,tte_sz[2],tte_sz[3],tte_sz[4]])
        truth_train_space_id = H5S_CREATE_SIMPLE([ttr_sz[1],ttr_sz[2],ttr_sz[3],ttr_sz[4]], MAX_DIMENSIONS = [-1,ttr_sz[2],ttr_sz[3],ttr_sz[4]])

        input_test_set_id = H5D_CREATE(test_fid, 'data', input_test_type_id, input_test_space_id, CHUNK_DIMENSIONS=[ite_sz[1],ite_sz[2],ite_sz[3],ite_sz[4]])
        input_train_set_id = H5D_CREATE(train_fid, 'data', input_train_type_id, input_train_space_id, CHUNK_DIMENSIONS=[itr_sz[1],itr_sz[2],itr_sz[3],itr_sz[4]])
        truth_test_set_id = H5D_CREATE(test_fid, 'label', truth_test_type_id, truth_test_space_id, CHUNK_DIMENSIONS=[tte_sz[1],tte_sz[2],tte_sz[3],tte_sz[4]])
        truth_train_set_id = H5D_CREATE(train_fid, 'label', truth_train_type_id, truth_train_space_id, CHUNK_DIMENSIONS=[ttr_sz[1],ttr_sz[2],ttr_sz[3],ttr_sz[4]])

        H5D_EXTEND, input_test_set_id, SIZE(input_test, /DIMENSIONS)
        H5D_EXTEND, input_train_set_id, SIZE(input_train, /DIMENSIONS)
        H5D_EXTEND, truth_test_set_id, SIZE(truth_test, /DIMENSIONS)
        H5D_EXTEND, truth_train_set_id, SIZE(truth_train, /DIMENSIONS)

        H5D_WRITE, input_test_set_id, input_test
        H5D_WRITE, input_train_set_id, input_train
        H5D_WRITE, truth_test_set_id, truth_test
        H5D_WRITE, truth_train_set_id, truth_train

      ENDIF ELSE BEGIN  ; Otherwise just append to the HDF5 database

        H5D_EXTEND, input_test_set_id, [ite, ite_sz[2],ite_sz[3],ite_sz[4]]
        H5D_EXTEND, input_train_set_id, [itr, itr_sz[2],itr_sz[3],itr_sz[4]]
        H5D_EXTEND, truth_test_set_id, [tte, tte_sz[2],tte_sz[3],tte_sz[4]]
        H5D_EXTEND, truth_train_set_id, [ttr ,ttr_sz[2],ttr_sz[3],ttr_sz[4]]

        iter_input_test_space_id = H5D_GET_SPACE(input_test_set_id)
        iter_input_train_space_id = H5D_GET_SPACE(input_train_set_id)
        iter_truth_test_space_id = H5D_GET_SPACE(truth_test_set_id)
        iter_truth_train_space_id = H5D_GET_SPACE(truth_train_set_id)

        H5S_SELECT_HYPERSLAB, iter_input_test_space_id, [old_ite,0,0,0], [ite_sz[1],ite_sz[2],ite_sz[3],ite_sz[4]], /RESET
        H5S_SELECT_HYPERSLAB, iter_input_train_space_id, [old_itr,0,0,0], [itr_sz[1],itr_sz[2],itr_sz[3],itr_sz[4]], /RESET
        H5S_SELECT_HYPERSLAB, iter_truth_test_space_id, [old_tte,0,0,0], [tte_sz[1],tte_sz[2],tte_sz[3],tte_sz[4]], /RESET
        H5S_SELECT_HYPERSLAB, iter_truth_train_space_id, [old_ttr,0,0,0], [ttr_sz[1],ttr_sz[2],ttr_sz[3],ttr_sz[4]], /RESET
        
        iter_input_test_space_id2 = H5S_CREATE_SIMPLE([ite_sz[1],ite_sz[2],ite_sz[3],ite_sz[4]])
        iter_input_train_space_id2 = H5S_CREATE_SIMPLE([itr_sz[1],itr_sz[2],itr_sz[3],itr_sz[4]])
        iter_truth_test_space_id2 = H5S_CREATE_SIMPLE([tte_sz[1],tte_sz[2],tte_sz[3],tte_sz[4]])
        iter_truth_train_space_id2 = H5S_CREATE_SIMPLE([ttr_sz[1],ttr_sz[2],ttr_sz[3],ttr_sz[4]])
        
        H5D_WRITE, input_test_set_id, input_test, FILE_SPACE_ID=iter_input_test_space_id, MEMORY_SPACE_ID=iter_input_test_space_id2
        H5D_WRITE, input_train_set_id, input_train, FILE_SPACE_ID=iter_input_train_space_id, MEMORY_SPACE_ID=iter_input_train_space_id2
        H5D_WRITE, truth_test_set_id, truth_test, FILE_SPACE_ID=iter_truth_test_space_id, MEMORY_SPACE_ID=iter_truth_test_space_id2
        H5D_WRITE, truth_train_set_id, truth_train, FILE_SPACE_ID=iter_truth_train_space_id, MEMORY_SPACE_ID=iter_truth_train_space_id2
        
        H5S_CLOSE, iter_input_test_space_id
        H5S_CLOSE, iter_input_train_space_id
        H5S_CLOSE, iter_truth_test_space_id
        H5S_CLOSE, iter_truth_train_space_id
        
        H5S_CLOSE, iter_input_test_space_id2
        H5S_CLOSE, iter_input_train_space_id2
        H5S_CLOSE, iter_truth_test_space_id2
        H5S_CLOSE, iter_truth_train_space_id2

      ENDELSE
      

  ENDFOR

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



END
