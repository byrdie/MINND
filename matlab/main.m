% Main script

% Reset memory
clear all

% Read parameter file
params

% Check if we alread
if(~strcmp(aia_pr, aia_pr_old))
    aia_get(t_start, t_end, wavl, data_dir, py_path);
end
