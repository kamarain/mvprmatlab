% MVPR_FEATURE_EXTRACT_FILES (IMGLISTFILE)
%
% mvpr_vlfeat_sift_files(imgListFile) extracts SIFT features
% from all images in imgListFile using the desired interest point/region
% detection method. Finally, the descriptors are stored in files
% <image name>.<ipDetector>.<Descriptor>.mat under the temporary working 
% directory.
%
% Inputs:
%  imgFile_ - A list of images to be processed, one per line,
%             containing no white spaces (this cuts the name) and
%             with their full path (if 'imgDir' not specified).
%
% Optional:
%  'imgDir'             Root directory for images (i.e. only relative
%                           paths given in imgListFile)
%                       Default: '/'
%
%  'tempDir'        Directory for temporary save items (e.g. extracted 
%                           descriptors)
%                       Default: '/'
%
%  'detector'           Interest point detector for feature extraction
%                           harris - harris detector
%                           hessian - hessian detector
%                           harmulti - multi-scale harris detector
%                           hesmulti - multi-scale hessian detector
%                           harhesmulti - multi-scale harris-hessian detector
%                           harlap - harris-laplace detector
%                           heslap - hessian-laplace detector
%                           dog | sift - DoG detector
%                           mser   - mser detector
%                           haraff - harris-affine detector
%                           hesaff - hessian-affine detector
%                           harhes - harris-hessian-laplace detector     
%                           dense | dsift - dense sampling
%                           haraff-alt - alternative harris-affine detector
%                                        implementation
%                           hesaff-alt - alternative hessian-affine detector
%                                        implementation
%                           ebr - edge-based region detector
%                           ibr - intensity extrema -based region detector
%                       Default: sift
%
%  'descriptor'         Descriptor to use
%                           sift - sift descriptor
%                           gloh - gloh
%                       Default: sift
%
%  'debugLevel'         Debug level [0,1,2]
%                       Default: 0
%
%  'harrisThreshold'    Harris threshold, when 'detector' is 'haraff'
%                       Default: 100
%
%  'hessianThreshold'   Hessian threshold, when 'detector' is 'hesaff'
%                       Default: 200
%
%  'denseStep'          Step size in dense sampling
%                       Default: 10
%
%  'denseSize'          Size of the extracted local feature in dense sampling
%                       Default: 10
%
%  'forceExtract'       Force feature extraction. Do not load temporary files
%                       Default: true
%
% Outputs:
%
% Examples:
%  -
%
% Authors:
%  Jukka Lankinen
%  Ville Kangas
%
% Project:
%  -
%
% References:
%  -
%
% DEPRECATES functions using solely VL_FEAT
%   mvpr_vlfeat_sift_files and mvpr_vlfeat_sift
%
function [ip,lf] = mvpr_feature_extract_files(imgListFile, varargin)

% Parse input arguments
conf = struct('tempDir', tempdir(),...
	      'imgDir', '.',...
	      'debugLevel', 0,...
	      'detector', 'sift',...
	      'descriptor', 'sift',...
              'harrisThreshold', 100,...
              'hessianThreshold', 200,...
              'denseStep', 10, ...
              'denseSize', 10, ...
	      'forceExtract', true);
	      
conf = mvpr_getargs(conf,varargin);

ip = {}; lf = {};

% Count entries
imgTot = mvpr_lcountentries(imgListFile);

timeTotalEstimated = 0;
timeTotalElapsed = 0;
timeElapsed = 0;

if exist(conf.tempDir) == 0
	mkdir(conf.tempDir);
end
if conf.debugLevel > 0,
	fprintf('\rLocal feature extraction (%s)\n', conf.detector);
end;
% Open image list file and create sift features
fh = mvpr_lopen(imgListFile, 'read');
for imgInd = 1:imgTot
	timeTotalEstimated = (timeTotalElapsed / (imgInd-1)) * (imgTot-imgInd);
	if conf.debugLevel > 0,
		fprintf('\r  * Progress: %5d/%5d, ETA: %.1fs  ', imgInd, imgTot, timeTotalEstimated);
	end;
	tic;
	filename = mvpr_lread(fh);
	[imgDir imgName imgExt] = fileparts(filename{1});
	
	featuresSaveFile = [fullfile(conf.tempDir, imgDir, imgName)...
	            '.' conf.detector '.' conf.descriptor '.features.mat'];
	
	% Extract local feature if user wants to overwrite existing
	% local features or local feature does not exist yet
	if conf.forceExtract == true || ~exist(featuresSaveFile, 'file')
		% Read image
		img = mvpr_imread(fullfile(conf.imgDir, filename{1}),'range', [0 1]);

		% Extract features
		[frames descriptors] = mvpr_feature_extract(img, ...
		                       'detector', conf.detector, ...
		                       'descriptor', conf.descriptor, ...
                                       'harrisThreshold', conf.harrisThreshold, ...
                                       'hessianThreshold', conf.hessianThreshold);

		% Make destination directory in a case it does not exist
		if (isdir(fileparts(featuresSaveFile)) == 0)
			mkdir(fileparts(featuresSaveFile));
		end

		% Save interest point and descriptor data
		save(featuresSaveFile, 'frames', 'descriptors');
	else
		% Load old
		load(featuresSaveFile, 'frames', 'descriptors');
	end

	% Store descriptors and frames if user wants to get them
	if nargout > 0,
		ip{imgInd} = frames;
		if nargout > 1,
			lf{imgInd} = descriptors;
		end;
	end;

	timeElapsed = toc;
	timeTotalElapsed = timeTotalElapsed + timeElapsed;
end

% Close image list file
mvpr_lclose(fh);
if conf.debugLevel > 0,
	fprintf('\r  * Done! Total time elapsed: %.2fs, %.2fs per file.  \n', ...
        	timeTotalElapsed, timeTotalElapsed / imgTot);
end; % if debugLevel

end % function mvpr_feature_extract_files()
