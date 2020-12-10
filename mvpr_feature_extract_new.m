% [F D] = MVPR_FEATURE_EXTRACT(IMG)
%
% NOTE: This should replace MVPR_FEATURE_EXTRACT.M - the main
% difference is that detector and descriptor are tied together -
% that makes sense since they naturally are due to available
% binaries and Matlab functions.
%
% [F D] = mvpr_feature_extract(img,:) detects/selects interest
% points/regions F from the image img and their descriptors D.
% This function wraps the following implementations by various
% researchers:
%
%   * OpenCV detectors: bundled. Compile it from under opencv_descriptors
%     and move the opencv_descriptors binary unde binaries directory
%   * VLFeat (vl): http://www.vlfeat.org/ (sift, dsift, mser)
%   * Feature Space (fs): 'compute_descriptors' Linux binary
%     (32/64-bit) (harlap, heslap, haraff, hesaff, mser, harris,
%     hessian, harmulti, hesmulti, harhes)
%     - Note: Binaries are sought under <MVPRMATLAB>/binaries/ 
%   * Vireo (vi): http://www.cs.cityu.edu.hk/~wzhao2/lip-vireo.htm (*-vireo)
%   * Mikolajczyk old (mo): http://www.robots.ox.ac.uk/~vgg/research/affine/detectors.html 
%     (haraff-alt, hesaff-alt, ebr, ibr, mser)
%     - Note: Binaries are sought under <MVPRMATLAB>/binaries/ 
%
% The defaults are set according to our own findings and the
% underlying functionality defaults.
%
% TODO: Maybe this could completely rely on VLFeat but since
% Mikolajczyk's Hessian affine detectors performs marveluously
% well in our applications we are affraid to stop using it.
%
% Input:
%  img - Image from where the ip's are detected and descriptors computed
%         Note: for fs_* methods it is faster to give an image file
%         name rather than the image itself since it needs to be
%         written to a file for the binary!
%
% <Optional:
%  'method' - Describes the pair of detector and descriptor:
%                * 'fs_hesaff+fs_sift' (Default) - found best in [1]
%                * 'fs_mser+fs_sift'
%                * 'vl_sift+vl_sift'
%                * 'vl_dense+vl_sift'
%                * 'vl_densems+vl_sift'
%                * 'cv_sift+cv_sift'
%                * 'cv_surf+cv_surf'
%                * 'cv_orb+cv_brief'
%                * 'cv_orb+cv_sift'
%                * 'cv_dense+cv_orb'
%                * 'cv_dense+cv_sift'
%                * 'vl_dense+mvpr_sg' (returns sgS structure needed
%                                      in matching)
%
%  'fs_hesThres'           fs_hesaff Hessian treshold (Def. 200) SHOULD BE
%  500!
%
%  ''fs_density'           Default: 100
%
%  'vl_siftPeakThreshold'  Peak threshold for Sift interest point detector
%                          Default: 0
%
%  'vl_siftEdgeThreshold'  Edge threshold for Sift interest point detector
%                          Default: 10
%
%  'vl_Levels'             Number of levels per octave of the DoG scale
%                          space. Default: 3
%
%  'harrisThreshold'       Harris threshold, when 'detector' is 'haraff'
%                          Default: 100
%
%  'vl_denseStep'          Step size in dense sampling
%                          Default: 10
%
%  'vl_denseSize'          Size of the extracted local feature in dense sampling
%                          Default: 10
%
% Outputs:
%  F - Feature frames for localization and visualization of features
%  D - Unique feature descriptors for matching
%
% <optional>:
%  S - Special structure, e.g.,
%      'vl_dense+mvpr_sg' -> sgS needed in descriptor matching
% 
% Examples:
%  -
%
% Authors:
%  Joni Kamarainen, MVPR 2010-2012
%  Jukka Lankinen,  MVPR 
%  Ville Kangas,    MVPR
%
% Project:
%  Object3D2D (http://www2.it.lut.fi/project/object3d2d/index.shtml)
%
% References:
%  [1] J. Lankinen and J.-K. Kamarainen, Local Feature Based
%  Unsupervised Alignment of Object Class Images, British Machine
%  Vision Conference (BMVC2011).

%
function [F D varargout] = mvpr_feature_extract_new(img, varargin)

%%%%%%%%%%%%%%%
% COMMON PART %
%%%%%%%%%%%%%%%
%global confParameter
% Parse input arguments

conf = struct('method','fs_hesaff+fs_sift',...   
...% These are the default parameters which are derived from the manuals of different implementations
'fs_harThres', 100, ...
'fs_hesThres', 200, ... 
'fs_density', 100, ...
'debugLevel', 0,...
'vl_siftPeakThreshold', 0, ... 
'vl_siftEdgeThreshold', 10,... 
'vl_Levels', 3,...     
'vl_denseStep', 10, ... 
'vl_denseSize', 10,...   
'benchType', '',...
'gabor_fmax', 1/20,...
'gabor_fnum', 4,...
'gabor_thetanum', 6,...
'gabor_k', sqrt(3),...
'gabor_p', 0.65);

% ...% Parameters are selected to return on average 300 regions
% ...% with caltech101 dataset
% ...% DESCRIPTOR 
% 'fs_harThres', 100, ...
% 'fs_hesThres', 200, ... 
% 'fs_density', 155, ... 
% 'debugLevel', 0,...
% 'vl_siftPeakThreshold', 0, ... 
% 'vl_siftEdgeThreshold', 21,... 
% 'vl_Levels', 11,...     
% 'vl_denseStep', 8, ... 
% 'vl_denseSize', 20,...    
% 'benchType', '',...
% 'gabor_fmax', 1/20,...
% 'gabor_fnum', 4,...
% 'gabor_thetanum', 6,...
% 'gabor_k', sqrt(3),...
% 'gabor_p', 0.65);    


% ...% Parameters are selected to return on average 300 regions
% ...% with Imagenet dataset
% ...% DESCRIPTOR 
% 'fs_harThres', 100, ...
% 'fs_hesThres', 200, ... 
% 'fs_density', 155, ... 
% 'debugLevel', 0,...
% 'vl_siftPeakThreshold', 0, ... 
% 'vl_siftEdgeThreshold', 30,... 
% 'vl_Levels', 11,...     
% 'vl_denseStep', 8, ... 
% 'vl_denseSize', 20,... 
% 'benchType', '',...
% 'gabor_fmax', 1/20,...
% 'gabor_fnum', 4,...
% 'gabor_thetanum', 6,...
% 'gabor_k', sqrt(3),...
% 'gabor_p', 0.65);     



  

% ...% Parameters are selected to return on average 300 regions
% ...% with caltech101 dataset
% ...% DETECTOR
% 'fs_harThres', 100, ...
% 'fs_hesThres', 200, ... 
% 'fs_density', 85, ... 
% 'debugLevel', 0,...
% 'vl_siftPeakThreshold', 0, ... 
% 'vl_siftEdgeThreshold', 15,... 
% 'vl_Levels', 12,...     
% 'vl_denseStep', 7, ... 
% 'vl_denseSize', 27,...    
% 'benchType', '',...
% 'gabor_fmax', 1/20,...
% 'gabor_fnum', 4,...
% 'gabor_thetanum', 6,...
% 'gabor_k', sqrt(3),...
% 'gabor_p', 0.65);  

    
% ...%%%%%%%%%%%%%%%
% ...% Parameters are selected to return on average 300 regions
% ...% with r-caltech101 dataset
% ...% DETECTOR TEST
% 'fs_harThres', 100, ...
% 'fs_hesThres', 200, ... 
% 'fs_density', 110, ... 
% 'debugLevel', 0,...
% 'vl_siftPeakThreshold', 0, ... 
% 'vl_siftEdgeThreshold', 27,... 
% 'vl_Levels', 10,...     
% 'vl_denseStep', 9, ... 
% 'vl_denseSize', 16,... 
% 'benchType', '',...
% 'gabor_fmax', 1/20,...
% 'gabor_fnum', 4,...
% 'gabor_thetanum', 6,...
% 'gabor_k', sqrt(3),...
% 'gabor_p', 0.65);

% ...%%%%%%%%%%%%%%%
% ...% Parameters are selected to return on average 300 regions
% ...% with r-caltech101 dataset
% ...% DESCRIPTOR TEST
% 'fs_harThres', 100, ...
% 'fs_hesThres', 200, ... 
% 'fs_density', 210, ... 
% 'debugLevel', 0,...
% 'vl_siftPeakThreshold', 0, ... 
% 'vl_siftEdgeThreshold', 14,... 
% 'vl_Levels', 9,...     
% 'vl_denseStep', 10, ... 
% 'vl_denseSize', 18,...    
% 'benchType', '',...
% 'gabor_fmax', 1/20,...
% 'gabor_fnum', 4,...
% 'gabor_thetanum', 6,...
% 'gabor_k', sqrt(3),...
% 'gabor_p', 0.65);

if (nargin >= 1 && isstr(img) && strcmp(img,'CONFIG')) %
	F = conf;
	return;
end;

conf = mvpr_getargs(conf, varargin);

% Function is used to test detectors and descriptors with different 
% parameters
% if confParameter >= 2
%     conf = loadConfigures(conf);
% end

varargout{1} = conf;

% Find toolbox path
filepath = which('mvpr_feature_extract');

binPath = fileparts(filepath);
binPath = fullfile(binPath, 'binaries');
tmpPath = tempdir;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPENCV IMPLEMENTATIONS                                  %
% 'cv_sift+cv_sift', 'cv_surf+cv_surf', 'cv_orb+cv_brief' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (strcmp(conf.method,'cv_sift+cv_sift'))
	% define files
	if (isstr(img))
		imgFile = img;
    else
	    imgFile = [tempname '.png']; % needs to be saved first
	    imwrite(img,imgFile);
    end;
    featureFile = [imgFile '.cv_sift.cv_sift'];

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

    command = [binary ' -d SIFT -s SIFT ' optArgs ' -i ' imgFile ' -p ' featureFile ' -V 0'];
    [s r] = system(command);

    if (s) % Something wrong with the binary (e.g. +x missing ;)
	    error(['Binary execution ''' command ''' failed ' ...
	    'with output: ' r]);
    end;
    [D, feat, d, n] = readOpenCVFeaturesFile(featureFile);	
    % Convert circles to same ellipse format that other detectors output
    feat = feat';
    %keyboard
    if size(feat,1) == 4
	    len = size(feat,2);
	    % x,y,a,b,c,scale; because this is a circle, a == c and b == 0
	    F = convertFeatures([ feat(1, :)' feat(2, :)' ones(len,1) ...
	    zeros(len,1) ones(len,1) feat(3, :)' ]);
	    F = F';
    else
	  F = feat;
	  F = F';
  end;
  D = D';

  if (~isstr(img))
	  % Delete temporary file
	  delete(imgFile);
  end;
  delete(featureFile);
elseif (strcmp(conf.method,'cv_orb+cv_brief'))
	% define files
	if (isstr(img))
		imgFile = img;
    else
	    imgFile = [tempname '.png']; % needs to be saved first
	    imwrite(img,imgFile);
    end;
    featureFile = [imgFile '.cv_orb.cv_brief'];

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

	    %F = convertFeatures([ feat(1, :)' feat(2, :)' ones(len,1)...
	    %zeros(len,1) ones(len,1) feat(3, :)' ]);
	    F = convertFeatures([ feat(1, :)' feat(2, :)' ones(len,1)...
	    zeros(len,1) ones(len,1) feat(3, :)' ]);
	    F = F';
  else
	  F = feat;
	  F = F';
  end;
  D = D';

  if (~isstr(img))
	  % Delete temporary file
	  delete(imgFile);
  end;
  delete(featureFile);

elseif (strcmp(conf.method,'cv_orb+cv_orb'))
	% define files
	if (isstr(img))
		imgFile = img;
    else
	    imgFile = [tempname '.png']; % needs to be saved first
	    imwrite(img,imgFile);
    end;
    featureFile = [imgFile '.cv_orb.cv_orb'];

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

    command = [binary ' -d ORB -s ORB ' optArgs ' -i ' imgFile ' -p ' featureFile ' -V 0'];
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

	    %F = convertFeatures([ feat(1, :)' feat(2, :)' ones(len,1)...
	    %zeros(len,1) ones(len,1) feat(3, :)' ]);
	    F = convertFeatures([ feat(1, :)' feat(2, :)' ones(len,1)...
	    zeros(len,1) ones(len,1) feat(3, :)' ]);
	    F = F';
  else
	  F = feat;
	  F = F';
  end;
  D = D';

  if (~isstr(img))
	  % Delete temporary file
	  delete(imgFile);
  end;
  delete(featureFile);



elseif (strcmp(conf.method,'cv_surf+cv_surf'))
	% define files
	if (isstr(img))
		imgFile = img;
    else
	    imgFile = [tempname '.png']; % needs to be saved first
	    imwrite(img,imgFile);
    end;
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

    command = [binary ' -d SURF -s SURF ' optArgs ' -i ' imgFile ' -p ' featureFile ' -V 0'];
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
  end;
  D = D';

  if (~isstr(img))
	  % Delete temporary file
	  delete(imgFile);
  end;
  delete(featureFile);
elseif (strcmp(conf.method,'cv_orb+cv_sift'))
	% define files
	if (isstr(img))
		imgFile = img;
    else
	    imgFile = [tempname '.png']; % needs to be saved first
	    imwrite(img,imgFile);
    end;
    featureFile = [imgFile '.cv_orb.cv_sift'];

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
    optArgs = [ ' -e ' num2str(10) ];
    
    command = [binary ' -d ORB -s SIFT ' optArgs ' -i ' imgFile ' -p ' featureFile ' -V 0'];
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
  end;
  D = D';

  if (~isstr(img))
	  % Delete temporary file
	  delete(imgFile);
  end;
  delete(featureFile);


elseif (strcmp(conf.method,'cv_dense+cv_sift'))
	% define files
	if (isstr(img))
		imgFile = img;
    else
	    imgFile = [tempname '.png']; % needs to be saved first
	    imwrite(img,imgFile);
    end;
    featureFile = [imgFile '.cv_dense.cv_sift'];

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
    command = [binary ' -d Dense -s SIFT ' optArgs ' -i ' imgFile ' -p ' featureFile ' -V 0 -e ' num2str(10)];
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
  end;
  % Fix this in the future
  % Make sure the binary gets the right size
  %F(3,:) = conf.vl_denseSize / 1000;
  %F(5,:) = conf.vl_denseSize / 1000;
  D = D';

  if (~isstr(img))
	  % Delete temporary file
	  delete(imgFile);
  end;
  delete(featureFile);



elseif (strcmp(conf.method,'cv_dense+cv_brief'))
	% define files
	if (isstr(img))
		imgFile = img;
    else
	    imgFile = [tempname '.png']; % needs to be saved first
	    imwrite(img,imgFile);
    end;
    featureFile = [imgFile '.cv_dense.cv_brief'];

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
    command = [binary ' -d Dense -s BRIEF ' optArgs ' -i ' imgFile ' -p ' featureFile ' -V 0 -e ' num2str(conf.vl_denseStep)];
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
  end;
  D = D';

  % Fix this in the future
  % Make sure the binary gets the right size
  %F(3,:) = conf.vl_denseSize / 1000;
  %F(5,:) = conf.vl_denseSize / 1000;
  if (~isstr(img))
	  % Delete temporary file
	  delete(imgFile);
  end;
  delete(featureFile);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FEATURE SPACE IMPLEMENTATIONS          %
% 'fs_hesaff+fs_sift', 'fs_mser+fs_sift' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (strcmp(conf.method,'fs_hesaff+fs_sift'))
	% define files
	if (isstr(img))
		imgFile = img;
    else
	    imgFile = [tempname '.png']; % needs to be saved first
	    imwrite(img,imgFile);
    end;
    featureFile = [imgFile '.fs_hessaff.fs_sift'];

    % Define binaries with paths
    switch computer
    case 'GLNX86' % 32-bit
	    binary = fullfile(binPath, ['compute_descriptors_32bit.ln']);
    case 'GLNXA64' % 64-bit
	    binary = fullfile(binPath, ['compute_descriptors_64bit.ln']);
    otherwise
	    error('This architecture is not supported by the FeatureSpace binaries.')
    end

    optArgs = '';
    optArgs = [ ' -hesThres ' num2str(conf.fs_hesThres) ' -density ' num2str(conf.fs_density)];

    command = [binary ' -hesaff -sift ' optArgs ' -i ' imgFile ' -o1 ' featureFile];
    [s r] = system(command);

    if (s) % Something wrong with the binary (e.g. +x missing ;)
	    error(['Binary execution ''' command ''' failed ' ...
	    'with output: ' r]);
    end;
    [D, F, d, n] = readLocalFeatureFile(featureFile);		

    F = F';
    D = D';

    if (~isstr(img))
	    % Delete temporary file
	    delete(imgFile);
    end;
    delete(featureFile);

elseif (strcmp(conf.method,'fs_mser+fs_sift'))
	% define files
	if (isstr(img))
		imgFile = img;
    else
	    imgFile = [tempname '.png']; % needs to be saved first
	    imwrite(img,imgFile);
    end;
    featureFile = [imgFile '.fs_hessaff.fs_sift'];

    % Define binaries with paths
    switch computer
    case 'GLNX86' % 32-bit
	    binary = fullfile(binPath, ['compute_descriptors_32bit.ln']);
    case 'GLNXA64' % 64-bit
	    binary = fullfile(binPath, ['compute_descriptors_64bit.ln']);
    otherwise
	    error('This architecture is not supported by the FeatureSpace binaries.')
    end

    optArgs = '';

    command = [binary ' -mser -sift ' optArgs ' -i ' imgFile ' -o1 ' featureFile];
    [s r] = system(command);

    if (s) % Something wrong with the binary (e.g. +x missing ;)
	    error(['Binary execution ''' command ''' failed ' ...
	    'with output: ' r]);
    end;
    [D, F, d, n] = readLocalFeatureFile(featureFile);		

    F = F';
    D = D';

    if (~isstr(img))
	    % Delete temporary file
	    delete(imgFile);
    end;
    delete(featureFile);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VLFeat implementations                                      %
% 'vl_sift+vl_sift', 'vl_dense+vl_sift', 'vl_densems+vl_sift' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (strcmp(conf.method,'vl_sift+vl_sift'))
	% define files
	if (isstr(img))
		img = imread(img);
  end;
  if ~exist('vl_sift')
	  error('VLFeat functionality not in the Matlab path!')
  end
  if length(size(img)) == 3
	  img = rgb2gray(img);
  end;
  [feat, D] = ...
  vl_sift(single(img), 'PeakThresh', conf.vl_siftPeakThreshold,...
  'EdgeThresh', conf.vl_siftEdgeThreshold,...
    'Levels', conf.vl_Levels);
  %D = uint8(sqrt(double(D)));
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

  elseif (strcmp(conf.method,'vl_dense+vl_sift'))
	  % define files
	  if (isstr(img))
		  img = imread(img);
    end;
    if ~exist('vl_sift')
	    error('VLFeat functionality not in the Matlab path!')
    end
    if length(size(img)) == 3
	    img = rgb2gray(img);
    end;
    [F, D] = vl_dsift(single(img), 'size',conf.vl_denseSize,'step', conf.vl_denseStep);
    %[F, D] = vl_dsift(single(img), 'size',8); %Use these when comparing to slow
    %version
    D = uint8(sqrt(double(D)));
    len = size(F,2);
    F(3,:) = conf.vl_denseSize;
    %F(3,:) = conf.vl_denseSize/3.2; %Use these when comparing to slow
    %version
    F(4,:) = 0 ;
    F = convertFeatures([F(1, :)' F(2, :)' ones(len,1)...
    zeros(len,1) ones(len,1) F(3,:)']);
    F = F';
    %F = convertFeatures([F(1, :)' F(2, :)' ones(len,1)...
    %                    zeros(len,1) ones(len,1) ones(len,1)*conf.vl_denseStep]);
    %F = F';
    %F = [F;ones(1,size(F,2)); zeros(1,size(F,2)); ones(1,size(F,2)); ones(1,size(F,2))*conf.vl_denseSize];


  elseif (strcmp(conf.method,'vl_dense+vl_sift(slow)'))
	  % define files
	  if (isstr(img))
		  img = imread(img);
    end;
    if ~exist('vl_sift')
	    error('VLFeat functionality not in the Matlab path!')
    end
    if length(size(img)) == 3
	    img = single(vl_imdown(rgb2gray(img)));
    end;
    %binSize = 30;
    %magnif = 3;
    img = vl_imsmooth(img, sqrt((conf.vl_denseSize/4)^2 - .25)) ;
    %[F_, D_] = vl_dsift(img,'step', conf.vl_denseStep,'size',conf.vl_denseSize);
    %img = vl_imsmooth(img, sqrt((8/3)^2 - .25)) ;
    [F_, D_] = vl_dsift(img,'size',8);
    len = size(F_,2);
    F_(3,:) = conf.vl_denseSize/3.2;
    F_(4,:) = 0 ;
    [feat, D] = vl_sift(img,'frames',F_);
    %[feat, D] = vl_sift(img,'frames',F_,'PeakThresh', 0,...
    %'EdgeThresh', 10,'Levels', 150);
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

elseif (strcmp(conf.method,'vl_densems+vl_sift'))
	% define files
	if (isstr(img))
		img = imread(img);
    end;
    if ~exist('vl_sift')
	    error('VLFeat functionality not in the Matlab path!')
    end
    if length(size(img)) == 3
	    img = rgb2gray(img);
    end;

    % these are from Mikolajczyk's 2011 paper
    %binSize = [16 24 32 40]; % or probably double as they say "radii"
    %stepSize = [8 14 20 26];
    %binSize =  [32 48 64 80];
    %stepSize = [ 8 14 20 26];
    binSize =  [12 24 36];
    stepSize = [12 24 36];
    magnif = 3;

    I = single(img);
    F = [];
    D = [];
    for binInd = 1:length(binSize)
	    Is = vl_imsmooth(I, sqrt((binSize(binInd)/magnif)^2 - .25)) ;
	    %imagesc(Is); colormap gray
	    %input('ret')
	    [f, d] = vl_dsift(Is, 'size', binSize(binInd),'step',stepSize(binInd),'Fast');
	    %'Bounds',[-round(size(Is,2))+round(binSize(binInd)/2) -round(size(Is,1))+round(binSize(binInd)/2)...
	    %size(Is,2)-round(binSize(binInd)/2) size(Is,1)-round(binSize(binInd)/2)]) ;
	    f(3,:) = binSize(binInd);
	    f(4,:) = 0 ;
	    F = [F f];
	    D = [D d];
    end;
    len = size(F,2);
    F = convertFeatures([F(1, :)' F(2, :)' ones(len,1)...
    zeros(len,1) ones(len,1) F(3,:)']);
    F = F';

    %[F, D] = vl_dsift(single(img), 'step', conf.vl_denseStep, 'size', conf.vl_denseSize);
    %F = [F;ones(1,size(F,2)); zeros(1,size(F,2)); ones(1,size(F,2)); ones(1,size(F,2))*conf.vl_denseSize];

    elseif (strcmp(conf.method,'fs_hesaff/vl_densems+fs_sift/vl_sift'))
	    % define files
	    if (isstr(img))
		    imgFile = img;
    else
	    imgFile = [tempname '.png']; % needs to be saved first
	    imwrite(img,imgFile);
    end;
    featureFile = [imgFile '.fs_hessaff.fs_sift'];

    % Define binaries with paths
    switch computer
    case 'GLNX86' % 32-bit
	    binary = fullfile(binPath, ['compute_descriptors_32bit.ln']);
    case 'GLNXA64' % 64-bit
	    binary = fullfile(binPath, ['compute_descriptors_64bit.ln']);
    otherwise
	    error('This architecture is not supported by the FeatureSpace binaries.')
    end

    optArgs = '';
    optArgs = [ ' -hesThres ' num2str(conf.fs_hesThres) ];

    command = [binary ' -hesaff -sift ' optArgs ' -i ' imgFile ' -o1 ' featureFile];
    [s r] = system(command);

    if (s) % Something wrong with the binary (e.g. +x missing ;)
	    error(['Binary execution ''' command ''' failed ' ...
	    'with output: ' r]);
    end;
    [D, F, d, n] = readLocalFeatureFile(featureFile);		

    F1 = F';
    D1 = D';

    if (~isstr(img))
	    % Delete temporary file
	    delete(imgFile);
    end;
    delete(featureFile);

    % define files
    if (isstr(img))
	    img = imread(img);
    end;
    if ~exist('vl_sift')
	    error('VLFeat functionality not in the Matlab path!')
    end
    if length(size(img)) == 3
	    img = rgb2gray(img);
    end;

    binSize =  [12 24 36];
    stepSize = [12 24 36];
    magnif = 3 ; % same as vl_sift

    I = single(img);
    F = [];
    D = [];
    for binInd = 1:length(binSize)
	    Is = vl_imsmooth(I, sqrt((binSize(binInd)/magnif)^2 - .25)) ;
	    [f, d] = vl_dsift(Is, 'size', binSize(binInd),'step',stepSize(binInd),'Fast');
	    f(3,:) = binSize(binInd)/magnif ;
	    f(4,:) = 0 ;
	    F = [F f];
	    D = [D d];
    end;
    len = size(F,2);
    F = convertFeatures([F(1, :)' F(2, :)' ones(len,1)...
    zeros(len,1) ones(len,1) F(3,:)']);
    F2 = F';
    D2 = D;

    F = [F1 F2];
    D = [D1 D2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MVPR SIMPLE GABOR DESCRIPTOR %
% 'vl_dense+mvpr_sg'           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (strcmp(conf.method,'vl_dense+mvpr_sg'))
  % Load image if string
  if (isstr(img))
    img = imread(img);
  end;
  % Convert to gray level
  if length(size(img)) == 3
    img = rgb2gray(img);
  end;
  
  % Take locations from vl_dsift - I know this is stupid, they
  % should be devised without dummy call, but I'm lazy /Joni
  [F, D] = vl_dsift(single(img), 'step', conf.vl_denseStep, 'size', conf.vl_denseSize);
  len = size(F,2);
  F(3,:) = conf.vl_denseSize;
  F(4,:) = 0 ;
  F = convertFeatures([F(1, :)' F(2, :)' ones(len,1)...
                      zeros(len,1) ones(len,1) F(3,:)']);
  F = F';
  
  [D sgS] = mvpr_sg_descriptor(img,F(1:2,:)',conf);
  D = transpose(D); % consistent with others
  if (nargout < 3)
    warning(['You should take the simple Gabor sgS structure as an ' ...
             'output argument as it is needed for matching!']);
  else
    varargout{1} = sgS;
    varargout{2} = conf;
  end;
  
  %F = convertFeatures([F(1, :)' F(2, :)' ones(len,1)...
  %                    zeros(len,1) ones(len,1) ones(len,1)*conf.vl_denseStep]);
  %F = F';
  %F = [F;ones(1,size(F,2)); zeros(1,size(F,2)); ones(1,size(F,2)); ones(1,size(F,2))*conf.vl_denseSize];

%%%%%%%%%%%
% UNKNOWN %
%%%%%%%%%%%

else
	error(['Unknown method: ' conf.method]);
end;

%%% DEBUG-2 STARTS -> %%%
if (conf.debugLevel >= 2)
	if isstr(img)
		dbg_img = imread(img);
  else
	  dbg_img = img;
  end;
  mvpr_feature_plot(dbg_img, F);
  fprintf(' - Number of features: %d - ',size(F,2));
  input('[DEBUG-2] Extracted local image features <RET>');
end;
%%% DEBUG-2 ENDS  <- %%%


return;

switch conf.detector
	%
	%% VLFeat
case {'dog','sift'}

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
		'hessian', 'harmulti', 'hesmulti', 'harhes'}
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
		binary = fullfile(binPath, ['lip-vireo']);
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
		command = [binary ' -img ' imgFile ' -d ' detector ' -p ' descriptor ' -kpdir ' tmpPath ' -dsdir ' tmpPath ' -c ' confFile];

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

ip = zeros(0,7);
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
	lf(i, :) = values(5:(nf+4));
end

% Convert size to radius
ip(:,3) = ip(:,3) / 2;
ip(:,4) = ip(:,4) * (pi/180);


fclose(fp);

end % readLocalOpenCVPointsFile


