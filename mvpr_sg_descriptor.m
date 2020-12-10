%MVPR_SG_DESCRIPTOR Compute Simple Gabor local descriptors.
%
% [d,sgS] = mvpr_sg_descriptor(img_,x_,:)
%
% Compute local simple Gabor descriptors for the image img_ at the
% points x_ .
%
%
% Output:
%  d    - NxD descriptors of D dimensions for N points.
% sgS   - Simple Gabor bank, which can be reused for faster
%         computation.
%
% Input:
%  img_        - Gray level image to be processed.
%  x_          - Nx2 points in the image (use [] for the whole image).
%
%  <optional>
%  sgS            - Simple Gabor structure to be reused.
%  gabor_fmax     - Maximum (base) Gabor bank frequency [1,2]
%                   (typically in {1/20,1/30,1/40,1/50}, def. 1/20)
%  gabor_fnum     - Number of frequencies (typically in {3,4,6},
%                   def. 4) [1,2]
%  gabor_thetanum - Number of orientations (typically in {4,6,8},
%                   def. 6) [1,2] 
%  gabor_k_       - The frequency scaling factor - starting from the
%                   base frequency (typically in
%                   {sqrt(2),sqrt(3),sqrt(4)}, def. sqrt(3)) [1,2]
%  gabor_p       - Gabor filter envelope overlap [0,1] (def. 0.65) 
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
% See also MVPR_SG_DESCRIPTOR_MATCH.M and MVPR_SG_CREATEFILTERBANK.M .
%
function [d,sgS] = mvpr_sg_descriptor(img_,x_,varargin)

% 1. Parse input arguments
conf = struct('method','fs_hesaff+fs_sift',...
    'fs_harThres', 100, ...
    'fs_hesThres', 500, ... %500
    'fs_density', 100, ... %100
    'debugLevel', 0,...
    'vl_siftPeakThreshold', 0, ... %0
    'vl_siftEdgeThreshold', 10,... %10
    'vl_Levels', 3,...     %3
    'vl_denseStep', 10, ... %10
    'vl_denseSize', 10,...    %10
    'benchType', 'descriptor',...
    'sgS', [],...
    'gabor_fmax', 1/20,...
    'gabor_fnum', 4,...
    'gabor_thetanum', 6,...
    'gabor_k', sqrt(3),...
    'gabor_p', 0.65);

conf = mvpr_getargs(conf,varargin);
%
% 2. Construct a simple Gabor bank
effective_fmax = conf.gabor_fmax; % this would be problem if scale
                                   % shifts would appear!!!
if (isempty(conf.sgS))
    warning('off','sg_createfilterbank:largeDimensionFactor');
    sgS = mvpr_sg_createfilterbank(...
        size(img_),... %configS.imgSize*configS.trainScaleFact,...
        effective_fmax,... %conf.gabor_fmax,... %configS.gaborBankS.fmax/configS.trainScaleFact,...
        conf.gabor_fnum,...
        conf.gabor_thetanum,...
        'pf',0.9999,...
        'k',conf.gabor_k,...
        'p',conf.gabor_p);
    warning('on','sg_createfilterbank:largeDimensionFactor');
else
    sgS = conf.sgS;
end;


d = mvpr_sg_filterwithbank(img_,sgS,'points',x_);
d = mvpr_sg_resp2samplematrix(d,'normalize',1);
