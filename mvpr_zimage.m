%MVPR_ZIMAGE - plot a height map over an image
%
% evex_zimage(img, zimg)
% evex_zimage(img, zimg, 'parameter', value...)
% h = evex_zimage(...)
%
%  'img'   - the underlaying image (if [], then just not plotted
%            under the zimg, can be used, for example, to print
%            gray scale images in different parts of any fig (used
%            to plot images on SOM maps for example))
%  'zimg'  - the height map, z-image
%  'h'     - figure handle
%
% Optional parameters
%  'pos'    - position of the heightmap corner pixels: top-left, bottom-right,
%             default: [] (covering the whole image)
%  'alpha'  - surface alpha level (translucency), default: 1.0
%  'figure' - figure handle to be used for drawing, default: [] (new figure)
%  'xmat'   - X-coordinates of the z-image points, matrix of size(zimg)
%  'ymat'   - Y-coordinates of the z-image points, matrix of size(zimg)
%
% 'img' can be a color or gray scale image, of type double
% (value range 0.0 - 1.0) or uint8 (range 0 - 255).
%
% If 'xmat' or 'ymat' are not defined, 'zimg' will be mapped onto the
% image by using 'pos' vector [x1, y1, x2, y2] where (x1,y1) is the top-left
% pixel center and (x2,y2) is the bottom-right pixel center coordinates.
%
% If 'alpha' < 1.0, some Matlab versions do not handle NaNs in 'zimg'
% correctly. NaN z-points will be fully transparent.
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
%
% Authors:
%  Pekka Paalanen, MVPR in 2009
%
% Project:
%  Evex
%
% References:
%
% See also MVPR_IMCONVERT.M .
%
function [h] = mvpr_zimage(img, zimg, varargin);

if (isempty(img))
    cols = 100;
    rows = 100;
else
    [rows cols depth] = size(img);
end;
[zrows zcols] = size(zimg);

conf = struct(...
	'figure', [], ...
	'alpha', 1.0, ...
	'pos', [1 1 cols rows], ...
	'xmat', [], ...
	'ymat', [] ...
	);
conf = getargs(conf, varargin);

% convert image to double, range [0.0 1.0]
if (~isempty(img))
    if isa(img,'uint8')
        img = double(img)./255;
    end
end;
    
% if xmat not defined, create from 'pos'
if isempty(conf.xmat)
	x_step = (conf.pos(3) - conf.pos(1)) / (zcols-1);
	conf.xmat = repmat( conf.pos(1):x_step:conf.pos(3), zrows, 1);
end

% if ymat not defined, create from 'pos'
if isempty(conf.ymat)
	y_step = (conf.pos(4) - conf.pos(2)) / (zrows-1);
	conf.ymat = repmat( (conf.pos(2):y_step:conf.pos(4))', 1, zcols);
end

% error checking
if [zrows zcols] ~= size(conf.xmat)
	error('''xmat'' size mismatch');
end
if [zrows zcols] ~= size(conf.ymat)
	error('''ymat'' size mismatch');
end


% if figure not defined, create a new one
if isempty(conf.figure)
	conf.figure = figure;
end

% convert gray image to RGB
if (~isempty(img))
    if depth == 1
	img = repmat(img, [1 1 3]);
	depth = 3;
    end
end;

% plot image
figure(conf.figure);  % FIXME: race condition. Using gca is Bad.
if (isempty(img) == false)
    image(img);
end;
hold_state = get(gca, 'NextPlot');
set(gca, 'NextPlot', 'add')

% replicate the z-image by 2x2
hei = reshape( repmat(1:zrows, 2, 1), 1, 2*zrows );
wid = reshape( repmat(1:zcols, 2, 1), 1, 2*zcols );
zimg = zimg(hei,wid);
clear hei, wid;

% compute corner coords for each z-pixel
xords = zeros(size(zimg));
yords = zeros(size(zimg));

df = (conf.xmat(:, 2:end) - conf.xmat(:, 1:(end-1)))./2;
dfd = df(:, [1 1:end]);
xords(1:2:end, 1:2:end) = conf.xmat - dfd;
xords(2:2:end, 1:2:end) = conf.xmat - dfd;
dfd = df(:, [1:end end]);
xords(1:2:end, 2:2:end) = conf.xmat + dfd;
xords(2:2:end, 2:2:end) = conf.xmat + dfd;

df = (conf.ymat(2:end, :) - conf.ymat(1:(end-1), :))./2;
dfd = df([1 1:end], :);
yords(1:2:end, 1:2:end) = conf.ymat - dfd;
yords(1:2:end, 2:2:end) = conf.ymat - dfd;
dfd = df([1:end end], :);
yords(2:2:end, 1:2:end) = conf.ymat + dfd;
yords(2:2:end, 2:2:end) = conf.ymat + dfd;

clear df, dfd;

% plot the z-pixels
surfhandle = surf( xords, yords, zimg );
set(surfhandle, 'edgeColor', 'none', 'FaceAlpha', conf.alpha);
%view(0, -90);
set(gca, 'NextPlot', hold_state)
