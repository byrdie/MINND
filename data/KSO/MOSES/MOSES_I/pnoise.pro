;+
;NAME:
;  PNOISE
;PURPOSE:
;  Add poisson noise to an array of data (in counts). Any
;  datum less than or equal to 0.0 is not modified.
;CALLING SEQUENCE:
;  pnoise, data [, seed=seed]
;INPUTS:
;  data - a data array of any size or dimension, in counts. This
;     array is modified in place.
;OPTIONAL KEYWORDS:
;  seed - seed for the random number generator.
;COMMON BLOCKS:
;  PNOISE_SEED contains only one element, pseed. This allows the
;     seed to persist from function call to function call. NO LONGER USED.
;HISTORY:
;  CCK 20020915
;  CCK 20050528 discovered pseed bug, eliminated common block.
;  2011-Nov-28 CCK added /double keyword, so PNOISE will work for very
;     large count rates.
;-

pro pnoise, data, seed=seed

;common pnoise_seed, pseed FOR SOME REASON, THIS BROKE THE RANDOMNESS!
;if n_elements (seed) ne 0 then pseed=seed

N = n_elements(data)
for i=0L, N-1 do begin
   if data[i] gt 0.0 then data[i] = randomn(seed, poisson=data[i], /double)
endfor

end
