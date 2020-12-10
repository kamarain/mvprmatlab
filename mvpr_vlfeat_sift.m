%MVPR_VLFEAT_SIFT Detect and extract SIFT features
%
% [lf :] = mvpr_vlfeat_sift(img_,:) extracts SIFT features from img_
% using the SIFT interest point/region detection method and SIFT
% interest region description.  
%
% NOTE: This function requires vlfeat (http://www.vlfeat.org) to be
% installed and available in the Matlab path (run vl_setup.m).
%
% Inputs:
%  img_ - Image (Note that different detectors/descriptors may
%         prefer different formats
%         (colour/gray/single/normalised([0,1]), etc.)) - warnings
%         produced in case reformations applied!
%
% <Optional>
% 'vl_sift_PeakThresh' - SIFT peak treshold (Def: 0)
% 'vl_sift_EdgeThresh' - SIFT edge treshold (Def: 10)
% 'vl_imsmooth_sigma'  - Image Gaussian smoothing Sigma (Def: [],
%                        i.e. no smoothing)
% 'useDense'           - Use dense histogram of gradients descriptors for image
%                        vl_sift_PeakThresh and vl_sift_EdgeThresh are ignored
% 'debugLevel'     - Debug level (Def: 0)
%
% Outputs:
%  lf         - Matrix DxM for M D-dimensional local features.
%  siftFrames - (varargout{1}) if requested
%
% Authors:
%  Teemu Kinnunen, MVPR in 2009
%  Joni Kamarainen, MVPR in 2009
%
% Project:
%  VisiQ (http://www.it.lut.fi/project/visiq)
%
% References:
%
% [1] Kinnunen, T., Unsupervised Visual Object Categorization, PhD
% thesis, Lappeenranta University of Technology, XXXX.
%
% [2] http://www.vlfeat.org
%
% See also MVPR_VLFEAT_SIFT_FILES.M, VL_SIFT.M, VL_IMSMOOTH.M and
% VL_PLOTFRAME.M .
%
function [lf varargout] = mvpr_vlfeat_sift(img_,varargin)

if (exist('vl_sift') == 0)
    error(['No vlfeat (http://www.vlfeat.org) functions '...
           'in the currect Matlab path!'])
end;

% Parse input arguments
conf = struct('vl_sift_PeakThresh', 0,...
              'vl_sift_EdgeThresh', 10,...
              'vl_imsmooth_sigma', [],...
              'scale', [],...
              'useDense', false,...
              'debugLevel', 0);
conf = mvpr_getargs(conf,varargin);

if (ndims(img_) > 2)
    warning('Assuming RGB image and converting to gray.')
    img = rgb2gray(img_);
else
    img = img_;
end;
imgMax = max(img(:));
if (imgMax > 1)
    warning('Image needs to be normalised to [0,1].')
    img = img/imgMax; % normalisation [0,1]
end;
    
if (isempty(conf.vl_imsmooth_sigma) == false)
    img = vl_imsmooth(img,conf.vl_imsmooth_sigma);
end;
if conf.useDense
[siftFrames,lf] = vl_dsift(single(img),'step', 10,'size',10);
else
[siftFrames,lf] = vl_sift(single(img), ...
                        'PeakThresh', conf.vl_sift_PeakThresh, ...
                        'EdgeThresh', conf.vl_sift_EdgeThresh);
end
if (nargout >= 2)
        varargout{1} = siftFrames;
end;

%%%%% DEBUG [0] %%%%
if (conf.debugLevel > 0)
    cla reset;
    set(gcf,'DoubleBuffer','on');
    imshow(img);
    vl_plotframe(siftFrames);
    drawnow;
end;
%%%%%%%%%%%%%%%%%%%%
