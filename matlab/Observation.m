classdef Observation
    %Observation superclass for all instrument types used in this project
    
    % Properties common to all observations
    properties
        t_start;    % Start time of observation
        t_end;      % End time of observation
        wavl_min;       % Minimum wavelength of observation
        wavl_max;       % Maximum wavelength of observation
        data_dir;       % Location of the dataset
        
        tssc;           % Memory location of the data cube
    end
    
    % Methods available to all observations
    methods
        
        % Constructor for observation
        function self = Observation(t_start, t_end, wavl_min, wavl_max, data_dir)
            
            % Save observation parameters
            self.t_start = t_start;
            self.t_end = t_end;
            self.wavl_min = wavl_min;
            self.wavl_max = wavl_max;
            self.data_dir = data_dir;
            
        end
        
    end
    
%     % Methods to be implemented by specific instruments
%     methods (Abstract)
%        import(self);    % Import the data into memory 
%     end
    
end

