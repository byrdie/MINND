classdef Imager < Observation
    %Imager superclass for all solar imaging instruments used in this
    %project
    %   Properties and methods common to all solar imaging instruments.
    
    properties
    end
    
    % Methods common to all imagers in this project
    methods
        
        function self = Imager(t_start, t_end, wavl_min, wavl_max, data_dir)
           
            self@Observation(t_start, t_end, wavl_min, wavl_max, data_dir);
            
        end
        
    end
    
end

