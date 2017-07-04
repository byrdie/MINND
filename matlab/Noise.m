classdef Noise < Model
    %Noise Defines an instrument noise model
    %   Supplies functions to apply and remove instrument noise for an
    %   arbitrary tempero-spatial-spectral cube (TSSC)
    
    % Parameters of the noise model
    properties
        read_noise      % (?) Read noise estimate
        poisson_noise   % (?) Poisson noise estimate
        
        
    end
    
    % Noise model methods
    methods
        
        % Constructor method for noise model
        function self = Noise(read, poisson, train_data, test_data)
            
            % Call superclass constructor
            self@Model(train_data, test_data);
           
            % Save model parameters
            self.read_noise = read;
            self.poisson_noise = poisson;
            
        end
        
        % Applies noise model to TSSC
        function out_tssc = eval(self, in_tssc)
            
           out_tssc = in_tssc; % TEMPORARY!!!
           
        end
        
        % Removes noise model from TSSC
        function out_tssc = invert(self, in_tssc)
            
           out_tssc = in_tssc; % TEMPORARY!!!
           
        end
        
    end
    
end

