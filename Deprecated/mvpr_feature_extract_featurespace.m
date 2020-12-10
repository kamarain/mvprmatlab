%
%
%

function [F D] = mvpr_feature_extract_featurespace(img, varargin)
conf = struct('detector', 'dog', ...
              'descriptor', 'sift', ...
              'binPath', '',...
              'features',[],...
              'harrisThreshold',100,...
              'hessianThreshold',200,...
              'debugLevel', 0);
              
conf = mvpr_getargs(conf, varargin);

%%% Locate binaries
filepath = which('mvpr_feature_extract_featurespace');
binPath = fileparts(filepath);
binPath = fullfile(binPath, 'binaries');
tmpPath = tempdir;

% Define filenames (temp)
tmpName = tempname;
imgFile = [tmpName '.png'];
framesFile = [tmpName '.keys'];
featureFile = [imgFile '.' conf.detector '.' conf.descriptor];

% Define optional arguments
optArgs = '';
if strcmp(conf.detector, 'haraff') == 1
	optArgs = [ ' -harThres ' num2str(conf.harrisThreshold) ];
elseif strcmp(conf.detector, 'hesaff') == 1
	optArgs = [ ' -hesThres ' num2str(conf.hessianThreshold) ];
end

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
	error([binary ' not found. Download from http://www.featurespace.org!']);
end	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write temp files
imwrite(img, imgFile);

% Build a system command
if size(conf.features,1) == 5 && size(conf.features,2) > 0
writeFeaturespaceFeaturesFile(framesFile, conf.features);
command = [binary ' -' conf.descriptor optArgs ...
                  ' -i ' imgFile ' -o1 ' featureFile ' -p1 ' framesFile];
else
command = [binary ' -' conf.detector ' -' conf.descriptor optArgs ...
                  ' -i ' imgFile ' -o1 ' featureFile];

end

% Run the system command              
[s r] = system(command);
		
% Read features from file
if strcmp(conf.descriptor, 'gloh') == 1
	% bug in binary. additional .gloh suffix
	[D, F, d, n] = readLocalFeatureFile([featureFile '.gloh']);
else
	[D, F, d, n] = readLocalFeatureFile(featureFile);
end
F = F';
D = D';

%for l = 1:size(F,2)
%	a = F(3,l);
%	b = F(4,l);
%	c = F(5,l);
%	
%	[v e] = eig([a b;b c]);
%	
%	l1 = 1/sqrt(e(1));
%	l2 = 1/sqrt(e(4));

%	F(3,l) = l1*v(1);
%	F(4,l) = l1*v(2);
%	
%	F(5,l) = l2*v(3);
%	F(6,l) = l2*v(4);
%end

% Remove identical features
[A B C] = unique([single(F); single(D)]','rows');

F = F(:,B);
D = D(:,B);

% Delete temporary file
delete(imgFile);
if strcmp(conf.descriptor, 'gloh') == 1
	% bug in binary. additional .gloh suffix
	delete([featureFile '.gloh']);
else
	delete(featureFile);
end
end % function




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Additional functions                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [lf, ip, d, N] = readLocalFeatureFile(filename)

% Open local feature file for reading
fp = fopen(filename,'r');
if fp == -1
	warning('Could not open the file: %s', filename);
	lf = zeros(0,128);
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

end % function


function [] = writeFeaturespaceFeaturesFile(filename, lf)

fp = fopen(filename,'w');
if fp == -1
	error('Could not open the file: %s', filename);
end
fprintf(fp,'128\n');
fprintf(fp,'%d\n',size(lf,2));

for i = 1:size(lf, 2)
	fprintf(fp,'%f %f %f %f %f ',lf(1,i), lf(2,i), lf(3,i), lf(4,i), lf(5,i));
	for j = 1:128
		fprintf(fp, '0 ');
	end
	fprintf(fp,'\n');
end
fclose(fp);

end % function

