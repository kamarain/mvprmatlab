%MVPR_SUMIMG Sum up images to make an "average" image
%
% [simg] = mvpr_sumimg(simg_,img_,T,:)
%
% Sums the image img_ to the sum image simg_. The summing is done
% in the centroid of the both images, i.e. it is assumed that
% whatever is important it is in the middle of the image.
%
% Note: using the transformation T not implemented yet.
%
% Output:
%  simg - Sum image (used as input in the consequent calls).
%
% Input:
%  simg_  - Existing sum image.
%  img_   - Image to be added to the sum image.
%
%  <optional>
%'sumImgSize' - Size of the sum image (Def. [300 300])
%
% Author(s):
%    Jukka Lankinen, MVPR in 2012.
%    Joni Kamarainen, MVPR in 2012.
%
% Project:
%    Object3d2d
%
% Copyright:
%
%
% References:
%
%  [1] J. Lankinen and J.-K. Kamarainen, Local Feature Based
%  Unsupervised Alignment of Object Class Images, British Machine
%  Vision Conference (BMVC2011).
%
% See also .
%
function [simg] = mvpr_sumimg(simg_,img_,T,varargin);

% Parse input arguments
conf = struct('sumImgSize', [500 500 3]);
conf = mvpr_getargs(conf,varargin);

if isempty(T)
    T = diag([1 1 1]); % no transformation
end;

if isempty(simg_)
    simg = zeros(conf.sumImgSize); % initialise
    return;
end;

if (isempty(img_))
    error('No image to sum given!');
end;

if ndims(img_) == 2 % gray level image
  foo(:,:,1) = img_;
  foo(:,:,2) = img_;
  foo(:,:,3) = img_;
  img_ = foo;
end;


d = floor((size(simg_(:,:,1)) - size(img_(:,:,1))) / 2);

posX = 1;
posY = 1;

startX = 1;
startY = 1;

if d(1) > 0
    posY = d(1);
else
    startY = -d(1);
end
if d(2) > 0
    posX = d(2);
else
    startX = -d(2);
end
if posX == 0
    posX = 1;
end
if posY == 0
    posY = 1;
end
if startX == 0
    startX = 1;
end		
if startY == 0
    startY = 1;
end			
clippedImg = img_(startY:size(img_,1)-startY-1, startX:size(img_,2)-startX-1,:);
clippedImg = double(clippedImg);	

simg = simg_;
simg(posY:size(clippedImg,1)+posY-1, posX:size(clippedImg,2)+posX-1,:) = ...
    simg(posY:size(clippedImg,1)+posY-1, posX:size(clippedImg,2)+posX-1,:) + ...
    clippedImg;
