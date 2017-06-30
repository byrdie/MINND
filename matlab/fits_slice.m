data = fitsread('../datasets/aia/aia.lev1.94A_2017-06-03T06-30-23.12Z.image_lev1.fits');
fitsdisp('../datasets/aia/aia.lev1.94A_2017-06-03T06-30-23.12Z.image_lev1.fits')

imshow(data, 'DisplayRange',[min(data(:)) max(data(:))])