classdef AIA
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
%         files;
        
%         % Dataset query parameters
%         t_start;    % Start of the requested time period
%         t_end;      % End of the requested time period
%         wavl_min;   % Minimum requested wavelength
%         wavl_max;   % Maximum requested wavelength
        
    end
    
    % Methods for use with only AIA observations
    methods
        
        % Constructor for the AIA observation class
        function S = AIA(t_start, t_end, wavl_min, wavl_max)
            
                             
            % Download the AIA data for the time and wavelength range
            src = VSO(S.instrument, t_start, t_end, wavl_min, wavl_max, S.download_dir);
            
            % Copy the files from disk into memory
            S.import_data(src.files)
            
            
        end
        
        function [] = import_data(S, files)
            
            % Read the first header to save AIA parameters
            header = fitsinfo(files{1});
            kw = header.PrimaryData.Keywords
            
            % Extract parameters from the first header
            i_naxis1 = strfind(kw{:,1}, 'NAXIS1')
            
%             x_sz = kw{, 2};
%             y_sz = kw.NAXIS2;
%             t_sz = numel(files);
            
            % Create the data array
            cube = zeros(x_sz, y_sz, t_sz)
            
            % Create arrays to store coordinate values for each dimension
            x = zeros(x_sz);
            y = zeros(y_sz);
            t = zeros(t_sz);
            
            % Create temporary array for keeping track of wavlength for
            % each input image
            lambda_t = zeros(t_sz);
            
            % Loop through filenames
            for i = 1:t_sz
                
                % select the filename
                file = files{i};
                
                % read in parameters from the fits header
                header = fitsinfo(file);
                keywords = header.PrimaryData.Keywords;
%                 t(i) = keywords.DATE-OBS;
                
                % read in data from fits file
                img = fitsread(file);
                
            end
            
        end
        
        function [] = download_files(S)

            
        end
    end
    
end

