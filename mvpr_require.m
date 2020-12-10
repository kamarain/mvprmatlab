%REQUIRE   - Check for required version of a toolbox/library
%
% REQUIRE(prefix, version)
%
% <prefix> is a name space, the prefix in function names
% of a library, without underscore.
% REQUIRE will try to call '<prefix>_version()' to get
% a version string, and then match it to <version>.
% If it does not match or the function is not found,
% a warning is issued.
% <version> can be a string or a cell array of strings,
% in which case any of the listed versions will suffice.
%
% REQUIRE(prefix, version, 'fatal')
%
% Means that the library is essential and mismatch is regarded
% as an error.
%
% flag = REQUIRE(...)
% Will return zero or one, was the correct library found.
% In non-fatal mode prevents the warning being issued.
% Note that fatal mode still produces an error.
%
% Author:
%   Pekka Paalanen <paalanen@lut.fi>
%
% $Name: HEAD $
% $Id: require.m,v 1.4 2004/11/04 07:14:30 paalanen Exp $

function [found] = mvpr_require(prefix, version, varargin);

found = 0;
fatal = 0;

if nargin > 2
	switch lower(varargin{1})
	case 'fatal'
		fatal = 1;
	otherwise
		error('Error using require()');
	end
end


verfunc = [prefix '_version'];

try
	pkgver = eval([verfunc ';']);
catch
	msg = ['No included package has function ''' ...
	       verfunc ''' defined. Mistyped prefix?'];
	if fatal
		error(msg);
	else
		warning(msg);
	end
	return;
end

if ~iscellstr(version)
	version = { version };
end

for l = 1:length(version)
	if strcmp(version{l}, pkgver)
		found = 1;
	end
end

if found == 0
	msg = ['Package version mismatch: found ''' ...
		pkgver ''', required ' mycellcat(version) ' (prefix '''...
		prefix ''').'];
	if fatal
		error(msg);
		return;
	end
	if nargout < 1
		warning(msg);
	end
end



function str = mycellcat(cells);
	str = ['''' cells{1} ''''];
	for l = 2:length(cells)
		str = [str ' or ''' cells{l} ''''];
	end
