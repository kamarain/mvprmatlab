%MVPR_HTMLOPEN - open a html for writing
%
% fh = mvpr_htmlopen(fname) open file fname for exporting data
%
% Inputs:
%  'fname' - the file name
% <Optional>
%  'title'  - the title of the html file
%  'style'  - selected stylesheet
%
% Outputs:
%  'fh'    - the default file object is returned for further editing
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
% See also MVPR_HTMLWRITE, MVPR_HTMLCLOSE
%
function fh = mvpr_lopen(fname, varargin);

%
%% Get parameters
conf = struct('title', 'MVPR webpage', ...
              'style', '');
conf = mvpr_getargs(conf, varargin);

fid = fopen(fname, 'wt');

if fid == -1
	error(['could not open file ' fname]);
end

%
%% Write HTML header info
fprintf(fid, '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">\n');
fprintf(fid, '<html>\n');
fprintf(fid, '<head>\n');
fprintf(fid, '<title>%s</title>\n', conf.title);
fprintf(fid, '<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />');
fprintf(fid, '</head>\n');
fprintf(fid, '<body>\n');

fh = fid;
