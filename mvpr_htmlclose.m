%MVPR_HTMLCLOSE - open a html for writing
%
% mvpr_htmlclose(fh) close a html file
%
% Inputs:
%  'fh' - file object created with mvpr_lopen
%
% Outputs:
%  -
%
% Examples:
%  -
%
% Authors:
%  Jukka Lankinen, MVPR in 2010
%
% Project:
%  -
%
% References:
%
% See also MVPR_HTMLWRITE, MVPR_HTMLOPEN
%
function mvpr_lopen(fh, varargin);

%
%% Get parameters
conf = struct('title', 'MVPR webpage', ...
              'style', '');
conf = mvpr_getargs(conf, varargin);

%
%% Write HTML footer info
fprintf(fh, '</body>\n');
fprintf(fh, '</html>\n');
if( fclose(fh) == -1 )
	warning(['closing file failed.']);
end

