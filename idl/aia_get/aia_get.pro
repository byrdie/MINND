PRO aia_get, t_start, t_end, wavl, data_dir

  print, wavl

  md = vso_search(t_start, t_end, wav=wavl, inst='aia')
  status = vso_get(md, out_dir=data_dir)

;  md=vso_search('2015/08/27 17:30:00', '2015/08/27 18:00:00', instr='aia', wav='131 Angstrom')
  
;  status = vso_get(md, out_dir='/home/byrdie/School/Research/MOSES/SPD_Meeting_2017/datasets/aia')
  

END