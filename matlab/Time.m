classdef Time
    %Time superclass for HSST objects with time dimension
    %   Stores physical information about the time dimension within TSST
    
    % Constant properties of this dimension
    properties (Constant)
        t_dim = 5;  % Location of the time dimension in the TSST
        n_dim = 1;  % Location of the time stride dimension in the TSST
    end
    
    % Variable properties of this dimension
    properties
        t_stride;   % Longest length of the time dimension
        t;          % Array of time coordinates for each index (UTC)   
    end
    
    methods
        
        % Constructor for TSST time objects
        function self = Time(t, t_stride)
            
            self.t = t;
            self.t_stride = t_stride;
            
        end
        
        % Simple function to return the size of the time dimension
        function sz = t_sz(self)
            sz = size(self.T, self.t_dim);
        end
        
        % Simple function to return the size of the time dimension
        function sz = n_sz(self)
            sz = size(self.T, self.n_dim);
        end
        
    end
    
end

