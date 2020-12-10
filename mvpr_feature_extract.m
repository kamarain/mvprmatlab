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
%   Binaries are sought under <MVPRMATLAB>/binaries/ 
%
%   You may use get_descriptors function to automatically acquire detectors!
%   (TODO)
%
% Optional:
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
%                           dog-vireo - DoG detector (vireo implementation)
%                           hesslap-vireo - hessian-laplace detector
%                           harlap-vireo - harris-laplace detector
%                           log-vireo - LoG detector
%                           ykpca-vireo - PCA detector
%                       Default: sift (VLfeat)
%
%  'descriptor'         Descriptor to use
%                           sift - sift descriptor
%                           gloh - gloh (not available for every detector)
%                       Default: sift
%
%  'siftPeakThreshold'  Peak threshold for Sift interest point detector
%                       Default: 0
%
%  'siftEdgeThreshold'  Edge threshold for Sift interest point detector
%                       Default: 10
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
% Outputs:
%  F - Feature frames for localization and visualization of features
%  D - Unique feature descriptors for matching
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
function [F D] = mvpr_feature_extract(img, varargin)

% Parse input arguments
conf = struct('siftPeakThreshold', 0, ...
              'siftEdgeThreshold', 10, ...
              'detector', 'sift', ...
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

switch conf.detector
	case {'brief'}
		% define files
		if (isstr(img))
			imgFile = img;
		else
			imgFile = [tempname '.png']; % needs to be saved first
			imwrite(img,imgFile);
		end
		
		featureFile = [imgFile '.cv_surf.cv_surf'];

		% Define binaries with paths
		switch computer
			case 'GLNX86' % 32-bit
				binary = fullfile(binPath, ['opencv_descriptors.sh']);
			case 'GLNXA64' % 64-bit
				binary = fullfile(binPath, ['opencv_descriptors.sh']);
			otherwise
				error('This architecture is not supported by the OpenCV binaries.')
		end

		optArgs = '';
		%optArgs = [ ' -hesThres ' num2str(conf.fs_hesThres) ];

		command = [binary ' -d ORB -s BRIEF ' optArgs ' -i ' imgFile ' -p ' featureFile ' -V 0'];
		[s r] = system(command);

		if (s) % Something wrong with the binary (e.g. +x missing ;)
			error(['Binary execution ''' command ''' failed ' ...
			'with output: ' r]);
		end;
		[D, feat, d, n] = readOpenCVFeaturesFile(featureFile);	
		% Convert circles to same ellipse format that other detectors output
		feat = feat';
		
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

		D = D';
		if (~isstr(img))
			% Delete temporary file
			delete(imgFile);
		end
		delete(featureFile);


	%
	%% VLFeat
	case {'sift'}
		img = single(img);
		if ~exist('vl_sift')
			error('VLFEAT not found!')
		end
		[feat, D] = vl_sift(img, ...
		        'PeakThresh', conf.siftPeakThreshold, ...
		        'EdgeThresh', conf.siftEdgeThreshold);

                % Convert circles to same ellipse format that other detectors output
                if size(feat,1) == 4
                    len = size(feat,2);
                    % x,y,a,b,c,scale; because this is a circle, a == c and b == 0
                    F = convertFeatures([ feat(1, :)' feat(2, :)' ones(len,1)...
                                         zeros(len,1) ones(len,1) feat(3, :)' ]);
                    F = F';
                else
                    F = feat;
                    F = F';
                end;

	case {'dense', 'dsift'}
		if size(img,3) == 3,
			img = rgb2gray(img);
		end;
		img = single(img);
		if ~exist('vl_dsift')
			error('VLFEAT not found!')
		end
		[F, D] = vl_dsift(img, 'step', conf.denseStep, 'size', conf.denseSize);

		% Convert frames into featurespace format
%		F=transp(convertFeatures(transp([F; ...
%                                          ones(1,size(F,2)); ...
%                                          zeros(1,size(F,2)); ...
%                                          ones(1,size(F,2)); ...
%                                          conf.denseSize*ones(1,size(F,2))])));
                F=[F;ones(1,size(F,2)); zeros(1,size(F,2)); ones(1,size(F,2)); ones(1,size(F,2))*conf.denseSize];

	%
	%% Compute_descriptors
	case {'harlap','heslap','haraff','hesaff', 'mser', 'harris', ...
	      'hessian', 'harmulti', 'hesmulti', 'harhes', 'dog'}

		% define files
		imgFile = [tempname '.png'];
		featureFile = [imgFile '.' conf.detector '.' conf.descriptor];
		
		% Define binaries with paths
		switch computer
			case 'GLNX86' % 32-bit
				binary = fullfile(binPath, ['compute_descriptors_32bit.ln']);
			case 'GLNXA64' % 64-bit
				binary = fullfile(binPath, ['compute_descriptors_64bit.ln']);
			otherwise
				error('Not supported')
		end
		if ~exist(binary)
			error('compute_descriptors not found. Download from http://www.featurespace.org and install under <MVPRMATLAB>/binaries/!')
		end	
			
		% write temp files
		imwrite(img, imgFile);
		% For some detectors it's possible to set additional parameters
		optArgs = '';
		if strcmp(conf.detector, 'haraff') == 1
			optArgs = [ ' -harThres ' num2str(conf.harrisThreshold) ];
		elseif strcmp(conf.detector, 'hesaff') == 1
			optArgs = [ ' -hesThres ' num2str(conf.hessianThreshold) ];
		end

		command = [binary ' -' conf.detector ' -' conf.descriptor optArgs ' -i ' imgFile ' -o1 ' featureFile];
		[s r] = system(command);
                
		if (s) % Something wrong with the binary (e.g. +x missing ;)
                  error(['Binary execution ''' command ''' failed ' ...
                         'with output: ' r]);
                end;
		if conf.descriptor(1) == 'g'
			[D, F, d, n] = readLocalFeatureFile([featureFile '.gloh']);
		else
			[D, F, d, n] = readLocalFeatureFile(featureFile);		
		end

		F = F';
		D = D';

		% Delete temporary file
		delete(imgFile);
		if conf.descriptor(1) == 'g'
			delete([featureFile '.gloh']);
		else
			delete(featureFile);
		end
		
	%
	%% VIREO
	case {'hesslap-vireo', 'harlap-vireo', 'dog-vireo', 'log-vireo', 'ykpca-vireo'}
		% define files
		tmpName = tempname;
		imgFile = [tmpName '.jpg'];
		framesFile = [tmpName '.keys'];
		descriptorsFile = [tmpName '.pkeys'];
		confFile = fullfile(tmpPath, 'lip-vireo-conf.tmp');
				
		% Define binary
		binary = fullfile(binPath, ['lip-vireo.sh']);
		if ~exist(binary)
			error('Lip-vireo binary not found! Download from: http://www.cs.cityu.edu.hk/~wzhao2/lip-vireo.htm!');
		end
		
		imwrite(img, imgFile);		
		% Drop '-vireo' suffix
		detector = conf.detector(1:numel(conf.detector)-6);
		descriptor = conf.descriptor(1:numel(conf.descriptor)-6);
		%switch conf.descriptor
		%	case { 'sift-vireo', 'spin-vireo', 'ljet-vireo', 'erift-vireo' }
		%		% Drop '-vireo' suffix
		%		descriptor = conf.descriptor(1:numel(conf.descriptor)-6);
		%	otherwise
		%		error (['Only descriptors sift-vireo, spin-vireo, ' ...
		%		'ljet-vireo and erift-vireo are available when ' ...
		%		'detector ' conf.detector ' is used!']);
		%end

		% Wrote temporary config file for lip-vireo
		h = fopen(confFile, 'w');
		fprintf(h, 'topk=500\n');
		fprintf(h, 'affine=yes\n');
		fprintf(h, 'scale=yes\n');
		fprintf(h, 'angle=yes\n');
		fclose(h);
		
		% Run binary
		command = [binary ' -img ' imgFile ' -d ' detector ' -p ' descriptor ' -kpdir ' tmpPath ' -dsdir ' tmpPath ' -c ' confFile]

		[s r] = system(command);

		if s ~= 0
			error(['Running lip-vireo failed: ' r]);
		end

		[F n] = readLocalVireoPointsFile(framesFile);
		[D d] = readLocalVireoDescriptorsFile(descriptorsFile);

		% Convert features to scaled representation
		F = convertFeatures(F);

		F = F';
		D = D';
		
		% Clean up
		delete(framesFile);
		delete(descriptorsFile);
		delete(imgFile);
	%
	% SURF!
	case 'surf'
		imgFile = [tempname '.pgm'];
		featureFile = [tmpPath 'temp.png.surf.surf'];
		binary = fullfile(binPath, ['surf.ln']);
		if ~exist(binary)
			error('SURF binary not found! Download from: http://www.vision.ee.ethz.ch/~surf/');
		end
		
		imwrite(img, imgFile);
		command = [binary ' -i ' imgFile ' -o ' featureFile];
	
		[s r] = system(command);

		if s ~= 0
			error(['Running SURF failed: ' r]);
		end
		if strcmp(conf.descriptor,'surf')
			featureFile = fullfile(tmpPath,'temp.png.surf.surf');
		else
			% Copy image in jpeg format so featurespace will accept it
			delete(imgFile);
			imgFile = fullfile(tmpPath,'temp.jpeg');
			imwrite(img,imgFile);
			% Define binaries with paths
	                switch computer
                	        case 'GLNX86' % 32-bit
        	                        binary = fullfile(binPath, ['compute_descriptors_32bit.ln']);
	                        case 'GLNXA64' % 64-bit
                        	        binary = fullfile(binPath, ['compute_descriptors_64bit.ln']);
                	        otherwise
        	                        error('Not supported')
	                end
			% Extract detected interest points
			command = [binary ' -p1 ' featureFile ' -' conf.descriptor ' -i ' imgFile ' -o1 ' featureFile];
	                [s r] = system(command);
                        if (s) % Something wrong with the binary (e.g. +x missing ;)
                          error(['Binary execution ''' command ''' failed ' ...
                                 'with output: ' r]);
                        end;

		end;
		[D, F, d, n] = readLocalFeatureFileDouble(featureFile);

		D = D';
		F = F';
		
		% clean up
		delete(imgFile);
		delete(featureFile);
	case {'haraff-alt', 'hesaff-alt'}
		imgFile = [tempname '.png'];
		featureFile = [imgFile '.' conf.detector '.' conf.descriptor];

		binary = fullfile(binPath, ['h_affine.ln']);
		
		if ~exist(binary)
			error(['h_affine.ln not found. Download from http://www.robots.ox.ac.uk/~vgg/research/affine/detectors.html']);
		end
		if strcmp (computer, 'GLNX86') ~= 1
			error ('Only 32-bit binaries for haraff-alt and hesaff-alt are available.');
		end
			
		imwrite(img, imgFile);
		if strcmp(conf.detector, 'haraff-alt') == 1
			detector = 'haraff';
			optArgs = [ ' -thres ' num2str(conf.harrisThreshold) ];
		else
			detector = 'hesaff';
			optArgs = [ ' -thres ' num2str(conf.hessianThreshold) ];
		end

		[ s r ] = system([ binary ' -' detector ' -i ' imgPath optArgs ]);
		if (s) % Something wrong with the binary (e.g. +x missing ;)
                  error(['Binary execution ''' command ''' failed ' ...
                         'with output: ' r]);
                end;

		[D, F, d, n] = readLocalFeatureFile(['temp.png.' detector '.' conf.descriptor]);

		D = D';
		F = F';

	case {'ibr', 'ebr' }
		imgFile = [tempname '.png'];
		featureFile = [imgFile '.' conf.detector];
				
		if strcmp(conf.detector, 'ibr') == 1
			binary = fullfile(binPath, ['ibr.ln']);
			imwrite(img, imgFile);
		else
			% Binary detector only works when image width and height are 
			% more than 300 px, so if the image is smaller we will add
			% padding to the image.
			% Note that some extra features may be found because of this 
			% operation!
			binary = fullfile(binPath, ['ebr.ln']);
			h = size(img,1);
			w = size(img,2);

			if h <= 300 
				img = [ img; zeros(301-h, w) ];
				h = size(img,1);
			end
			
			if w <= 300
				img = [ img zeros(h, 301-w) ];
			end

			imwrite(img, imgFile);
		end

		

		if ~exist(binary)
			error([ binary ' not found. Download from '... 
			'http://www.robots.ox.ac.uk/~vgg/research/affine/detectors.html']);
		end

		if strcmp(computer, 'GLNX86') ~= 1
			error ('Only 32-bit binaries are available for ebr and ibr detectors.');
		end

		[ s r ] = system([ binary ' ' imgFile ' ' featureFile ]);
		if (s) % Something wrong with the binary (e.g. +x missing ;)
                  error(['Binary execution ''' command ''' failed ' ...
                         'with output: ' r]);
                end;

		if strcmp(binary, 'ibr.ln') & s ~= 1 
			warning(['Error occurred while processing file: '    ]);
		elseif strcmp(binary, 'ebr.ln') & s ~= 0
			warning(['Error occurred while processing file: '    ]);
		end


		[D, F, d, n] = readLocalFeatureFile(featureFile);

		D = D';
		F = F';

	otherwise
		error(['Unsupported interest-point detector: "' conf.detector '"!']);
end % switch

end


function [lf, ip, d, N] = readLocalFeatureFile(filename)
% [lf,ip,d,N] = readLocalFeatureFile(filename)

% Open local feature file for reading
fp = fopen(filename,'r');
if fp == -1
	warning('Could not open the file: %s', filename);
	lf = uint8( zeros(0,128) );
	ip = zeros(0,5);
	d = 128;
	N = 0;
	return;
end

% Get dimensions of the local feature (descriptor)
line = fgetl(fp);
d = str2num(line);

% Get number of the local features
line = fgetl(fp);
N = str2num(line);

% Get local features and store them in the lf matrix
lf = uint8(zeros(N,d));
ip = zeros(N,5);
for i=1:N
	line = fgetl(fp);
	values = str2num(line);
	lf(i,:) = uint8(values(end-d+1:end));
	ip(i,:) = values(1:5);
end

% Finally, close the file
fclose(fp);
end

function [lf, ip, d, N] = readLocalFeatureFileDouble(filename)
% [lf,ip,d,N] = readLocalFeatureFile(filename)

% Open local feature file for reading
fp = fopen(filename,'r');
if fp == -1
	warning('Could not open the file: %s', filename);
	lf = zeros(0,128);
	ip = zeros(0,5);
	return;
end

% Get dimensions of the local feature (descriptor)
line = fgetl(fp);
d = str2num(line);

% Get number of the local features
line = fgetl(fp);
N = str2num(line);

% Get local features and store them in the lf matrix
lf = double(zeros(N,d));
ip = zeros(N,5);
for i=1:N
	line = fgetl(fp);
	values = str2num(line);
	lf(i,:) = double(values(end-d+1:end));
	ip(i,:) = values(1:5);
end

% Finally, close the file
fclose(fp);
end



% [lf,ip,d,N] = readLocalFeatureFile(filename)

% Lip-vireo uses representation in which ellipses have their shape (a,b,c) 
% and scaling factor. Here we convert that to a form in we have only
% coefficients a,b,c in the correct scale.
%
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


end % convertFeatures


% Lip-vireo uses a specific descriptor file format that we need to
% interpret to be able to pass descriptors on. 
% This function reads descriptors from a file and returns
% them in "normal form".

function [lf, d] = readLocalVireoDescriptorsFile(filename)

fp = fopen(filename,'r');
if fp == -1
	warning('Could not open the file: %s', filename);
	lf = zeros(0,128);
	d = 0;
	return;
end

% Get number of lines and number of items in each line
line = fgetl(fp);
a = str2num(line);

N  = a(1); % number of descriptors in the file
nm = a(2); % number of affiliated properties(x,y,scale,dominant orientation)
d  = a(3); % dimension of the feature vector

lf = zeros(N, d);

for i=1:N
	% Read affiliated properties (there should be nm properties for each feature)
	[ values n ] = fscanf(fp, '%f', [ 1 nm ]);

	if n < 2
		warning(['We need at least 2 properties: x and y!']);
		lf = zeros(N, d);
		return;
	end

	% Let first 2 params in a line to be x and y
	%lf(i, 1:2) = values(1:2);

	% Read descriptor (descriptor should have d dimensions)
	[ values n ] = fscanf(fp, '%d', [ 1 d ]);

	if n ~= d
		warning(['Not enough dimensions in descriptor: is this file in correct format?']);
		lf = zeros(N, d);
		return;
	end

	lf(i, 1:d) = values(1:d);
end

fclose(fp);

end % readLocalVireoDescriptorsFile



function [ip, N] = readLocalVireoPointsFile(filename)

ip = zeros(0,8);
fp = fopen(filename,'r');
if fp == -1
	warning('Could not open the file: %s', filename);
	N = 0;
	return;
end

% Get number of lines and number of items in each line
line = fgetl(fp);
a = str2num(line);

N = a(1);
nf = a(2);

for i=1:N
	line = fgetl(fp);
	values = str2num(line);
	ip(i, :) = values(1:nf);
end

fclose(fp);

end % readLocalVireoPointsFile

function [lf, ip, d, N] = readOpenCVFeaturesFile(filename)

ip = zeros(0,4);
fp = fopen(filename,'r');
if fp == -1
	warning('Could not open the file: %s', filename);
	N = 0;
	return;
end

% Get the describing line
line = fgetl(fp);

C = textscan(line, '%f');

% Explanation
N = C{1}(1);
d = C{1}(2);
nf = d;

% x, y, size, angle, n-d descriptor

for i=1:N
	line = fgetl(fp);
	values = str2num(line);
	ip(i, :) = values(1:4);
	lf(i, :) = values(5:nf);
end

fclose(fp);

end % readLocalOpenCVPointsFile
