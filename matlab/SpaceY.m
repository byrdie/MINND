classdef SpaceY < TSST
    %SpaceY superclass for HSST objects with y spatial dimension
    %   Stores physical information about the  y spatial dimension within TSST
    
    properties
        
        y_dim = 3;  % Location of the y spatial dimension in the TSST
        j_dim = 7;  % Location 
        y_stride;   % Longest length of the y spatial dimension
        y_pScale;   % Pixel subtent
        y;          % Array of y spatial coordinates for each index
        
    end
    
    methods
        
        function self = SpaceY(y_stride, y_pScale)
            self.y_stride = y_stride;
            self.y_pScale = y_pScale;
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

