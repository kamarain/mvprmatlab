%MVPR_IMCONVERT - Convert ("any") image to gray scale
%
% img = mvpr_imconvert(img,cT)
% img = mvpr_imconvert(img,cT,'<parameter>','<paramval>')
%
% This function was implemented to support mvpr_imread.m as that
% function applies image type conversions. Sometimes images are not
% loaded from file (e.g. camera capture), but for the algorithms to
% work they may require a similar conversion. Internally
% mvpr_imread() now calls mvpr_imconvert(). The colour type of the
% original image (cT), must be provided as this function may
% support only certain conversions.
%
% Input
%  img - Image to be converted.
%  cT  - Colour type of image to be converted (see imfinfo)
%        'truecolor'
%        'grayscale'
%        'indexed'
%
% Output
%  'range'         - scale the (theoretical) image values to range, 
%                    for example [0 1], default: empty (no
%                    scaling).
%  'type'          - the data type of the returned image, default:
%                    'single' (The type is used like a function, so
%                    it could be any function taking and returning
%                   one argument.) 
% Examples:
%  -
%
% Authors:
%  Joni Kamarainen, MVPR in 2009
%  Pekka Paalanen, MVPR in 2009
%
% Project:
%  -
%
% References:
%
% See also MVPR_IMREAD.M .
%
function [img] = mvpr_imconvert(img_,cT_,varargin)

conf = struct( 'range', [], 'type', 'single');
conf = mvpr_getargs(conf, varargin);

switch cT_
 case 'truecolor'
  img = mvpr_rgb2gray( img_ );
  if isa(img, 'uint8')
      bitdepth = 8;
  elseif isa(img, 'uint16')
      bitdepth = 16;
  elseif isa(img, 'double')
      bitdepth = 1;
  else
      error('rgb2gray returned unknown format');
  end
  
 case 'grayscale'
  img = img_;
  if isa(img_, 'uint8')
      bitdepth = 8;
  elseif isa(img_, 'uint16')
      bitdepth = 16;
  elseif isa(img_, 'double')
      bitdepth = 1;
  else
      error('Unknown bit depth for gray scale image');
  end
  
 case 'indexed'
  img = ind2gray_(img_, cmap);
  bitdepth = 8;
end

if isempty(conf.range)
    img = feval(conf.type, img_);
    return;
end

% Assume image values are in the range [0, (2^bitdepth)-1]
% rescale

range = conf.range(2) - conf.range(1);
factor = range / ( 2^bitdepth -1 );
img = double(img) .* factor + conf.range(1);
img = feval(conf.type, img);


% own implementation of ind2gray to get rid of imagetoolbox dependency
function img2=ind2gray_(img,cmap);

diu=mean(cmap');
img2=diu(img);
