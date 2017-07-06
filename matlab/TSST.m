classdef TSST
    %HST base class for temporal-spatial-spectral tensor
    %   subclasses should implement a hyperspectral tensor of a specific
    %   dimensionality.
    
    % Properties to be implemented by subclasses
    properties
        
        t;  %   Times at each t-index (UTC)
        x;  %   x-coordinate value at each x-index
        y;  %   y-coordinate value at each y-index
        l;  %   lambda-coordinate value at each lambda-index
        n;  %   time chunk index
        i;  %   x chunk index
        j;  %   y chunk index
        k;  %   lambda chunk index
        m;  %   spectral order
        p;  %   spectral projection angle
        
        t_sz;   % size of the time dimension
        x_sz;   % size of the first spatial dimension
        y_sz;   % size of the second spatial dimension
        l_sz;   % size of the spectral dimension
        
        % Main tensor storage location
        T;
        
        % Solar observation properties
        pixel_subtent
        
    end
    
    methods
        
        function self = TSST(kw, val)
            
            % Determine action based on keyword
            switch kw
               
                case 'fits'
                    
                
               
            end
            
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

