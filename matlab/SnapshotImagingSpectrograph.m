classdef (Abstract) SnapshotImagingSpectrograph < Observation
    %CTIS Abstract class for all models of computed tomography imaging spectrographs
    %   Implementations of this class will contain forward and backward
    %   models of various spectrographs developed by the Kankelborg
    %   Research Group, Montana State University
    
    % Instrument-specific properties
    properties (Abstract)
        noise_mod           % Model.Noise type
%         psf_mod             % Model.PSF type
%         diffraction_mod     % Model.Diffraction type
    end
    
    
    % Instrument-independent methods
    methods
        
       % Downloads AIA data for the specified time range 
        function [ fits_paths ] = aia_get(self, t_start, t_end, wavl, data_dir)    
            
            % delete old data in the data directory
            delete (strcat(data_dir, '/*.fits'))
            
            % Add the python file to the python search path
            if count(py.sys.path, self.py_path) == 0
                insert(py.sys.path, int32(0), self.py_path);
            end
            
            % Call Sunpy function to download AIA data
            fits_paths = py.aia_get.aia_range(t_start, t_end, wavl, data_dir);
            
        end
    end
    
end

