PRO aia_get

  md=vso_search('2015/08/01 10:00:00', '2015/08/01 10:05:30', instr='aia')
  
  status = vso_get(md, out_dir='../../datasets/aia')
  

END