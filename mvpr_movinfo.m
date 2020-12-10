function INFO = mvpr_movinfo(moviefile, varargin)

% Parse input arguments
conf = struct('debugLevel', 0);
conf = mvpr_getargs(conf, varargin);

% Find toolbox path
filepath = which('mvpr_movread');

binPath = fileparts(filepath);
binPath = fullfile(binPath, 'binaries');

binPath = '/usr/bin';
tmpPath = tempdir;

binary = fullfile(binPath, ['ffmpeg']);
command = [binary ' -i ' moviefile ' 2> temp.txt'];
[s r] = system(command);
r = fileread('temp.txt');
delete 'temp.txt'
% Extract file info
% Filename
[info.filepath info.filename info.extension] = fileparts(moviefile);

% Length
[matchstart, matchend,tokenindices,matchstring,tokenstring, tokenname, splitstring] = regexp(r, 'Duration: (.*?):(.*?):(.*?),','once');

info.hours = str2num(tokenstring{1});
info.minutes = str2num(tokenstring{2});
info.seconds = str2num(tokenstring{3});

% Resolution & color & codec 
[matchstart, matchend,tokenindices,matchstring,tokenstring, tokenname, splitstring] = regexp(r, 'Video: (.*?), (.*?), (.*?)x(.*?) (.*), (.*?) fps','once');
info.codec = tokenstring{1};
info.color = tokenstring{2};
info.resolution = [tokenstring{3} 'x' tokenstring{4}];
info.fps = str2num(tokenstring{6});

INFO = info;

end
