%MVPR_RGB2GRAY - Convert RGB image to gray scale
%
% gimg = mvpr_rgb2gray(img)
%
% img   - input image of size N x M x 3, type double
% gimg  - output image of size N x M, type double
%
% Pixel value range is irrelevant.
% This function is not meant to be used for accurate results.

% Author:
%   Pekka Paalanen <pekka.paalanen@lut.fi>, 2004
%
% $Id: rgb_to_gray.m,v 1.2 2006/04/25 12:30:47 paalanen Exp $

function gim = mvpr_rgb2gray(img);

% Take class of the image so we can convert it back to the correct format
imgType = class( img );

if strcmp( imgType,'double' ) == 0,
	img = double( img );
end;

% Don't ask where these came from.
T = [ 0.298936; 0.587043; 0.114021];

sz = size(img);
sz = sz([1 2]);

gim = reshape( reshape(img, prod(sz), 3) * T, sz);

% Convert image back to the original format
switch imgType,
	case 'uint8',
		gim = uint8( gim );
	case 'uin16',
		gim = uint16( gim );
	case 'double',
		gim = double( gim );
	otherwise
		error('Unknown image dataformat: %s', imgType);
end;


