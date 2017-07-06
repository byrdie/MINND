classdef SpaceX < TSST
    %SpaceX superclass for HSST objects with x spatial dimension
    %   Stores physical information about the x spatial dimension within TSST
    
    properties
        
        x_dim = 2;  % Location of the x spatial dimension in the TSST
        i_dim = 6;  % Location of the x spatial stride dimension in the TSST
        x_stride;   % Longest length of the x spatial dimension
        x_pScale;   % Pixel subtent
        x;          % Array of x spatial coordinates for each index
        
    end
    
    methods
        
        function self = SpaceX(x_stride, x_pScale)
            self.x_stride = x_stride;
            self.x_pScale = x_pScale;
        end
        
        % Simple function to return the size of the x spatial dimension
        function sz = x_sz(self)
           sz = size(self.T, self.x_dim); 
        end
        
        % Simple function to return the size of the x spatial stride dimension
        function sz = i_sz(self)
           sz = size(self.T, self.i_dim); 
        end
        
    end
    
end

