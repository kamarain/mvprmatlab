% MVPR_FEATURE_EXTRACT_FILES File list version of the function.
%
% [ip,lf] = mvpr_feature_extract_files_new(imgListFile, varargin)
%
% Runs the wrapped function MVPR_FEATURE_EXTRACT.M for multiple
% images listed in imgListFile and stores the extracted interest
% regions and their descriptor under the name:
%
%  <image name>.<ipDetector>.<Descriptor>.mat
%
% under the temporary working directory ('tempDir') retaining paths.
%
% Inputs:
%  imgFile_ - A list of images, one per line, containing no white
%             spaces full path relative to 'imgDir'.
%
% Optional:
%  'imgDir'             Root directory for images (i.e. only relative
%                           paths given in imgListFile)
%                       Default: '/'
%
%  'featListFile'   Contains images and after that feature file
%                   name (Def. [] which is imgListFile_feats.ext
%                   storen under tempDir.
%  'tempDir'        Directory for temporary save items (e.g. extracted 
%                   descriptors (Def. 'TEMPWORK')
%  'debugLevel'         Debug level [0,1,2] (Def. 0)
%
% + all the optional configuration parameters accepted by the
%   MVPR_FEATURE_EXTRACT.M .
%
% Outputs:
%  featListFile - A file where images from which features were
%                 extracted are stored (you may need this in the
%                 next processing steps)
%  ip,lf - all extracted interest points (ip) and their descriptors
%          (lf). May require a lot of memory and thus returned only
%          on request.
%
% Examples:
%  -
%
% Authors:
%  Jukka Lankinen, MVPR
%  Ville Kangas, MVPR
%  Joni Kamarainen, MVPR
%
% Project:
%  -
%
% References:
%  -
%
function [featListFile,ip,lf] = mvpr_feature_extract_files_new(imgListFile, varargin)

% Parse input arguments
conf = struct('imgDir', '.',...
              'featListFile', [],...
              'tempDir', 'TEMPWORK',...
              'debugLevel', 0,...
	      'forceExtract', true,...
              'method', 'fs_hesaff+fs_sift'); % lower level arg
conf = mvpr_getargs(conf,varargin);

if isempty(conf.featListFile)
    [fpath fname fext] = fileparts(imgListFile);
    featListFile = fullfile(conf.tempDir,[fname '_feat' fext]);
end;

if (~isdir(conf.tempDir))
	mkdir(conf.tempDir);
end

fh_list = mvpr_lopen(featListFile,'write');

ip = {}; lf = {};

% Count entries
imgTot = mvpr_lcountentries(imgListFile);

timeTotalEstimated = 0;
timeTotalElapsed = 0;
timeElapsed = 0;

if conf.debugLevel > 0,
	fprintf('\rLocal feature extraction (%s)\n', conf.method);
end;

% Open image list file and extracted & store local image features
fh = mvpr_lopen(imgListFile, 'read');
timeElapsed = 0;
for imgInd = 1:imgTot
    timeTotalEstimated = (timeTotalElapsed / (imgInd-1)) * (imgTot-imgInd);
    if conf.debugLevel > 0,
        fprintf('\r  * Progress: %5d/%5d, ETA: %.1fs  ', imgInd, imgTot, ...
                timeElapsed/(imgInd-1)*(imgTot-imgInd+1));
    end;
    tic; % start timer
    filename = mvpr_lread(fh);
    [imgDir imgName imgExt] = fileparts(filename{1});
    
    featuresSaveFile = [fullfile(imgDir, imgName)...
                        '.' conf.method '.features.mat'];
    
    % Extract local feature if user wants to overwrite existing
    % local features or local feature does not exist yet
    if conf.forceExtract == true || ~exist(fullfile(conf.tempDir,featuresSaveFile), 'file')
        imgFile = fullfile(conf.imgDir, filename{1});
        
        % Extract features
        [frames descriptors] = ...
            mvpr_feature_extract_new(imgFile, ...
                                     'method', conf.method, ...
                                     'debugLevel',  conf.debugLevel);
        
        % Make destination directory in a case it does not exist
        if (isdir(fileparts(fullfile(conf.tempDir,featuresSaveFile))) == 0)
            mkdir(fileparts(fullfile(conf.tempDir,featuresSaveFile)));
        end
        
        % Save interest point and descriptor data
        save(fullfile(conf.tempDir,featuresSaveFile),...
             'frames', 'descriptors');
    else
        % Load old
        load(fullfile(conf.tempDir,featuresSaveFile), 'frames', 'descriptors');
    end
    
    % Store descriptors and frames if user wants to get them
    if nargout > 1,
        ip{imgInd} = frames;
        if nargout > 2,
            lf{imgInd} = descriptors;
        end;
    end;
    
    mvpr_lwrite(fh_list, [conf.imgDir ' ' filename{1} ' ' featuresSaveFile]);
    
    timeElapsed = timeElapsed+toc; % stop timer
end

mvpr_lclose(fh);
mvpr_lclose(fh_list);

if conf.debugLevel > 0,
    fprintf('\r  * Done! Total time %.2fs (%.2fs per file).  \n', ...
    timeElapsed, timeElapsed / imgTot);
end; % if debugLevel

end % function mvpr_feature_extract_files()
