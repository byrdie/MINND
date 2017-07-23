from astropy import units as u

from sunpy.net import vso       # Import Virtual Solar Observatory class
from download import Downloader     # Import custom downloader class that won't overwrite previously downloaded files
from sunpy.io import read_file

import sunpy.map
import sunpy.map.mapcube
import matplotlib.pyplot as plt
import matplotlib.animation as animation

from Obs import Obs     # Import superclass




# Provides a class structure stroring properties and methods for manipulating AIA observations
class AIA_Obs(Obs):

    # Constructor for AIA_Obs class
    def __init__(self, index_file = None, t_start = None, t_end = None, wavl_min = None, wavl_max = None, data_dir =''):

        # Pass parameters to superclass constructor
        Obs.__init__(self, 'SDO', 'AIA', index_file=index_file, t_start=t_start, t_end=t_end, wavl_min=wavl_min, wavl_max=wavl_max, data_dir=data_dir)

    # Import data into TSST
    def import_data(self, file_list):

        # map_list = []   # Store list of maps to pass into MapCube constructor
        #
        # # Loop through each file in the argument list
        # for file in file_list:
        #
        #     map_list.append(sunpy.map.Map(file))    # Construct new map and append it to the list


        # Create MapCube object for storing a time series of images
        cube = sunpy.map.Map(file_list, cube=True)

        # Resample the map
        res = 256
        for i in range(len(cube.maps)):

            cube.maps[i] = cube.maps[i].resample((256,256) * u.pix)

        self.cube = cube

