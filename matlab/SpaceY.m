classdef SpaceY < TSST
    %SpaceY superclass for HSST objects with y spatial dimension
    %   Stores physical information about the  y spatial dimension within TSST
    
    % Constant properties of this dimension
    properties (Constant)
        
        y_dim = 7;  % Location of the y spatial dimension in the TSST
        j_dim = 3;  % Location of the y spatial stride dimension in the TSST
        
    end
    
    % Variable properties of this dimension
    properties
        
        y_stride;   % Longest length of the y spatial dimension (pixel)
        y;          % Array of y spatial coordinates for each index (arcsec)
        
    end
    
    methods
        
        function self = SpaceY(y, y_stride)
            self.y = y;
            self.y_stride = y_stride;
        end
        
        % Simple function to return the size of the y spatial dimension
        function sz = y_sz(self)
           sz = size(self.T, self.y_dim); 
        end
        
        % Simple function to return the size of the y spatial stride dimension
        function sz = j_sz(self)
           sz = size(self.T, self.j_dim); 
        end
        
    end
    
end

