%MVPR_WARNING_WRAP Warning function wrapper (to support old
%versions)
%
% [] = mvpr_warning_wrap(warn_) allows Matlab R13 style warning
% calls in Matlab R12.
%
% Inputs:
%  -
%
% Outputs:
%  -
%
% Examples:
%
% Authors:
%   Pekka Paalanen, MVPR in 2009.
%
% Project:
%  - 
%
% References:
%
% -
%
% See also .
%
function [] = mvpr_warning_wrap(varargin);

old_version = false; %strcmp(version('-release'), '12');

if old_version
	if nargin > 1
		warning(varargin{2});
	else
		warning(varargin{1});
	end
else
	% Assume version Matlab R13
	warning(varargin{:});
end
