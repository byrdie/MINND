classdef (Abstract) Model
    %Model Abstract class defining an instrument model.
    %   An instrument model is representative of a particular effect of a
    %   CTIS instrument. A model should have both a forward and an inverse
    %   operation. The inverse operation is found by applying the forward
    %   model to a training dataset and using a neural network to invert
    %   the operation.
    
    % Model-independent properties
    properties
        
        train_data; % (TSSC) Training data for the inversion neural network
        test_data;  % (TSSC) Validation data for the inversion neural network
        
    end
    
    % Model-independent methods
    methods
        
        % Constructor for Model class
        function self = Model(train_data, test_data)
            
            % Save the datasets
            self.train_data = train_data;
            self.test_data = test_data;
            
        end
        
    end
    
    % Model-dependent methods
    methods (Abstract)
        
        % Applies forward model to TSSC
        eval(self, tssc)
        
        % Applies inverse model to TSSC
        invert(self, cube)
        
    end
    
end

