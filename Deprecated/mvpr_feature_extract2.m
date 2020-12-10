% [F D] = MVPR_FEATURE_EXTRACT(IMG)
%
% [F D] = mvpr_feature_extract(img) will open image file img and extract the
%   features by using sift interest point detector. The user may change
%   Interest point detector and descriptor.
%   Most of the detectors require different binaries or toolboxes to work. 
%   Those can be acquired freely from the following locations:
%
%   VLFeat: http://www.vlfeat.org/ (sift, dsift, mser)
%   Compute_descriptors: http://www.featurespace.org (harlap, heslap, haraff,
%       hesaff, mser, harris, hessian, harmulti, hesmulti, harhes)
%   Vireo: http://www.cs.cityu.edu.hk/~wzhao2/lip-vireo.htm (*-vireo)
%   Other: http://www.robots.ox.ac.uk/~vgg/research/affine/detectors.html 
%       (haraff-alt, hesaff-alt, ebr, ibr, mser)
%
%   TODO / Limitations
%      * Acquire extractors automatically if not present. (get_extractors.m)
%      * MSER original implementation missing
%      * ibr/ebr/salient regions missing
%
% Optional:
%  'detector'           Interest point detector for feature extraction
%                           DoG (VLFeat)
%                               suffixes: -VLFeat -FeatureSpace, -Vireo
%                           MSER (VLFeat)
%                               suffixes: -Vireo
%                           Haraff (FeatureSpace)
%				suffixes: -FeatureSpace, -Vireo
%                           Hesaff (FeatureSpace)
%				suffixes: -FeatureSpace, -Vireo
%                           SURF (Surf)
%                               suffixes: -Surf
%                       Default: sift (VLFeat)
%
%  'descriptor'         Descriptor to use
%                           sift - sift descriptor (default: VLFeat)
%                               suffixes: -VLFeat -FeatureSpace
%                           gloh - gloh descriptor (default: FeatureSpace)
%                           surf - surf descriptor (default: Surf)
%                       Default: sift (VLFeat)
%
% Outputs:
%  F - Feature frames for localization and visualization of features
%  D - Unique feature descriptors for matching
%
% Examples:
%  [F D] = mvpr_feature_extract2(rgb2gray(I), 'detector', 'DoG-Vireo', ...
%                                            'descriptor', 'gloh-FeatureSpace');
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
function [F D] = mvpr_feature_extract(img, varargin)

% Parse input arguments
conf = struct('siftPeakThreshold', 0, ...
              'siftEdgeThreshold', 10, ...
              'detector', 'DoG', ...
              'descriptor', 'sift', ...
              'harrisThreshold', 100, ...
              'hessianThreshold', 200, ...
              'denseStep', 10, ...
              'denseSize', 10, ...
              'debugLevel', 0);
conf = mvpr_getargs(conf, varargin);


% Find toolbox path
filepath = which('mvpr_feature_extract');

binPath = fileparts(filepath);
binPath = fullfile(binPath, 'binaries');
tmpPath = tempdir;

% Determine default values

F = [];
D = [];
detector = 'DoG';
detector_implementation = 'VLFeat';

descriptor = 'sift';
descriptor_implementation = 'VLFeat';

% Determine detector
values = regexp(conf.detector, '-', 'split');

if size(values,2) == 2 % defined implementation
	detector = values{1};
	detector_implementation = values{2};
elseif size(values,2) == 1 % default
	detector = values{1};
	
	if strcmp(detector, 'DoG') == 1
		detector_implementation = 'VLFeat';
	elseif strcmp(detector, 'Haraff') == 1
		detector_implementation = 'FeatureSpace';
	elseif strcmp(detector, 'Hesaff') == 1
		detector_implementation = 'FeatureSpace';
	elseif strcmp(detector, 'SURF') == 1
		detector_implementation = 'Surf';
	elseif strcmp(detector, 'MSER') == 1
		detector_implementation = 'VLFeat';
	else
		error('Error');
	end			
end

% Determine descriptor
values = regexp(conf.descriptor, '-', 'split');

if size(values,2) == 2 % defined implementation
	descriptor = values{1};
	descriptor_implementation = values{2};
elseif size(values,2) == 1 % default
	descriptor = values{1};
	if strcmp(descriptor, 'sift') == 1
		descriptor_implementation = 'VLFeat';
	elseif strcmp(descriptor, 'gloh') == 1
		descriptor_implementation = 'FeatureSpace';
	elseif strcmp(descriptor, 'surf') == 1
		descriptor_implementation = 'Surf';
	else
		error('Error');
	end		
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run detector
switch detector
	case {'DoG'}
		if strcmp(detector_implementation, 'VLFeat') == 1	
			img2 = single(img);		
			[feat, D] = vl_sift(img2,...
		        'PeakThresh', conf.siftPeakThreshold, ...
		        'EdgeThresh', conf.siftEdgeThreshold);
			
		        if size(feat,1) == 4
		            len = size(feat,2);
		            % x,y,a,b,c,scale; because this is a circle, a == c and b == 0
		            %F = convertFeatures([ feat(1, :)' feat(2, :)' ones(len,1)...
		            %                     zeros(len,1) ones(len,1) feat(3, :)' ]);
			    F = convertFeatures([ feat(1, :)' feat(2, :)' ones(len,1)...
		                                 zeros(len,1) ones(len,1) feat(3, :)' ]);
		                  
		            F = F';
		            mvpr_feature_plot(img,F) 
		        else
		            F = feat;
		            F = F';
		        end
		elseif strcmp(detector_implementation, 'FeatureSpace') == 1
			[F D] = mvpr_feature_extract_featurespace(img, 'detector', 'dog');
		elseif strcmp(detector_implementation, 'Vireo') == 1
			[F D] = mvpr_feature_extract_vireo(img, 'detector', 'dog');
		else
			error(['Unsupported implementation']);
		end
		
			
	case {'Hesaff'}
		if strcmp(detector_implementation, 'FeatureSpace') == 1
			[F D] = mvpr_feature_extract_featurespace(img, 'detector', 'hesaff');
		elseif strcmp(detector_implementation, 'Vireo') == 1
			[F D] = mvpr_feature_extract_vireo(img, 'detector', 'hesslap', 'affine', true);
		else
			error(['Unsupported implementation']);			
		end		
	case {'Haraff'}
		if strcmp(detector_implementation, 'FeatureSpace') == 1
			[F D] = mvpr_feature_extract_featurespace(img, 'detector', 'haraff');
		elseif strcmp(detector_implementation, 'Vireo') == 1
			[F D] = mvpr_feature_extract_vireo(img, 'detector', 'harlap', 'affine', true);
		else
			error(['Unsupported implementation']);
		end			
	case {'MSER'}
		% TODO
		% TODO
		% TODO
	case {'SURF'}
		[F D] = mvpr_feature_extract_surf(img);
	otherwise
		error(['Unsupported interest-point descriptor: "' detector '"!']);
end % switch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run descriptor
% Do conversion if 
numFeatures = size(F,2);
%if strcmp(detector_implementation, descriptor_implementation) ~= 1
switch descriptor
	case 'sift'
		if strcmp(descriptor_implementation, 'VLFeat') == 1
			img2 = single(img);
			F = convertFeaturesVLSift(F);
			
			[feat, D] = vl_sift(img2,...
		        'PeakThresh', conf.siftPeakThreshold, ...
		        'EdgeThresh', conf.siftEdgeThreshold, ...
		        'frames', F);
			
		        if size(feat,1) == 4
		            len = size(feat,2);
		            % x,y,a,b,c,scale; because this is a circle, a == c and b == 0
		            F = convertFeatures([ feat(1, :)' feat(2, :)' ones(len,1)...
		                                 zeros(len,1) ones(len,1) feat(3, :)' ]);

		            F = F';
		        else
		            F = feat;
		            F = F';
		        end			
			
			
			%% STUB
		elseif strcmp(descriptor_implementation, 'FeatureSpace') == 1
			[F D] = mvpr_feature_extract_featurespace(img, 'features', F);
		elseif strcmp(descriptor_implementation, 'Vireo') == 1
			[F D] = mvpr_feature_extract_vireo(img, 'features', F);
		else
			error(['Unsupported descriptor implementation']);		
		end
		
	case 'gloh'
		[F D] = mvpr_feature_extract_featurespace(img, 'descriptor', 'gloh', 'features', F);
	case 'surf'
		[F D] = mvpr_feature_extract_surf(img, 'features', F);
	otherwise
		error(['Unsupported interest-point descriptor: "' conf.descriptor '"!']);
end % switch
%end % if

if numFeatures ~= size(F,2)
	warning(sprintf('Some features modified during conversion: %d -> %d', numFeatures, size(F,2) ));
end

end % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Additional functions                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [F] = convertFeatures(feat)

F = zeros(size(feat,1), 5);

for i=1:size(feat,1)

	Mi = [ feat(i, 3) feat(i, 4); feat(i, 4) feat(i, 5) ];

	[ v e ] = eig(Mi);

	e(1) = e(1) * feat(i, 6);
	e(4) = e(4) * feat(i, 6);

	e(1) = 1/(e(1)*e(1));
	e(4) = 1/(e(4)*e(4));

	Mi_s = v * e * inv(v); 

	F(i, :) = [ feat(i,1) feat(i,2) Mi_s(1,1) Mi_s(1,2) Mi_s(2,2) ];

end
end % function

function [F] = convertFeaturesVLSift(feat)
%F = zeros(size(feat,1), 3);
for l = 1:size(feat,2)
	a = feat(3,l);
	b = feat(4,l);
	c = feat(5,l);
	
	[v e] = eig([a b;b c]);
	
	l1 = 1/sqrt(e(1));
	l2 = 1/sqrt(e(4));

	F(1:2,l) = feat(1:2,l);


	F(3,l) = l1*v(1);
	F(4,l) = 0;
	%F(4,l) = l1*v(2);
	
	%F(5,l) = l2*v(3);
	%F(6,l) = l2*v(4);
end

end
