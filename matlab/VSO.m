classdef VSO
    %VSO Access to the Virtual Solar Observatory
    %   Allows for the query and download of solar observations over
    %   the internet. Uses the Matlab-python interface and Sunpy to access
    %   the VSO. Please make sure to have a working copy of Sunpy installed
    %   before using this class.
    
    % VSO properties
    properties
       unit_wav = 'Angstrom';
    end
    
    % Instrument-specific VS0 properties
    properties (Abstract)
       inst_name;   % Name of the instrument according to VSO. 
    end
    
    methods
        
        % Queries VSO for the time frame, wavlength, and instrument and
        % downloads the data into dir. 
        function fits_files = query_and_get(self, t_start, t_end, min_wav, max_wav, dir)
                       
            %import py.sunpy.net.*;    % Load Sunpy's VSO libraries
            
            v_client = py.sunpy.net.vso.VSOClient(); % Initialize VSO client
            
            % Create arguments for query
            tstart = pyargs('tstart', t_start);
            tend = pyargs('tend', t_end);
            kwargs =pyargs('instrument', self.inst_name, 'min_wave', min_wav, 'max_wave', max_wav, 'unit_wave', self.unit_wav);
            
            
%             inst = pyargs('instrument', self.inst_name);
%             mw = pyargs('min_wave', min_wav);
%             xw = pyargs('max_wave', max_wav);
%             uw = pyargs('unit_wave', self.unit_wav);
            

            % query the VSO using the specified parameters
            v_query = v_client.query_legacy(t_start, t_end, kwargs);
            v_query(1)
            
            % Create arguments for file download
            path = pyargs('path', strcat(dir, '/{file}'));
            
            % Download the files
            fits_files = v_client.get(v_query, path).wait()
            
        end
        
    end
    
end

