%MVPR_SG_DESCRIPTOR_DEMO Demonstrate Simple Gabor local descriptors.
%
% [] = mvpr_sg_descriptor_demo
%
% Demonstrates extraction and matching of Simple Gabor local region
% descriptors.
%
% Author(s):
%    Joni Kamarainen, TUT-SGN 2014
%
% Project:
%  Object3D2D
%
% Copyright:
%
%   Copyright (C) 2011 by Joni-Kristian Kamarainen.
%
% References:
%  [1] -
%
% See also MVPR_SG_DESCRIPTOR.M and MVPR_SG_DESCRIPTOR_MATCH.M .
%
clear all;
close all;
% Load test images
disp('[1] Reading an image');
img1 = double(imresize(rgb2gray(imread('resources/img1.ppm')),1/4))/255;
rotAngles = [0 1 2 4 8 16 32 64 128 256];
%% compute cov
%dd = [];
%randNum = 100;
%for ii = 1:10
%    x = [1+(size(img1,2)-1)*rand(randNum,1) 1+(size(img1,1)-1)*rand(randNum,1)];
%    d = sg_descriptor(img1,round(x),sgS);
%    dd = [dd; d];
%end;
%dd_mu = mean(dd,1);
%dd_cov = cov(dd);

randNum = 200;
x = [1+(size(img1,2)-1)*rand(randNum,1) 1+(size(img1,1)-1)*rand(randNum,1)];

d1 = mvpr_sg_descriptor(img1,round(x));

% rotate the image and see what happens to the matches
for rotAngle = rotAngles
    % rotate image
    H = mvpr_h2d_iso(rotAngle, [0 0]);
    [Himg Hnew] = mvpr_imtrans(img1,H);
    Himg(isnan(Himg)) = 0; % Non existing regions NaN => 0
    [xnew] = mvpr_h2d_trans(x',Hnew)';

    % compute descriptors and match
    [d2 sgS] = mvpr_sg_descriptor(Himg,round(xnew));
    m = mvpr_sg_descriptor_match(d1,d2,sgS);
    fprintf('Match percent %f\n',sum((m-[1:length(m)]) == 0)/length(m)*100);

    xs = size(img1,2)+1;
    comp_img = zeros(max([size(img1,1) size(Himg,1)]),size(img1,2)+size(Himg,2));
    comp_img(1:size(img1,1),1:size(img1,2)) = img1;
    comp_img(1:size(Himg,1),xs:end) = Himg;
    clf;
    imagesc(comp_img);

    
    %imagesc(Himg);
    hold on;
    colormap gray
    plot(x(:,1), x(:,2),'yo','MarkerSize',10,'LineWidth',2);
    plot(xs+xnew(:,1), xnew(:,2),'yo','MarkerSize',10,'LineWidth',2);
    for ii = 1:size(xnew,1)
        line([x(ii,1) xs+xnew(m(ii),1)],...
             [x(ii,2) xnew(m(ii),2)]);
    end;
    hold off;
    input('<RET>');
end;
