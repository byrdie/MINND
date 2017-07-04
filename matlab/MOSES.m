classdef MOSES < SnapshotImagingSpectrograph
    %MOSES superclass for MOSES instrument
    %   Providing properties and methods common to the entire MOSES
    %   instrument
    
    % Iteration-dependent MOSES instrument properties
    properties (Abstract)
        noise_mod           % Model.Noise type
%         psf_mod             % Model.PSF type
%         diffraction_mod     % Model.Diffraction type
    end
    
end

