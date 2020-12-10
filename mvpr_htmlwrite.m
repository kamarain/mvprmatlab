%MVPR_HTMLWRITE - write data into a html file
%
% mvpr_htmlwrite(fh, data) write data to a html file
%
% Output:
%  none
%
% Input:
%  'data'  - data to be added to the html file
%
%  <optional>
%  'datatype' - type to be added possible values
%               'image', 'text', 'newline'
%  'dataname' - name of the added type. Image name for images
%
% Author(s):
%  Jukka Lankinen, MVPR in 2010.
%
% Project:
%  -
%
% Copyright:
%   -
%
% See also MVPR_HTMLCLOSE, MVPR_HTMLOPEN
%%
function mvpr_htmlwrite(fd, data, varargin)

%
%% Get parameters
conf = struct('datatype', 'text', ...
              'dataurl', '',...
              'dataname', 'result.png');
conf = mvpr_getargs(conf, varargin);

if conf.datatype == 'text'
	datasize = size(data);
	
	fprintf('<p>');
	for i = 1:data(size,1)
		fprintf('%s', data(i,:));
	end
	fprintf('</p>');
elseif conf.datatype == 'image'
	imwrite(data, conf.dataname);
	
	fprintf('<img src="%s" alt="" />', conf.dataurl);
		
else
	% TODO
end



end
