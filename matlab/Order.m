classdef Order < TSST
    %Order superclass for HSST objects with spectral order dimension
    %   Stores physical information about the spectral order dimension within TSST
    
    % Constant properties of this dimension
    properties (Constant)
        
        m_dim = 9;  % Location of the spectral order dimension in the TSST
        
    end
    
    % Variable properties of this dimension
    properties
            
        m;          % Array of spectral order for each index
        
    end
    
    methods
        
        function self = Spectrum(m, m_pScale)
            self.m = m;
            self.m_pScale = m_pScale;
        end
        
        % Simple function to return the size of the spectral dimension
        function sz = m_sz(self)
           sz = size(self.T, self.m_dim); 
        end
        
    end
    
end

