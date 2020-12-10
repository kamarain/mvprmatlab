function [F D] = mvpr_feature_extract_vireo(img, varargin)
conf = struct('detector', 'dog', ...
              'descriptor', 'sift', ...
              'affine', true, ...
              'binPath', '', ...
              'features', [],...
              'harrisThreshold',100,...
              'hessianThreshold',200,...
              'debugLevel', 0);
              
conf = mvpr_getargs(conf, varargin);

% define files
filepath = which('mvpr_feature_extract_vireo');
binPath = fileparts(filepath);
binPath = fullfile(binPath, 'binaries');
tmpPath = tempdir;

tmpName = tempname;
imgFile = [tmpName '.jpg'];
framesFile = [tmpName '.keys'];
descriptorsFile = [tmpName '.pkeys'];
confFile = fullfile(tmpPath, 'lip-vireo-conf.tmp');
		
% Define optional arguments
%%
%% TODO	
		
% Define binary
binary = fullfile(binPath, ['lip-vireo']);

if ~exist(binary)
	error([binary ' not found. Download from http://www.cs.cityu.edu.hk/~wzhao2/lip-vireo.htm!']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Write temporary image
imwrite(img, imgFile);

% Write temporary config file for lip-vireo
h = fopen(confFile, 'w');
fprintf(h, 'topk=500\n');
if conf.affine == true
	fprintf(h, 'affine=yes\n');
else
	fprintf(h, 'affine=no\n');
end
fprintf(h, 'scale=yes\n');
fprintf(h, 'angle=yes\n');
fclose(h);

% Write decriptorfile if needed
if size(conf.features,1) == 5 && size(conf.features,2) > 0
	writeLocalVireoDescriptorsFile(framesFile, conf.features);
	command = [binary ' -img ' imgFile ' -d ' conf.detector ' -p ' conf.descriptor ...
                  ' -kpdir ' tmpPath ' -dsdir ' tmpPath ' -c ' confFile];
else 
	command = [binary ' -img ' imgFile ' -d ' conf.detector ' -p ' conf.descriptor ...
                  ' -kpdir ' tmpPath ' -dsdir ' tmpPath ' -c ' confFile];
    
end              
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
delete(confFile);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Additional functions                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

function writeLocalVireoDescriptorsFile(filename, lf)

fp = fopen(filename,'w');
if fp == -1
	error('Could not open the file: %s', filename);
end
fprintf(fp,'%d 7\n',size(lf,2));

for i = 1:size(lf, 2)
	fprintf(fp,'%d %d %f %f %f 1 1\n',lf(1,i), lf(2,i), lf(3,i), lf(4,i), lf(5,i));
end
fclose(fp);

end

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
