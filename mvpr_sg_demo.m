%MVPR_SG_DEMO Simple Gabor demo script
%
% Script, just type 'mvpr_sg_demo' in the Matlab prompt.
%
%
% Output:
%  -
%
% Input:
%  -
%
% Author(s):
%    Jarmo Ilonen, MVPR
%    Joni Kamarainen, MVPR
%
% Project:
%  SimpleGabor (http://www2.it.lut.fi/project/simplegabor/)
%
% Copyright:
%
%   Simple Gabor Toolbox (mvpr_sg_* ) is Copyright
%   (C) 2006-2010 by Jarmo Ilonen and Joni-Kristian Kamarainen.
%
% References:
%  [1] Ilonen, Jarmo, "Supervised local image feature detection",
%  PhD Thesis, Dept. of Information Technology, Lappeenranta
%  University of Technology, 2007.
%
% See also MVPR_SG_*.M .
%

%% VERSION NUMBER FUNCTION REMOVED
%% Display version number
%disp(['SimpleGabor Toolbox Version: ' sg_version]);

%
% Read and normalise image
fprintf('Reading an input image...');
img = imread('resources/trewas.jpg');
img = squeeze(img(:,:,1));
img = double(img)/255;
fprintf('Done!\n');

fh = figure;
colormap gray

%
% Create Gabor filter bank
fprintf('Creating Gabor filter bank with selected parameters...');
gaborBank = mvpr_sg_createfilterbank(size(img),1/4,3,4,'pf',0.9);
fprintf('Done!\n');

%
% Filter with the filter bank
fprintf('Filtering...');
fResp = mvpr_sg_filterwithbank(img,gaborBank);
fResp2 = mvpr_sg_filterwithbank2(img,gaborBank);
fprintf('Done!\n');

%
% Convert responses to simple 3-D matrix
fprintf('Convert responses to matrix form...');
fResp = mvpr_sg_resp2samplematrix(fResp);
fprintf('Done!\n');

%
% Normalise
fprintf('Normalise responses to reduce illumination effect...');
fResp = mvpr_sg_normalizesamplematrix(fResp);
fprintf('Done!\n');

%
% Display responses
fprintf('Displaying input image and responses...');
subplot(1,3,1);
imagesc(img);
axis off
title('Input');
for featInd = 1:size(fResp,3)
  subplot(1,3,2);
  imagesc(squeeze(real(fResp(:,:,featInd))));
  axis off
  title('Real');
  subplot(1,3,3);
  imagesc(squeeze(imag(fResp(:,:,featInd))));
  axis off
  title('Imaginary');
  input('<RETURN>');
end;
fprintf('Done!\n');

%
% Display scaled responses
fprintf('Displaying input image and the same but "unscaled" responses...');
subplot(1,3,1);
imagesc(img);
axis off;
title('Input');
for freqInd = 1:size(fResp2.freq,2)
  for orientInd = 1:size(fResp2.freq{1}.resp,1)
    subplot(1,3,2);
    imagesc(squeeze(real(fResp2.freq{freqInd}.resp(orientInd,:,:))));
    axis([1 size(img,1) 1 size(img,2)]);
    axis off
    title('Real');
    subplot(1,3,3);
    imagesc(squeeze(imag(fResp2.freq{freqInd}.resp(orientInd,:,:))));
    axis([1 size(img,1) 1 size(img,2)]);
    axis off
    title('Imaginary');
    input('<RETURN>');
  end;
end;
fprintf('Done!\n');

close(fh);
