classdef AIA < Imager & VSO
    %AIA properties and methods for dealing with AIA data in this project
    %   Serves as a container for the data and provides methods for 
    %   downloading data via the Virtual Solar Observatory.
    
    properties
        inst_name = 'AIA';  % Define instrument name for searching VSO
        hst;
    end
    
    % Methods for use with only AIA observations
    methods
        
        % Constructor for the AIA observation class
        function self = AIA(t_start, t_end, wavl_min, wavl_max, data_dir)
            
            % Call superclass constructor
            self = self@Imager(t_start, t_end, wavl_min, wavl_max, data_dir);
            
            % Download the AIA data for the time and wavelength range
            fits = self.query_and_get(t_start, t_end, wavl_min, wavl_max, data_dir);
            
            % load the fits files into memory
            HST.slice_fits(fits, 128);
            
        end
    end
    
end

