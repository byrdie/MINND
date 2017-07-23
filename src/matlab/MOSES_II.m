classdef MOSES_II < MOSES
    %MOSES_II Properties and methods for the MOSES-II instrument
    %   MOSES-II and MOSES-I differ on a few things, so they must be
    %   treated separately.
    
    % Properties for the MOSES-II instrument
    properties
        
        read_noise = 0;
        poisson_noise = 0;
        
        noise_mod           % Model.Noise type
%         psf_mod             % Model.PSF type
%         diffraction_mod     % Model.Diffraction type
    end
    
    methods
        function self = MOSES_II()
            self.noise_mod = Noise(read_noise, poisson_noise);
        end
    end
    
end

