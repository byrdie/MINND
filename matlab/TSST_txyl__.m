classdef TSST_txyl__ < Time & SpaceX & SpaceY & Spectrum
    %TSST_txyl__ TSST for observations with only spectral, spatial and
    %temporal information.
    %   This class is the most common instance of a TSST as most solar
    %   observations acquire data in these 4 dimensions.
    
    properties
    end
    
    methods
        
        % Constructor for simple TSST
        %   T = input tensor
        %   X = cell array of coordinates for each dimension
        %   S = cell array of strides for each dimension
        function self = TSST_txyl__(T, X, S)
            
            % call superclass constructors
            
            
        end
        
    end
    
end

