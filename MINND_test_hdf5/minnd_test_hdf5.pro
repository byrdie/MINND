PRO minnd_test_hdf5

  out_file = "/home/byrdie/School/Research/MINND/MINND/cnn/output.h5"
  in_file = "/home/byrdie/School/Research/MINND/MINND/cnn/input.h5"
  truth_file = "/home/byrdie/School/Research/MINND/MINND/cnn/truth.h5"
  
  out_file_id = H5F_OPEN(out_file)
  in_file_id = H5F_OPEN(in_file)
  truth_file_id = H5F_OPEN(truth_file)
  
  out_id1 = H5D_OPEN(out_file_id,"data")
  in_id1 = H5D_OPEN(in_file_id,"data")
  truth_id1 = H5D_OPEN(truth_file_id,"data")
  
  out_image = H5D_READ(out_id1)
  in_image = H5D_READ(in_id1)
  truth_image = H5D_READ(truth_id1)
  
  image = ROTATE([ROTATE(out_image[*,*,0],1), ROTATE(truth_image[*,*,0],1), ROTATE(in_image[*,*,0],1)],1)
  
  help, image
  
  ;xstepper, REFORM(in_image[*,*,0,*])
  
  ;atv, image[*,*,0]
  
  atv, REBIN(truth_image[*,*,0], 188*5, 20*5)
  
  ;xstepper, BYTSCL(REFORM(image[*,*,0,*]))
  
END