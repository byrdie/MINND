classdef TSST
    %HST base class for temporal-spatial-spectral tensor
    %   subclasses should implement a hyperspectral tensor of a specific
    %   dimensionality.
    
    % Constant values in the TSST class
    properties (Constant)
        
        Dx = 1;     % x dimension
        Dy = 2;     % y dimension
        Dl = 3;     % spectral dimension
        Dm = 4;     % spectral order dimension
        Dp = 5;    % spectral angle dimension
        Dt = 6;     % time dimension
        Di = 7;     % x stride dimension
        Dj = 8;     % y stride dimension
        Dk = 9;     % spectral stride dimension
        Dn = 10;     % time stride dimension
        
        nD = 10;    % Number of dimensions
        

        
        
    end
    
    
    properties
        
        
        % Main tensor memory storage location
        T;
        
        % Cell arrays containing vectors of physical coordinate for each
        % corresponding stride index
        t;      % Time coordinates
        x;      % x coordinates
        y;      % y coordinates
        l;      % Spectral coordinates
        m;      % Spectral order value
        p;      % Spectral angle value
        
        % Storage space for the width the stride in each dimension.
        stride;
        
        % Data origin information
        source;      % The observatory responsible for the observation
        instrument;  % The instrument responsible for the observation
        keywords;       % keywords struct provided by fits file.
        
    end
    
    methods
        
        %         % Constructor for TSST class
        %         function S = TSST(files)
        %
        %             S.files = files;
        %
        %         end
        
        % Slices up the original input tensor into separate chunks of size
        % given by the stride in each dimension
        function [] = slice_xy(S)
            
            % Find the size in each dimension
            sz = size(S.T);
            
            % Find the number of chunks in each dimension
            N = floor(size() /  )
            
            
            
        end
        
    end
    
    % Static methods for the hyperspectral tensor
    methods (Static)
        
        % Takes a list of fits files and slices them into smaller pieces
        % and saves the result in a new fits file
        function sliced_files = slice_fits(files, new_path, stride)
            
            % Initialize return variable
            sliced_files = [];
            
            % Loop through filenames
            for i = 1:numel(files)
                
                % select the filename
                file = files{i};
                
                % read in parameters from the fits header
                % keywords = fitsinfo(file).PrimaryData.Keywords;
                
                % read in data from fits file
                img = fitsread(file);
                
                % slice image
                cube = HST.slice(img, stride);
                
                % Construct new filename for the sliced image
                new_file =
                
                %                 test = squeeze(cube(32+4, :, :));
                %                 imshow(test, [min(test(:)), max(test(:))]);
                
                %                 for i = 1:20
                %                     subplot(4,5,i);
                %                     test = squeeze(cube(512 + i, :, :));
                %                     imshow(test, [min(test(:)), max(test(:))]);
                %                 end
                
            end
            
            sliced_files = [];
            
        end
        
        % Slices a given input image into a cube
        function cube = slice(img, stride)
            
            % Check to see if img is 2-dimensional
            if ~ismatrix(img)
                disp('slice called with non-image');
                cube = [];
                return;
            end
            
            [sz_x, sz_y] = size(img); % Find the size of the image
            
            % find the number of sub-images given the stride
            n_x = int16(sz_x / stride);
            n_y = int16(sz_y / stride);
            
            % Use double loop to slice
            cube = zeros(n_x * n_y, stride, stride);    % initialize cube
            for i = (1:n_x)         % loop along x-dimension
                for j = (i:n_y)     % loop along y-dimension
                    
                    % Find the limits of the subimage
                    x_min = stride * (i - 1) + 1;   % Minimum x pixel
                    x_max = stride * i;             % Maximum x pixel
                    y_min = stride * (j - 1) + 1;   % Minimum y pixel
                    y_max = stride * j;             % Maximum y pixel
                    
                    % Select subimage
                    sub_img = img(x_min : x_max, y_min : y_max);
                    
                    % insert subimage into cube
                    k = sub2ind([n_x, n_y], i, j);
                    cube(k,:,:) = sub_img;
                    
                end
            end
            
        end
        
        
        
    end
    
end

