

% load old value
aia_pr_file = 'hist/aia_pr.mat';
if exist(aia_pr_file, 'file') == 2
    load(aia_pr_file);
    aia_pr_old = aia_pr;
end
aia_pr = [t_start, t_end, wavl, data_dir, py_path];
save(aia_pr_file, 'aia_pr');      % Save new value