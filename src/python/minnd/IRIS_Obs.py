
import sunpy.map
import sunpy.map.mapcube

import h5py

from Obs import Obs

class IRIS_Obs(Obs):

    def __init__(self, index_file = None, t_start = None, t_end = None, wavl_min = None, wavl_max = None, data_dir =''):

        # Pass parameters to superclass constructor
        Obs.__init__(self, 'IRIS', 'FUV', index_file=index_file, t_start=t_start, t_end=t_end, wavl_min=wavl_min,
                     wavl_max=wavl_max, data_dir=data_dir)


    def import_data(self, file_list):

        with h5py.File
