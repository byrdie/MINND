
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

  ; Define test and train index filenames
  input_test_ind_fn = levelB_dir + 'test/input/index.txt'
  input_train_ind_fn = levelB_dir + 'train/input/index.txt'
  truth_test_ind_fn = levelB_dir + 'test/truth/index.txt'
  truth_train_ind_fn = levelB_dir + 'train/truth/index.txt'

  ; Define test and train index file pointers
  input_test_fp = 1
  input_train_fp = 2
  truth_test_fp = 3
  truth_train_fp = 4

  ; Open up the file to append image filenames
  CLOSE, /ALL
  OPENW, input_test_fp, input_test_ind_fn
  OPENW, input_train_fp, input_train_ind_fn
  OPENW, truth_test_fp, truth_test_ind_fn
  OPENW, truth_train_fp, truth_train_ind_fn
  
  FILE_DELETE, levelB_dir + "test/levelB.h5", /ALLOW_NONEXISTENT
  FILE_DELETE, levelB_dir + "train/levelB.h5", /ALLOW_NONEXISTENT

  ; Open the HDF5 files
  test_fid = H5F_CREATE(levelB_dir + "test/levelB.h5")
  train_fid = H5F_CREATE(levelB_dir + "train/levelB.h5")

  ; Select a random image for tesing purposes
  ;	i = LONG(N_ELEMENTS(levelA_list)*RANDOMU(seed,1))	; random index generation

  ;FOR i=0,N_ELEMENTS(levelA_list)-1 DO BEGIN
      FOR i=0,0 DO BEGIN

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

    input_test = idata[0:isz[1]/2 - 1,*,*]
    input_train = idata[isz[1]/2:-1,*,*]
    truth_test = tdata[0:tsz[1]/2 - 1,*,*]
    truth_train = tdata[tsz[1]/2:-1,*,*]
    

    ; Set up the HDF5 writing
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



;    ; Extract the filename from the .dat files
;    next_fn_split = STRSPLIT(next_fn, '/', /EXTRACT)
;    next_fn_split = STRSPLIT(next_fn_split[-1], '.',/EXTRACT)
;    next_fn_base = next_fn_split[0]

    ; Loop through time and save both input and truth
    ;    range = 1
    range = isz[1] / 2 - 1
    FOR j = 0, range DO BEGIN

      ; Define the filename of the next images
      input_test_fn = levelB_dir + 'test/input/' + next_fn_base + '_' + STRTRIM(STRING(j, FORMAT='(I7.7)'),1) + '.bmp'
      input_train_fn = levelB_dir + 'train/input/' + next_fn_base + '_' + STRTRIM(STRING(j, FORMAT='(I7.7)'),1) + '.bmp'
      truth_test_fn = levelB_dir + 'test/truth/' + next_fn_base + '_' + STRTRIM(STRING(j, FORMAT='(I7.7)'),1) + '.bmp'
      truth_train_fn = levelB_dir + 'train/truth/' + next_fn_base + '_' + STRTRIM(STRING(j, FORMAT='(I7.7)'),1) + '.bmp'


      ; Write the images to the file
      WRITE_BMP, input_test_fn, REFORM(idata[2 * j,*,*])
      WRITE_BMP, input_train_fn, REFORM(idata[2 * j + 1,*,*])
      WRITE_BMP, truth_test_fn, REFORM(tdata[2 * j,*,*])
      WRITE_BMP, truth_train_fn, REFORM(tdata[2 * j + 1,*,*])

      ; Write the filename to the index
      PRINTF, input_test_fp, input_test_fn
      PRINTF, input_train_fp, input_train_fn
      PRINTF, truth_test_fp, truth_test_fn
      PRINTF, truth_train_fp, truth_train_fn


    ENDFOR

  ENDFOR

  H5F_CLOSE, test_fid
  H5F_CLOSE, train_fid

  CLOSE, /ALL

END
