from astropy import units as u

from sunpy.net import vso       # Import Virtual Solar Observatory class
from download import Downloader     # Import custom downloader class that won't overwrite previously downloaded files
from sunpy.io import read_file

import sunpy.map
import sunpy.map.mapcube
import matplotlib.pyplot as plt
import matplotlib.animation as animation




# Provides a class structure stroring properties and methods for manipulating AIA observations
class AIA_Obs:

    # Instrument properties
    source = 'SDO'
    instrument = 'AIA'

    # data storage location
    cube = []

    # Constructor for AIA_Obs class
    # Either the file_list param must be specified OR t_start, t_end, and wavl must be specifieda
    # @param file_list:     path to text file containing list of data files
    def __init__(self, index_file = None, t_start = None, t_end = None, wavl_min = None, wavl_max = None, data_dir =''):

        # check the keyword parameters
        if index_file != None:   # Check if the file_list parameter is specified

            # Read index file into a list with each line as a separate element/filename
            with open(index_file) as f:
                file_list = f. readlines()

            file_list = [x.strip() for x in file_list]      # Stip off newlines, and trailing and leading whitespace

            self.import_data(file_list)     # If so, we are free to import data

        elif ((t_start != None) and (t_end != None) and (wavl_min != None) and (wavl_max != None)):    # If not, we need to grab the data from the VSO

            # Find the available files for download using the Virtual Solar Observatory
            c = vso.VSOClient() # Initialize Sunpy VSO client
            #qr = c.query(vso.vso.attrs.Time(t_start, t_end), vso.vso.attrs.Instrument(self.instrument), vso.vso.attrs.Wave(wavl_min * u.AA, wavl_max * u.AA))
            #qr = c.query(vso.vso.attrs.Time(t_start, t_end), vso.vso.attrs.Instrument(self.instrument))
            qr = c.query_legacy(tstart=t_start, tend=t_end, instrument=self.instrument, min_wave=wavl_min, max_wave=wavl_max, unit_wave='Angstrom')   # Query the VSO for files
            print(qr)   # Print the query

            # Download the files returned by the query
            dw = Downloader()   # Initialize custom downloader class
            r = c.get(qr, path = data_dir + '/{source}/{instrument}/{file}').wait()

            print(r)

            # Import the data
            # self.import_data(file_list)

        else:   # Invalid keyword combination

            print('Incorrect keyword specification')


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

