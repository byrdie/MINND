from aia_get import *

# AIA data parameters
t_start = '2015/08/27 17:45:00';
t_end = '2015/08/27 17:45:30';
wavl = '131 Angstrom';
data_dir = '../../'

aia_get(t_start, t_end, wavl, data_dir)