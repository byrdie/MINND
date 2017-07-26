;+
; :Description:
;    Describe the procedure.
;
; :Params:
;    fn
;    input_test
;    input_train
;    truth_test
;    truth_train
;
;    Writes the test and training datasets to their respective filenames
;
; :Author: Roy Smart
;-
PRO write_hdf5_dataset, test_fn, train_fn, input_test, input_train, truth_test, truth_train

  ite_sz = SIZE(input_test)
  itr_sz = SIZE(input_train)
  tte_sz = SIZE(truth_test)
  ttr_sz = SIZE(truth_train)
  
  help, tte_sz, ttr_sz

  ; Reform to include channel dimension
  input_test = TRANSPOSE(input_test)
  input_train = TRANSPOSE(input_train)
  truth_test = TRANSPOSE(REFORM(truth_test, tte_sz[1], 1, 1, 1))
  truth_train = TRANSPOSE(REFORM(truth_train, ttr_sz[1], 1, 1, 1))
  
  atv, REBIN(REFORM(input_train[*,*,1,0]),21*10,21*10, /SAMPLE)

  help, input_test, input_train, truth_test, truth_train

  ; Open the HDF5 files
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

END