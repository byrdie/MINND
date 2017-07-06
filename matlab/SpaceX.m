classdef SpaceX < TSST
    %SpaceX superclass for HSST objects with x spatial dimension
    %   Stores physical information about the x spatial dimension within TSST
    
    % Constant properties of this dimension
    properties (Constant)
        
        x_dim = 6;  % Location of the x spatial dimension in the TSST
        i_dim = 2;  % Location of the x spatial stride dimension in the TSST
        
    end
    
    % Variable properties of this dimension
    properties
        
        x_stride;   % Longest length of the x spatial dimension (pixel)
        x;          % Array of x spatial coordinates for each index (arcsec)
        x_roll;     % Roll angle for each index of the array
 
    end
    
    methods
        
        % Constructor
        function self = SpaceX(x, x_roll, x_stride)
            self.x = x;
            self.x_roll = x_roll;
            self.x_stride = x_stride;
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

