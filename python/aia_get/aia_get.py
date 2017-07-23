from sunpy.net import vso

def aia_range(t_start, t_end, wavl, data_dir):


    c = vso.VSOClient()
    qr = c.query_legacy(tstart=t_start, tend=t_end, instrument='AIA', min_wave=wavl, max_wave=wavl,  unit_wave='Angstrom')
    print qr
    r = c.get(qr, path=data_dir + '/{file}').wait()


    return r