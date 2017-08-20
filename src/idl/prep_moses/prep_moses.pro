pro prep_moses

  restore, '../../../data/KSO/MOSES/MOSES_I/mosesAlignFinal.sav'
  
  zero = TRANSPOSE(cube_zero, [1, 0, 2])
  plus = TRANSPOSE(cube_plus, [1, 0, 2])
  minus = TRANSPOSE(cube_minus, [1, 0, 2])
  
  zs = SIZE(zero)
  ps = SIZE(plus)
  ms = SIZE(minus)
  
  ; Apply Atwood PSF equalization technique
;  inf_ord = fltarr(21)
;  inf_ord[10] = 1
;  inf_ord=[1,0,0,0]
;  FOR i = 0, zs[3]-1 DO BEGIN
;
;    n_z = zero[*,*,i]
;    n_p = plus[*,*,i]
;    n_m = minus[*,*,i]
;
;    
;    psffixer, n_m, n_z, n_p, [1], 10
;
;  
;    zero[*,*,i] = n_z
;    plus[*,*,i] = n_p
;    minus[*,*,i] = n_m
;    
;    atv, n_p
;    
;    print, 'corrected psf for image ', i
;
;  ENDFOR
;  

  
  zero = simple_inv(zero, [0], 10, 21)
  plus = simple_inv(plus, [1], 10, 21)
  minus = simple_inv(minus, [-1], 10, 21)
  
  
  zs = SIZE(zero)
  ps = SIZE(plus)
  ms = SIZE(minus)
  
  help, zero, plus, minus
  

  
;  plus = SHIFT(plus, [0,-4,0,0])
  
  zero = REFORM(zero, [1, zs[1:4]])
  plus = REFORM(plus, [1, ps[1:4]])
  minus = REFORM(minus, [1, ms[1:4]])
  
  
  
  
  inp = [zero, plus, minus]
  
  zero = []
  plus = []
  minus = []
  
  
  inp = TRANSPOSE(inp, [3, 0, 1, 2, 4])
  
  is = SIZE(inp)

  ; Reform to include channel dimension
  inp = TRANSPOSE(inp)

  ; Open the HDF5 files
  fid = H5F_CREATE('moses_level_1.h5')

  type_id = H5T_IDL_CREATE(inp)

  space_id = H5S_CREATE_SIMPLE(SIZE(inp, /DIMENSIONS))

  set_id = H5D_CREATE(fid, 'data', type_id, space_id)

  H5D_WRITE, set_id, inp

  H5D_CLOSE, set_id

  H5S_CLOSE, space_id

  H5T_CLOSE, type_id

  H5F_CLOSE, fid

end