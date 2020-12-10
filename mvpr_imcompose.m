%MVPR_IMCOMPOSE Compose given image to a larger image
%
%newimg = composeimg(sz_, orig_, img_, T_, varargin) produces a new
% image newimg which is "a view" to original img_ seen after the
% linear transform (see mvpr_h2d_*). The size of the new image is
% sz_ and its origin is orig_ (typically you give coordinates of
% the center pixels). For example, if you have a set of images and
% their transforms (T) to some standard pose, then you can use this
% function to map all of them to the same space (pose) and, for
% example, calculate their average. T is the mapping from the
% standard pose to the image (_not_ vice versa), because you must
% consider T here as a "new view" to img_ .
%
% Input:
%  sz_   - Size of the new image [height width]
%  orig_ - Origin position of the new image (img_ origin is
%          considered to be in its center).
%  img_  - Image to be processed.
%  T_    - 3x3 transformation matrix.
%
% <Optional>
%  'magn'  - Image magnification (resizes newimg).
%
% Output:
%  'newim' - transformed image
%
% Author(s):
%    Pekka Paalanen, MVPR in 2009.
%
% Project:
%  Probably RTMosaic
%
% Copyright:
%  -
%
% References:
%  -
%
% See also .
%
function newimg = mvpr_imcompose(sz_, orig_, img_, T_, varargin);

conf = struct( 'magn', 1,...
               'centered', false);
conf = mvpr_getargs(conf, varargin);

hei = round(sz_(1)*conf.magn);
wid = round(sz_(2)*conf.magn);

%newimg = ones(hei, wid, sz(3)).*NaN;
newimg = ones(hei, wid, size(img_,3)).*NaN;

% Compute coordinates of newimg (not that here origin is at the
% centre of the upper left pixel)
[XX, YY] = meshgrid( ((1:wid)-0.5)./conf.magn+0.5, ...
                     ((1:hei)-0.5)./conf.magn+0.5 );
pts = [XX(:)'; YY(:)'];
clear XX YY

%switch class(img_)
% case 'uint8'
%  img_ = double(img_)./255;
%  %img = img + randn(size(img)).*0.02;
%  %img(img<0) = 0;
%  %img(img>1) = 1;
% otherwise
%  error(['Unknown image class ' class(img_)]);
%end

[psy, psx, pch] = size(img_);
%fpts = evex_pttrans(M{nr}.noisyT, pts);
if conf.centered == true
	pts(1,:) = pts(1,:) - psx/2;
	pts(2,:) = pts(2,:) - psy/2;
end
fpts = mvpr_h2d_trans(pts,T_);
if conf.centered == true
	fpts(1,:) = fpts(1,:) + psx/2;
	fpts(2,:) = fpts(2,:) + psy/2;
end
x_coordmat = reshape(fpts(1,:), hei, wid);
y_coordmat = reshape(fpts(2,:), hei, wid);
for ch = 1:pch;
  plane = interp2(img_(:,:,ch), ...
                  x_coordmat, y_coordmat, '*nearest');
  mask = ~isnan(plane);
  tmpimg = newimg(:,:,ch);
  tmpimg(mask) = plane(mask);
  newimg(:,:,ch) = tmpimg;
end
