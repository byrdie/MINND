classdef VSO < DataSource
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
    
    properties
        
        inst_name;  % Name of the instrument
        t_start;    % Requested start time of the observation
        t_end;      % Requested end time of the observation
        wavl_min;   % Requested minimum wavelength of the observation
        wavl_max;   % Requested maximum wavelength of the observation
        download_dir;   % Location to which to download the data
        
        files;      % cell array of filenames
        
    end
    
    
    % VSO-specific methods
    methods
        
        function S = VSO(inst_name, t_start, t_end, wavl_min, wavl_max, download_dir)
            
            S.inst_name = inst_name;
            S.t_start = t_start;
            S.t_end = t_end;
            S.wavl_min = wavl_min;
            S.wavl_max = wavl_max;
            S.download_dir = download_dir;
            
            S.files = S.query_and_get();
            
        end
        
        % Queries VSO for the time frame, wavlength, and instrument and
        % downloads the data into dir.
        function fits_files = query_and_get(S)
            
            %import py.sunpy.net.*;    % Load Sunpy's VSO libraries
            
            v_client = py.sunpy.net.vso.VSOClient(); % Initialize VSO client
            
            % Create arguments for query
            kwargs = pyargs('instrument', S.inst_name, 'min_wave', S.wavl_min, 'max_wave', S.wavl_max, 'unit_wave', S.unit_wav);
            
            % query the VSO using the specified parameters
            v_query = v_client.query_legacy(S.t_start, S.t_end, kwargs);
            
            % Initialize custom downloader class
            if count(py.sys.path, S.dw_path) == 0
                insert(py.sys.path,int32(0), S.dw_path);
            end
            dw = py.download.Downloader();  % Instantiate class
            dw.init();  % Initialize class
            
            % Create arguments for file download
            kwargs = pyargs('path', strcat(S.download_dir, S.dir_prototype), 'downloader', dw, 'methods', 'URL-FILE');
            
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

