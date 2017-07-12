classdef DataSource
    %DataSource Abstract class defining methods to download and access data
    
    properties (Abstract)
        
        files;      % cell array of fits files for every observation
        
    end
    
    
end

