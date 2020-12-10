%RGB_TO_GRAY - Convert RGB image to gray scale
%
% gimg = rgb_to_gray(img)
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

function gim = rgb_to_gray(img);

% Don't ask where these came from.
T = [ 0.298936; 0.587043; 0.114021];

sz = size(img);
sz = sz([1 2]);

gim = reshape( reshape(img, prod(sz), 3) * T, sz);
