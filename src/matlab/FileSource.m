classdef FileSource < DataSource
    %FileSource Provides a basic interface for text input files
    
    properties
        
        files
        
    end
    
    methods
        
        function S = FileSource(file_list)
           
           % Open the text file containing the list of input files
           fid = fopen(file_list);
           
           % Read in file 
           i = 1;   % initialize index variable
           tline = fgetl(fid);  % Grab first line
           while feof(fid) == 0  % Loop until EOF
              S.files{i} = tline;   % Insert line into cell array
              tline = fgetl(fid);   % Get next line
              i = i + 1;
           end
            
           fclose(fid);
           
        end
        
    end
    
end

