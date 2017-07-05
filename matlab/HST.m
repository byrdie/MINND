classdef HST
    %HST base class for hyperspectral tensor
    %   subclasses should implement a hyperspectral tensor of a specific
    %   dimensionality.
    
    % Properties to be implemented by subclasses
    properties
        
        t;  %   Times at each t-index (UTC)
        x;  %   x-coordinate at each x-index
        y;  %   y-coordinate at each y-index
        l;  %   wavelength coordinate at each l-index
        
        t_sz;   % size of the time dimension
        x_sz;   % size of the first spatial dimension
        y_sz;   % size of the second spatial dimension
        l_sz;   % size of the spectral dimension
        
        % Main tensor storage location
        data;
        
        % Solar observation properties
        pixel_subtent
        
    end
    
    methods
        
        function self = HST(fits_files)
            self.data = [];
        end
        
        function [] = import_fits(self, fits)
            
            % Loop through filenames
            for i = 1:numel(fits)
                
                % select the filename
                file = fits{i};
                
                %                 py_img = py.sunpy.io.fits.read(file);
                %                 py_img{1}(1)
                
                % read in parameters from the fits header
                info = fitsinfo(file);
                info.PrimaryData.Keywords
                
                img = fitsread(file);
                
                imshow(img, 'DisplayRange',[min(img(:)) max(img(:))]);
                
                
                
                
                %                 if i == 1
                %
                %                 end
                
            end
            
        end
        
    end
    
    % Static methods for the hyperspectral tensor
    methods (Static)
        
        % takes a list of fits files and slices them into smaller pieces
        % and saves the result in a new fits file
        function paths = slice_fits(paths, stride)
            
            % Loop through filenames
            for i = 1:numel(paths)
                
                % select the filename
                file = fits{i};
                
                % read in parameters from the fits header
                keywords = fitsinfo(file).PrimaryData.Keywords;
                
                % read in data from fits file
                img = fitsread(file);
                
                
            end
            
        end
        
        function T = 
        
        
        
    end
    
end

