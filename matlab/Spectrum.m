classdef Spectrum < TSST
    %Spectrum superclass for HSST objects with spectral dimension
    %   Stores physical information about the spectral dimension within TSST
    
    % Constant properties of this dimension
    properties (Constant)
        
        l_dim = 8;  % Location of the spectral dimension in the TSST
        k_dim = 4;  % Location of the spectral stride dimension in the TSST
        
    end
    
    % Variable properties of this dimension
    properties
        
        l_stride;   % Longest length of the spectral dimension (pixel)
        l;          % Array of spectral coordinates for each index (angstrom)
        
    end
    
    methods
        
        function self = Spectrum(l, l_stride)
            self.l = l;
            self.l_stride = l_stride;
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

