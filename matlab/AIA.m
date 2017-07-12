classdef AIA < handle
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
        
        % Final stride of the dataset
        stride_x = 32;
        stride_y = 32;
        
        % Main data storage location
        tsst;
        
        
    end
    
    % Methods for use with only AIA observations
    methods
        
        % Constructor for the AIA observation class
        function S = AIA(keyword, params)
            
            if keyword == 'txt'
                
                % Text file containing fits paths is the only parameter
                file_list = params;
                
                % Construct source object
                src = FileSource(file_list);
                
                
            elseif keyword == 'vso'
                
                t_start = params{1};
                t_end = params{2};
                wavl = params{3};
                
                % Download the AIA data for the time and wavelength range
                src = VSO(S.instrument, t_start, t_end, wavl, S.download_dir);
                
            end
            
            
            
            % Copy the files from disk into memory
            S.import_keywords(src.files);
            
            
        end
        
        
        
        % Imports keywords that should not change across files
        function [] = import_keywords(S, files)
            
            import matlab.io.*  % Import the CFITSIO library C API
            
            len_t = size(files, 2);    % Number of time steps
            len_k = size(files, 1);     % Number of wavelength steps
            
            
            % Allocate memory for initial coordinate information vectors
            Nt = len_t;
            Nx = zeros(len_k, len_t);
            Ny = zeros(len_k, len_t);
            dx = zeros(len_k, len_t);
            dy = zeros(len_k, len_t);
            sun_center_x = zeros(len_k, len_t);
            sun_center_y = zeros(len_k, len_t);
            r_sun = zeros(len_k, len_t);
            l = zeros(len_k, len_t);
            t = cell(len_k, len_t);
            
            % Loop through time
            for n = 1:len_t
                
                % loop through wavelengths
                for k = 1:len_k
                    
                    fptr = fits.openFile(files{k, n}); % Open the fits file
                    num_hdu = fits.getNumHDUs(fptr);  % Find the number of HDUs
                    
                    if num_hdu == 1     % Only read the first HDU
                        
                        % Select the first HDU
                        fits.movAbsHDU(fptr,1);
                        
                        % Read in keys
                        Nx(k, n) = fits.readKeyLongLong(fptr,'NAXIS1');
                        Ny(k, n) = fits.readKeyLongLong(fptr,'NAXIS2');
                        dx(k, n) = fits.readKeyDbl(fptr,'CDELT1');
                        dy(k, n) = fits.readKeyDbl(fptr,'CDELT2');
                        sun_center_x(k, n) = fits.readKeyDbl(fptr,'X0_MP');
                        sun_center_y(k, n) = fits.readKeyDbl(fptr,'Y0_MP');
                        r_sun(k, n) = fits.readKeyDbl(fptr,'R_SUN');
                        l(k, n) = fits.readKeyDbl(fptr,'WAVELNTH');
                        t{k, n} = fits.readKey(fptr, 'DATE-OBS');
                        
                        
                    else    % AIA fits files should not have more than one HDU
                        
                        disp('ERROR! More than one HDU');
                        
                    end
                    
                    fits.closeFile(fptr);   % Close the FITS file
                    
                end
                
            end
            
            
            % Reduce a subset of the keywords to a scalar value
            Nx = unique(Nx);
            Ny = unique(Ny);
            dx = mean(dx(:));
            dy = mean(dy(:));
            sun_center_x = mean(sun_center_x(:));
            sun_center_y = mean(sun_center_y(:));
            r_sun = mean(r_sun(:));   % Take the mean of the radius since apparently SDO is in orbit
            wavl = unique(l(:));
            t = unique(t(1,:));
            
            
            % Check to make sure all values excpet wavlength are scalars
            if(~isscalar(Nx) || ~isscalar(Ny) || ~isscalar(dx) || ~isscalar(dy) || ~isscalar(sun_center_x) || ~isscalar(sun_center_y) || ~isscalar(r_sun) )
                disp('ERROR! Inconsistent alignemnt detected!')
            end
            
            % Call the TSST constructor
            Nl = 1;     % Only one wavelength per spectral chunk
            Nm = 1;     % Only one spectral order
            Np = 1;     % Only one spectral angle
            Ni = 1;     % Only one x chunk
            Nj = 1;     % Only one y chunk
            Nk = numel(wavl);   % Variable number of spectral chunks, depending on query
            Nn = 1;     % Only one t chunk
            S.tsst = TSST(Nx, Ny, Nl, Nm, Np, Nt, Ni, Nj, Nk, Nn);  % Constructor call
            
            % Insert FITS files into TSST
            id = 'MATLAB:imagesci:fitsinfo:missingEndQuote';
            warning('off', id);   % Turn off endquote warnings
            for n = 1:len_t     % Loop through time
                for k = 1:len_k     % loop through wavelengths
                    S.tsst.T(:, :, 1, 1, 1, n, 1, 1, k, 1) = fitsread(files{k, n});
                end
            end
            
            % Insert coordinate vectors into TSST
            S.tsst.x(:,1) = (0 : Nx-1) * dx - sun_center_x;
            S.tsst.y(:,1) = (0 : Ny-1) * dy - sun_center_y;
            S.tsst.l(1,:) = wavl;
            S.tsst.t(:,1) = t;
            
            % Crop the border out of the AIA image
            min_x = ceil((sun_center_x - r_sun) / S.stride_x) * S.stride_x + 1;
            max_x = ceil((sun_center_x + r_sun) / S.stride_x) * S.stride_x;
            min_y = ceil((sun_center_y - r_sun) / S.stride_y) * S.stride_y + 1;
            max_y = ceil((sun_center_y + r_sun) / S.stride_y) * S.stride_y;
            S.tsst.crop_xy(min_x, max_x, min_y, max_y);
            
            % Set the spatial stride of the dataset
            S.tsst.slice_xy(S.stride_x, S.stride_y);
            
%             S.tsst.disp_xyt_cube(1,1,1,1,1,1,1)
            
        end
    end
    
end

