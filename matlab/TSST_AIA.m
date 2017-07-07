classdef TSST_AIA < TSST
    %AIA properties and methods for dealing with AIA data in this project
    %   Serves as a container for the data and provides methods for
    %   downloading data via the Virtual Solar Observatory.
    
    properties (Constant)
        
        % Instrument properties
        source = 'SDO';
        instrument = 'AIA';
        
        download_dir = '../datasets';   % Directory in which to download datasets
        
    end
    
    properties
        

        
        % Dataset disk storage properties
        files;
        
        % Dataset query parameters
        t_start;    % Start of the requested time period
        t_end;      % End of the requested time period
        wavl_min;   % Minimum requested wavelength
        wavl_max;   % Maximum requested wavelength
        
    end
    
    % Methods for use with only AIA observations
    methods
        
        % Constructor for the AIA observation class
        function S = TSST_AIA(t_start, t_end, wavl_min, wavl_max)
                                   
            % Download the AIA data for the time and wavelength range
            files = VSO.query_and_get(S.instrument, t_start, t_end, wavl_min, wavl_max, S.download_dir);
            
            
            S.t_start = t_start;
            S.t_end = t_end;
            S.wavl_min = wavl_min;
            S.wavl_max = wavl_max;
            
            
        end
        
        function [] = read_files(S)
            
            % Loop through filenames
            for i = 1:numel(S.files)
                
                % select the filename
                file = S.files{i};
                
                % read in parameters from the fits header
                keywords = fitsinfo(file).PrimaryData.Keywords;
                
                % read in data from fits file
                img = fitsread(file);
                
            end
            
        end
        
        function [] = download_files(S)

            
        end
    end
    
end

