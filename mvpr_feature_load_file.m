function [F D FN] = mvpr_feature_load_file(imgFile, varargin)

conf = struct('tempDir', '.',...
	      'detector', 'sift',...
	      'descriptor', 'sift');
conf = mvpr_getargs(conf, varargin);	     

[imgDir imgName imgExt] = fileparts(imgFile);
% Load descriptors
featuresFile = [fullfile(conf.tempDir, imgDir, imgName)...
	            '.' conf.detector '.' conf.descriptor '.features.mat'];
load(featuresFile,'descriptors','frames');
F = frames;
D = descriptors;
FN = featuresFile;

end
