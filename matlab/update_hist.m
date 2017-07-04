function [old_val] = update_hist(name, val)

% load old value
file = strcat('hist/',strcat(name, '.mat'));
if exist(file, 'file') == 2
    load(file);
    old_val = val;
else
    old_val = 0;
end
save(file, 'val');      % Save new value

end