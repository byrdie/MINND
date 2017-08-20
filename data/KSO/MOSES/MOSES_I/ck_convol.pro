;+
;NAME:
;  CK_CONVOL
;PURPOSE:
;  Like IDL's CONVOL, but with better handling of missing data. Where
;  the kernel overlaps some missing data, only the good data is used
;  and the result is renormalized like a proper weighted average.
;  CK_CONVOL is implemented as a wrapper around CONVOL. Therefore, if 
;  the behavior of CONVOL is changed in the future, the behavior of 
;  CK_CONVOL may also change.
;CALLING SEQUENCE:
;  result = ck_convol(image, kernel [,/nan] [,missing=missing] $
;     [method=method])
;  .run ck_convol ;RUNS A DEMONSTRATION PROGRAM TO ILLUSTRATE THE OPTIONS.
;INPUTS:
;  image:  Image to be convolved with kernel.
;  kernel: Kernel to be convolved with image.
;OUTPUT:
;  The result is image convolved with kernel.
;OPTIONAL KEYWORD INPUTS:
;  nan: Provided for backward compatibility with IDL convol. Does
;     nothing, unless method="IDL".
;  missing: A scalar value meant to represent missing data, both
;     in the input image and in the result. Note that NaN and Inf are
;     always treated as missing, whether or not this keyword is specified!
;  method: Specifies the method of treating missing data. Method may
;     take the following values (N.B.: method is case sensitive!):
;     "IDL" --- means to simply use CONVOL, except that any data
;        matching the 'missing' keyword is replaced by NaN before
;        calling CONVOL. So the behavior is almost, but not quite,
;        the same as CONVOL.
;     "redeem_taint" --- means to interpolate values for missing data
;        where possible, i.e. where at least one element of the kernel
;        overlaps a valid pixel. Hence, some bad pixels are 'redeemed'.
;     "conserve_taint" --- means to give values using part of the kernel,
;        renormalized, when the rest of the kernel overlaps missing data.
;        But any pixel once marked missing remains so marked.
;     "spread_taint" --- means that any pixel within the radius of the
;        kernel from a pixel marked missing will be marked missing. This
;        is the most conservative option, 'guilt by association'.
;     The default is method = "conserve_taint".
;  debug: if set, then break just before returning.
;MODIFICATION HISTORY:
;  2006-Jun-1 C. Kankelborg
;  2006-Jun-3 C. Kankelborg. Debugging, documentation.
;-
function ck_convol, image, kernel, nan=foo, missing=missing, method=method,$
   edge_truncate=edge_truncate, edge_wrap=edge_wrap, debug=debug


NaN = !values.f_nan       ;Same as result of 0.0/0.0
Inf = !values.f_infinity  ;Same as result of 1.0/0.0
isize = size(image)
Nx = isize[1]
Ny = isize[2]

if n_elements(missing) eq 0 then missing = NaN  ;default

;Remap missing data (if specified) to NaN
if finite(missing) then begin
   finite_missing = 1b
   ss = where(image eq missing)
   if (ss[0] ne -1) then image[ss] = NaN
endif else finite_missing = 0b

if n_elements(method) eq 0 then method="conserve_taint"
case method of
   "redeem_taint": begin
      mask = finite(image)
      ss = where(1b-mask)  ;Comprehensive list of bad pixels.
      result = convol(image, kernel, /nan, edge_truncate=edge_truncate, $
            edge_wrap=edge_wrap)
      norm = convol(float(mask), kernel, edge_truncate=edge_truncate, $
            edge_wrap=edge_wrap)
      result = result / norm
      if finite_missing then begin
         ss = where(1b-finite(result))
         if (ss[0] ne -1) then result[ss] = missing
      endif
   end
   "conserve_taint": begin
      mask = finite(image)
      ss = where(1b-finite(image))  ;Comprehensive list of bad pixels.
      result = convol(image, kernel, /nan, edge_truncate=edge_truncate, $
            edge_wrap=edge_wrap)
      norm = convol(float(mask), kernel, edge_truncate=edge_truncate, $
            edge_wrap=edge_wrap)
      result = result / norm
      if finite_missing then begin 
         if (ss[0] ne -1) then result[ss] = missing 
      endif else begin
         if (ss[0] ne -1) then result[ss]=NaN
      endelse
   end
   "spread_taint": begin
      result = convol(image, kernel, edge_truncate=edge_truncate, $
            edge_wrap=edge_wrap)
      if finite_missing then begin
         ss = where(1b-finite(result))
         if (ss[0] ne -1) then result[ss] = missing
      endif
   end
   "IDL": result = convol(image, kernel, nan=foo, missing=missing, $
            edge_truncate=edge_truncate, edge_wrap=edge_wrap)
   else:message,"Invalid METHOD keyword."
endcase

if keyword_set(debug) then message,'debug'
return, result

end

;*********************
;**  DEMO  PROGRAM  **
;*********************
print
print,"-------------------------------"
print,"CK_CONVOL Demonstration Program"
print,"-------------------------------"
NaN = !values.f_nan

;Demo program parameters
Nx=8 & Ny=8   ;test image size
zoom = 7      ;magnification factor for image display
missing = NaN ;pixel value for missing data

;Create test image, and make a linear colorbar for reference.
image = replicate(1.0,Nx,Ny) + 0.9*randomu(seed,Nx,Ny)
colorbar = max(image) * findgen(zoom-1,Ny*zoom)/(Ny*zoom*(zoom-1) - 1)
colorbar = [colorbar, fltarr(1,Ny*zoom)] ;add vertical separator


print,"This demo includes tiny (8x8) sample images, which will be"
print,"printed to the terminal and displayed zoomed in a new window."
print,"You may wish to expand the terminal window to make room."
print
print,"Press any key to continue."
foo=get_kbrd(1)
print

set_plot,'x'
window, 0, title="CK_CONVOL demo", xsize=(Nx+1)*zoom*(5*2), ysize=Ny*zoom


image[Nx/2-1:Nx/2+1, Ny/2-1:Ny/2+1]=missing  ;mark as missing data
print,"Original image, with 'missing' data marked as ",missing,":"
print, image
tv, displayscale([colorbar,rebin(image, zoom*Nx, zoom*Ny, /sample)],missing=missing,/ct),0
print
print,"Original image is displayed, 'missing' data in red. A linear color "+$
   "bar is provided for reference. Press any key to continue."
foo=get_kbrd(1)
print

kernel = [[1,2,1],[2,4,2],[1,2,1]]/16.0
print,"Next we will see what happens when we convolve the image"+$
   " with the following smoothing kernel:"
print, kernel
print
print,"Press any key to continue."
foo=get_kbrd(1)
print

image1 = ck_convol(image,kernel,/nan,/edge_truncate, missing=missing, $
   method="IDL")
print,"What CONVOL does -- implemented here using CK_CONVOL(...METHOD = 'IDL'):"
print, image1
tv,displayscale([colorbar,rebin(image1, zoom*Nx, zoom*Ny, /sample)],missing=missing),2

print,"In effect, CONVOL treats the missing data as if they were "   + $
      "just zeroes. Signal diffuses into the region of missing data "+ $
      "The missing data is thus permitted to bias the "+ $           + $
      "surrounding pixels. This behavior is potentially harmful. "   + $
      "Following are three alternative strategies offered by CK_CONVOL."

print
print,"Press any key to continue."
foo=get_kbrd(1)
print

print,"METHOD = 'redeem_taint' (interpolate bad pixels from good pixels):"
image2 = ck_convol(image, kernel, /edge_truncate, missing=missing, $
   method="redeem_taint")
print, image2
tv,displayscale([colorbar,rebin(image2, zoom*Nx, zoom*Ny, /sample)],missing=missing),4
print
print,"Press any key to continue."
foo=get_kbrd(1)
print

print,"METHOD = 'conserve_taint' (once a bad pixel, always a bad pixel):"
image3 = ck_convol(image, kernel, /edge_truncate, missing=missing, $
   method="conserve_taint")
print, image3
tv, displayscale([colorbar,rebin(image3, zoom*Nx, zoom*Ny, /sample)],missing=missing),6
print
print,"Press any key to continue."
foo=get_kbrd(1)
print

print,"METHOD = 'spread_taint' (guilt by association):"
image4 = ck_convol(image, kernel, /edge_truncate, missing=missing, $
   method="spread_taint")
print, image4
tv, displayscale([colorbar,rebin(image4, zoom*Nx, zoom*Ny, /sample)],missing=missing),8
print

loadct,0
end
