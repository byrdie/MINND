function [ fits_fp ] = aia_get( t_start, t_end, wavl, data_dir, py_path )
% Downloads AIA data for the specified time range

% delete old data in the data director
delete (strcat(data_dir, '/*.fits'))

% Add the python file to the python search path
if count(py.sys.path, py_path) == 0
    insert(py.sys.path, int32(0), py_path);
end


fits_fp = py.aia_get.aia_range(t_start, t_end, wavl, data_dir);

end

