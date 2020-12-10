%
%
%

function [F D] = mvpr_feature_extract_surf(img, varargin)
conf = struct('binPath', '',...
              'features',[],...
              'debugLevel', 0);
              
conf = mvpr_getargs(conf, varargin);

%%% Locate binaries
filepath = which('mvpr_feature_extract_featurespace');
binPath = fileparts(filepath);
binPath = fullfile(binPath, 'binaries');
tmpPath = tempdir;

tmpName = tempname;

imgFile = [tmpName '.pgm'];
framesFile = [tmpName '.keys'];
featureFile = [tmpPath 'temp.png.surf.surf'];
% Define binary
binary = fullfile(binPath, ['surf.ln']);
if ~exist(binary)
	error([binary ' not found. Download from http://www.vision.ee.ethz.ch/~surf/']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Write temporary image
imwrite(img, imgFile);

% run command
if size(conf.features,1) == 5 && size(conf.features,2) > 0
	writeFeaturespaceFeaturesFile(framesFile, conf.features);
	command = [binary ' -i ' imgFile ' -o ' featureFile ' -p1 ' framesFile];
else
	command = [binary ' -i ' imgFile ' -o ' featureFile];
end

[s r] = system(command);

if s ~= 0
	error(['Running SURF failed: ' r]);
end


[D, F, d, n] = readLocalFeatureFileDouble(featureFile);

D = D';
F = F';

% clean up
delete(imgFile);
%delete(featureFile);

end % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Additional functions                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = writeFeaturespaceFeaturesFile(filename, lf)

fp = fopen(filename,'w');
if fp == -1
	error('Could not open the file: %s', filename);
end
fprintf(fp,' \n%d\n',size(lf,2));

for i = 1:size(lf, 2)
	fprintf(fp,'%f %f %f %f %f\n',lf(1,i), lf(2,i), lf(3,i), lf(4,i), lf(5,i));
end
fclose(fp);

end % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
end % function
