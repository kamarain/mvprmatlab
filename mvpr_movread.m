function F = mvpr_movread(moviefile, varargin)

% Parse input arguments
conf = struct('debugLevel', 0,...
              'framerate', 1,...
	      'start', 0,...
	      'end', 1);
conf = mvpr_getargs(conf, varargin);

% Find toolbox path
filepath = which('mvpr_movread');

binPath = fileparts(filepath);
binPath = fullfile(binPath, 'binaries');

binPath = '/usr/bin';
tmpPath = tempdir;


info = mvpr_movinfo(moviefile)
binary = fullfile(binPath, ['ffmpeg']);

lengthSeconds = info.seconds + info.minutes*60 + info.hours * 60 * 60;
startSecond = floor(start * lengthSeconds);
stopSecond = floor(stop * lengthSeconds);
 

command = [binary ' -i ' moviefile ' -r ' num2str(conf.framerate) ' ' [tempdir info.filename] '-%5d.jpeg'];
[s r] = system(command);

if(info.fps < conf.framerate)
	numFrames = floor(lengthSeconds * info.fps);
else
	numFrames = floor(lengthSeconds * conf.framerate);
end

F = {};
for i = 1:numFrames
	filename = sprintf('%s%s-%05d.jpeg',tempdir, info.filename, i);
	F{i} = imread(filename);
end

end % function
