%MVPR_IMTRANS - Homogenous transformation of an image.
%
% newim = mvpr_imtrans(img, T)
% newim = mvpr_imtrans(img, T, 'parameter', value...)
% [newim, newT] = mvpr_imtrans(...)
%
% Input:
%  img   - the image to be transformed
%  T     - 3x3 transformation matrix
%
% <Optional>
%  'inregion'  - region of input image to be transformed, default: whole image
%  'pxlimit'   - max number of pixels in the output image, default: 1 000 000
%  'outregion' - region of output image to be created, default: big enough
%  'outfmt'    - output data format: 'double' or 'uint8', default: 'uint8'
%  'interp'    - interpolation method, see interp2 function. Default: 'linear'
%
% Output:
%  'newim' - transformed image
%  'newT'  - transformation matrix corresponding to the new image
%
% By default the output image is as large as required for the whole
% transformed image to fit in it. The transformation introduces
% translation, so the 'newT' is returned for transforming
% from original image coordinates to transformed image coordinates directly.
%
% You can use 'outregion' to define just a subset of the output image,
% given in coordinates defined by transformation 'T'.
% 'outregion' always affects 'newT', and 'inregion' affects 'newT' if
% 'outregion' is empty (automatic).
%
% This function uses 'interp2' to do the work. Therefore the pixels in
% output image, that are off of the input image, will be NaN.
% 'interp2' also defaults to using linear interpolation.
%
% Regions are given as vector [minrow maxrow mincol maxcol].
%
% If 'pxlimit' is exceeded, error is thrown. This is to prevent
% memory hogging accidents.
%
% You can map coordinates from output image to input image
% using inverse transformation: R = inv(newT)
%
% *** Image Coordinate Reference:
%
%     0.5  1.0  1.5   X-coordinate, matrix columns ->
%           :
% 0.5  +----:----+---
%      |    :    |
%      |    :    |
% 1.0·······*    |
%      |         |
%      |         |
% 1.5  +---------+---
%      |         |
%
%  |  Y-coordinate, matrix rows
%  V
%
% The center of the top-left corner pixel is (1.0, 1.0),
% the top-left corner of the image is at (0.5, 0.5).
% evex_pttrans will return real numbers. If you need to convert them
% to matrix indices (integers), use round().
%
% Author(s):
%    Pekka Paalanen, MVPR in 2009.
%    Peter Kovesi
%      School of Computer Science & Software Engineering
%      The University of Western Australia
%      pk @ csse uwa edu au
%      http://www.csse.uwa.edu.au/~pk
%
% Project:
%  -
%
% Copyright:
%  -
%
% References:
%  -
%
% See also .
%
function [newim, newT] = mvpr_imtrans(im, T, varargin);

[rows cols depth] = size(im);

conf = struct(...
	'inregion', [1 rows 1 cols], ...
	'outregion', [], ...
	'pxlimit', 1000000, ...
	'outfmt', 'uint8', ...
	'interp', 'linear');

conf = mvpr_getargs(conf, varargin);

if isa(im,'uint8')
    im = double(im)./255;  % Make sure image is double     
end


threeD = (ndims(im)==3);  % A colour image
if threeD    % Transform red, green, blue components separately
	% ASSUMED: uint8 type
	[r, newT] = transformImage(im(:,:,1), T, ...
		conf.inregion, conf.outregion, conf.pxlimit, conf.interp);
	[g, newT] = transformImage(im(:,:,2), T, ...
		conf.inregion, conf.outregion, conf.pxlimit, conf.interp);
	[b, newT] = transformImage(im(:,:,3), T, ...
		conf.inregion, conf.outregion, conf.pxlimit, conf.interp);

	switch lower(conf.outfmt)
		case 'double'
			newim = repmat(0,[size(r),3]);
			newim(:,:,1) = r;
			newim(:,:,2) = g;
			newim(:,:,3) = b;
		case 'uint8'
			newim = repmat(uint8(0),[size(r),3]);
			newim(:,:,1) = uint8(round(r*255));
			newim(:,:,2) = uint8(round(g*255));
			newim(:,:,3) = uint8(round(b*255));
	end

else                % Assume the image is greyscale
	[newim, newT] = transformImage(im, T, ...
		conf.inregion, conf.outregion, conf.pxlimit, conf.interp);
end

%------------------------------------------------------------

% The internal function that does all the work

function [newim, newT] = transformImage(im, T, inreg, outreg, pixellimit, ...
                                        interpmethod);

% Cut the image down to the specified region
im = im(inreg(1):inreg(2), inreg(3):inreg(4));
[rows, cols] = size(im);

if isempty(outreg)
	% Find where corners go - this sets the bounds on the final image
	B = bounds(T,inreg);
else
	B = outreg;
end

nrows = B(2) - B(1) +1;
ncols = B(4) - B(3) +1;

Tinv = inv(T);

if (nrows*ncols) > pixellimit
	error(['Resulting ' num2str(ncols) 'x' num2str(nrows) ...
		' image is too big.']);
end

newT = T - [0 0 B(3)-1; 0 0 B(1)-1; 0 0 0];

% Set things up for the image transformation.
newim = zeros(nrows,ncols);
[xi,yi] = meshgrid((1:ncols)-1, (1:nrows)-1);    % All possible xy coords in the image.

% Transform these xy coords to determine where to interpolate values
% from. Note we have to work relative to x=B(3) and y=B(1).
%sxy = evex_pttrans(Tinv, [xi(:)'+B(3) ; yi(:)'+B(1) ; ones(1,ncols*nrows)]);
sxy = mvpr_h2d_trans([xi(:)'+B(3) ; yi(:)'+B(1) ; ones(1,ncols*nrows)],Tinv);
xi = reshape(sxy(1,:),nrows,ncols);
yi = reshape(sxy(2,:),nrows,ncols);

[x,y] = deal(1:cols,1:rows);
x = x+inreg(3)-1; % Offset x and y relative to region origin.
y = y+inreg(1)-1;
% Interpolate values from source image.
newim = interp2(x, y, double(im), xi, yi, interpmethod); 



%---------------------------------------------------------------------
%
% Internal function to find where the corners of a region, R
% defined by [minrow maxrow mincol maxcol] are transformed to 
% by transform T and returns the bounds, B in the form 
% [minrow maxrow mincol maxcol]

function B = bounds(T, R)

P = [R(3) R(4) R(4) R(3)      % homogeneous coords of region corners
     R(1) R(1) R(2) R(2)
      1    1    1    1   ];
     
%PT = round(evex_pttrans(T,P)); 
PT = round(mvpr_h2d_trans(P,T)); 

B = [min(PT(2,:)) max(PT(2,:)) min(PT(1,:)) max(PT(1,:))];
%      minrow          maxrow      mincol       maxcol  
