classdef Spectrum < TSST
    %Spectrum superclass for HSST objects with spectral dimension
    %   Stores physical information about the spectral dimension within TSST
    
    properties
        
        l_dim = 4;  % Location of the spectral dimension in the TSST
        k_dim = 8;  % Location of the spectral stride dimension in the TSST
        l_stride;   % Longest length of the spectral dimension
        l_pScale;   % Pixel wavelength range
        l;          % Array of spectral coordinates for each index
        
    end
    
    methods
        
        function self = Spectrum(l_stride, l_pScale)
            self.l_stride = l_stride;
            self.l_pScale = l_pScale;
        end
        
        % Simple function to return the size of the spectral dimension
        function sz = l_sz(self)
           sz = size(self.T, self.l_dim); 
        end
        
        % Simple function to return the size of the spectral dimension
        function sz = k_sz(self)
           sz = size(self.T, self.k_dim); 
        end
        
    end
    
end

