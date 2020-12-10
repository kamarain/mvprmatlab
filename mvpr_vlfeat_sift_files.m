%MVPR_VLFEAT_SIFT_FILES Detect and extract SIFT features
%                       (read images from file)
%
% [] = mvpr_vlfeat_sift_files(imgFile_,:) extracts SIFT features
% from all images in imgFile_ using the SIFT interest point/region
% detection method and SIFT interest region description.  Finally,
% the descriptors are stored in files
% <imgname_in_imgFile>_features.mat under the temporary working
% directory.
%
% NOTE: This function requires vlfeat (http://www.vlfeat.org) to be
% installed and available in the Matlab path (run vl_setup.m).
%
% Inputs:
%  imgFile_ - A list of images to be processed, one per line,
%             containing no white spaces (this cuts the name) and
%             with their full path (if 'imgDir' not specified).
%
% <Optional>
% 'tempSaveDir'    - Directory for temporary save items
%                    (e.g. extracted descriptors) (Def: '.')
% 'imgDir'         - Root directory for images (i.e. only relative
%                    paths given in imgFile_) (Def: '/')
% 'imgType'        - Usage type of loaded image:
%                     'colour'
%                     'graylevel' (Default)
% 'imread_type'    - Conversion data type for loaded image (see
%                    mvpr_imread) (Def. 'single').
% 'imread_range'   - Value range for loaded image (see mvpr_imread)
%                    (Def. [0 1]).
% 'extract'        - Boolean value that defines if user wants to
%                    to overwrite all existing local features. If
%                    extract = 1 then all existing local features
%                    will be overwritten (default). If extract = 0
%                    then existing local features will not be
%                    recomputed (faster for incremental work).
% <Optional/passed to mvpr_vlfeat_sift.m>
% 'vl_sift_PeakThresh' - SIFT peak treshold (Def: 0)
% 'vl_sift_EdgeThresh' - SIFT edge treshold (Def: 10)
% 'vl_imsmooth_sigma'  - Image Gaussian smoothing Sigma (Def: [],
%                        i.e. no smoothing)
% 'debugLevel'     - Debug level (Def: 0)
%
% Outputs:
%  lf - Matrix DxM for M D-dimensional local features (Note that
%       descriptors may return additional variables if available:
%       'sift'-'sift' : ipFrames also returned
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
% See also MVPR_VLFEAT_SIFT.M .
%
function [varargout] = mvpr_vlfeat_sift_files(imgFile_,varargin)

% Parse input arguments
conf = struct('vl_sift_PeakThresh', 0,...
              'vl_sift_EdgeThresh', 10,...
              'vl_imsmooth_sigma', [],...
              'useDense', false,...
              'tempSaveDir', '.',...
              'extract', 1, ...
              'imgDir', '/',...
              'imgType', 'graylevel',...
              'imread_type', 'single',...
              'imread_range', [0 1],...
              'debugLevel', 0);
conf = mvpr_getargs(conf,varargin);

% Count number of images
fh = mvpr_lopen(imgFile_, 'read');
filepair = mvpr_lread(fh);
imgTot = 0;
while ~isempty(filepair)
    imgTot = imgTot+1;
    filepair = mvpr_lread(fh);
end;
mvpr_lclose(fh);

% Load images, form and save descriptors
fh = mvpr_lopen(imgFile_, 'read');
for imgInd = 1:imgTot
    fprintf('\rLocal feature extraction (img#:%5d/%5d)', imgInd,imgTot);
    filepair = mvpr_lread(fh);
    [imgDir imgName imgExt] = fileparts(filepair{1}); % 2->1
    featSaveFile = [fullfile(conf.tempSaveDir,imgDir,imgName)...
                    '_features.mat'];

    % Extract local feature if user wants to overwrite existing
    % local features or local feature does not exist yet
    if conf.extract == 1 || ~exist(featSaveFile, 'file')
        switch conf.imgType,
         case 'graylevel',
          img = mvpr_imread(fullfile(conf.imgDir,filepair{1}),...
                            'range', conf.imread_range,...
                            'type', conf.imread_type);
         case 'colour',
          error('Image type ''colour'' not supported yet.');
         otherwise
          error('Unknown image type.');
        end;
        
        [lf siftFrames] = mvpr_vlfeat_sift(...
            img,...
            'vl_sift_PeakThresh', conf.vl_sift_PeakThresh,... 
            'vl_sift_EdgeThresh', conf.vl_sift_EdgeThresh,...
            'vl_imsmooth_sigma', conf.vl_imsmooth_sigma,...
            'useDense', conf.useDense,...
            'debugLevel', conf.debugLevel);

        % mkdir in a case it does not exist
        if (isdir(fileparts(featSaveFile)) == 0)
            mkdir(fileparts(featSaveFile));
        end;
        
        save(featSaveFile,'lf','siftFrames');
    end;
end;
mvpr_lclose(fh);
fprintf('...Done (features saved to temp dir)!\n');
