classdef Angle < TSST
    %Angle superclass for HSST objects with spectral angle dimension
    %   Stores physical information about the spectral angle dimension within TSST
    
    % Constant properties of this dimension
    properties (Constant)
        
        p_dim = 10;  % Location of the spectral angle dimension in the TSST
        
    end
    
    % Variable properties of this dimension
    properties
         
        p;          % Array of spectral angles for each index
        
    end
    
    methods
        
        function self = Spectrum(p)
            self.p = p;
        end
        
        % Simple function to return the size of the spectral dimension
        function sz = p_sz(self)
           sz = size(self.T, self.p_dim); 
        end
        
    end
    
end

