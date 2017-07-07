classdef VSO
    %VSO Access to the Virtual Solar Observatory
    %   Allows for the query and download of solar observations over
    %   the internet. Uses the Matlab-python interface and Sunpy to access
    %   the VSO. Please make sure to have a working copy of Sunpy installed
    %   before using this class.
    
    % VSO properties
    properties (Constant)
        unit_wav = 'Angstrom';
        dw_path = '../python/sunpy_fork/net'
        dir_prototype = '/{source}/{instrument}/{file}';
    end
    
    % VSO-specific methods
    methods (Static)
        
        % Queries VSO for the time frame, wavlength, and instrument and
        % downloads the data into dir.
        function fits_files = query_and_get(S, inst_name, t_start, t_end, min_wav, max_wav, dir)
            
            %import py.sunpy.net.*;    % Load Sunpy's VSO libraries
            
            v_client = py.sunpy.net.vso.VSOClient(); % Initialize VSO client
            
            % Create arguments for query
            kwargs = pyargs('instrument', inst_name, 'min_wave', min_wav, 'max_wave', max_wav, 'unit_wave', S.unit_wav);
            
            % query the VSO using the specified parameters
            v_query = v_client.query_legacy(t_start, t_end, kwargs);
            
            % Initialize custom downloader class
            if count(py.sys.path, S.dw_path) == 0
                insert(py.sys.path,int32(0), S.dw_path);
            end
            dw = py.download.Downloader();  % Instantiate class
            dw.init();  % Initialize class
            
            % Create arguments for file download
            kwargs = pyargs('path', strcat(dir, dir_prototype), 'downloader', dw, 'methods', 'URL-FILE');
            
            % Download the files
            fits_files_py = v_client.get(v_query, kwargs).wait();
            
            % Convert the python strings into cell array of char arrays
            cP = cell(fits_files_py);
            cellP = cell(1, numel(cP));
            for n=1:numel(cP)
                strP = char(cP{n});
                cellP(n) = {strP};
            end
            fits_files = cellP;
            
            
        end
        
    end
    
end

