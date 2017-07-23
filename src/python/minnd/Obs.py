
import abc      # Import Abstract Base Class

from sunpy.net import vso       # Import Virtual Solar Observatory class
from download import Downloader     # Import custom downloader class that won't overwrite previously downloaded files

class Obs(object):
    __metaclass__ = abc.ABCMeta     # Register as an abstract class

    # Instrument properties
    source = []
    instrument = []

    # data storage location
    cube = []

    # Constructor for AIA_Obs class
    # Either the file_list param must be specified OR t_start, t_end, and wavl must be specifieda
    # @param file_list:     path to text file containing list of data files
    def __init__(self, src_name, inst_name, index_file = None, t_start = None, t_end = None, wavl_min = None, wavl_max = None, data_dir =''):

        # Set instrument properties
        self.source = src_name
        self.instrument = inst_name

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

    @abc.abstractmethod
    def import_data(self, file_list):
        """ Method interface to import data into cube """
        return