PRO minnd_test_hdf5

  $ ./test_hdf5_minnd.sh


  out_file = "/home/byrdie/School/Research/MINND/MINND/cnn/output.h5"
  in_file = "/home/byrdie/School/Research/MINND/MINND/cnn/input.h5"
  truth_file = "/home/byrdie/School/Research/MINND/MINND/cnn/truth.h5"
  t1_file = "/home/byrdie/School/Research/MINND/MINND/cnn/test1.h5"
  t2_file = "/home/byrdie/School/Research/MINND/MINND/cnn/test2.h5"
  t3_file = "/home/byrdie/School/Research/MINND/MINND/cnn/test3.h5"
  t4_file = "/home/byrdie/School/Research/MINND/MINND/cnn/test4.h5"

  out_file_id = H5F_OPEN(out_file)
  in_file_id = H5F_OPEN(in_file)
  truth_file_id = H5F_OPEN(truth_file)
  t1_file_id = H5F_OPEN(t1_file)
  t2_file_id = H5F_OPEN(t2_file)
  t3_file_id = H5F_OPEN(t3_file)
  t4_file_id = H5F_OPEN(t4_file)

  out_id1 = H5D_OPEN(out_file_id,"data")
  in_id1 = H5D_OPEN(in_file_id,"data")
  truth_id1 = H5D_OPEN(truth_file_id,"data")
  t1_idl = H5D_OPEN(t1_file_id,"data")
  t2_idl = H5D_OPEN(t2_file_id,"data")
  t3_idl = H5D_OPEN(t3_file_id,"data")
  t4_idl = H5D_OPEN(t4_file_id,"data")




  out_image = REFORM(H5D_READ(out_id1))
  in_image = REFORM(H5D_READ(in_id1))
  truth_image = REFORM(H5D_READ(truth_id1))
  t1_image = REFORM(H5D_READ(t1_idl))
  t2_image = REFORM(H5D_READ(t2_idl))
  t3_image = REFORM(H5D_READ(t3_idl))
  t4_image = REFORM(H5D_READ(t4_idl))

  help, in_image, out_image, truth_image, t1_image, t2_image, t3_image, t4_image

  osz = SIZE(out_image)
  isz = SIZE(in_image)
  tsz = SIZE(truth_image)
  t1sz = SIZE(t1_image)
  t2sz = SIZE(t2_image)
  t3sz = SIZE(t3_image)
  t4sz = SIZE(t4_image)

;  out_image = REFORM(out_image, osz[1],osz[2]*osz[3],osz[4])
  in_image = REFORM(in_image, isz[1],isz[2]*isz[3],isz[4])
  ;  truth_image = REFORM(truth_image, tsz[1],tsz[2],tsz[3])
  t1_image = REFORM(t1_image, t1sz[1],t1sz[2]*t1sz[3],t1sz[4])
  t2_image = REFORM(t2_image, t2sz[1],t2sz[2]*t2sz[3],t2sz[4])
  t3_image = REFORM(t3_image, t3sz[1],t3sz[2]*t3sz[3],t3sz[4])
  t4_image = REFORM(t4_image, t4sz[1],t4sz[2]*t4sz[3],t4sz[4])
;t3_image = REFORM(t3_image, 1, t3sz[1],t3sz[2])
;t4_image = REFORM(t4_image, 1, t4sz[1],t4sz[2])

  out_image = TRANSPOSE(out_image, [1,0,2])
  in_image = TRANSPOSE(in_image, [1,0,2])
  truth_image = TRANSPOSE(truth_image, [1,0,2])
  t1_image = TRANSPOSE(t1_image, [1,0,2])
  t2_image = TRANSPOSE(t2_image, [1,0,2])
  t3_image = TRANSPOSE(t3_image, [1,0,2])
  t4_image = TRANSPOSE(t4_image, [1,0,2])

  osz = SIZE(out_image)
  isz = SIZE(in_image)
  tsz = SIZE(truth_image)
  t1sz = SIZE(t1_image)
  t2sz = SIZE(t2_image)
  t3sz = SIZE(t3_image)
  t4sz = SIZE(t4_image)


  max_w = MAX([osz[1], isz[1], tsz[1], t1sz[1], t2sz[1], t3sz[1], t4sz[1]])

  out_row = FLTARR(max_w, osz[2],  osz[3])
  in_row = FLTARR(max_w, isz[2],  isz[3])
  truth_row = FLTARR(max_w, tsz[2],  tsz[3])
  t1_row = FLTARR(max_w, t1sz[2],  t1sz[3])
  t2_row = FLTARR(max_w, t2sz[2],  t2sz[3])
  t3_row = FLTARR(max_w, t3sz[2],  t3sz[3])
  t4_row = FLTARR(max_w, t4sz[2],  t4sz[3])

  out_row[0:osz[1]-1,*,*] = out_image
  in_row[0:isz[1]-1,*,*] = in_image
  truth_row[0:tsz[1]-1,*,*] = truth_image
  t1_row[0:t1sz[1]-1,*,*] = t1_image
  t2_row[0:t2sz[1]-1,*,*] = t2_image
  t3_row[0:t3sz[1]-1,*,*] = t3_image
  t4_row[0:t4sz[1]-1,*,*] = t4_image

;  tot_image = [[in_row],[t1_row],[t3_row],[t4_row],[out_row],[truth_row]]

  
  tot_image = [[out_image],[truth_image]]

  help, tot_image

  pmm, tot_image

  ;  out_image = ROTATE([ROTATE(BYTSCL(out_image),1), ROTATE(BYTSCL(truth_image),1)],1)

  ;  out_image = REFORM(out_image, osz[1],osz[2]*osz[3],osz[4])
  ;  out_image = TRANSPOSE(out_image, [1,0,2])

;  tot_image = [out_image, truth_image]

  SAVE, tot_image, FILENAME='roysmart_MINN.sav'

  totsz = SIZE(tot_image)
  fact = 17
  tot_image = REBIN(tot_image, fact*totsz[1], fact*totsz[2], totsz[3])




  ;xstepper, REFORM(in_image[*,*,0,*])

  ;atv, image[*,*,0]/


  atv, tot_image[*,*,27]
;  print, TOTAL(truth_image[*,10])

  xstepper, REFORM(tot_image)
  
 

  ;xstepper, BYTSCL(REFORM(image[*,*,0,*]))

END