; Created by: Roy Smart, Nicholas Bonham
; Date: 11-08-2016
; Purpose: This procedure is a driver for the iris-seqeunce-read function.

pro iris_datset_gen

a=iris_sequence_read('/exports/fi1/IRIS/archive/level2/2013/07/31/20130731_075510_4182010156/', 'iris_l2_20130731_075510_4182010156_raster_t000_r00000.fits') 

end