%MVPR_CHKCONFIG - Compare saved and current configurations
%
% mvpr_chkconfig(oldconfig, currconfig, items, level)
%
% Inputs
%  'oldconfig'   - configuration structure read from a save file,
%                  ignored if it is empty: []
%  'currconfig'  - current configuration structure
%  'items'       - cell array of strings, the names of relevant
%                  configuration structure fields, or empty to
%                  check all fields
%  'level'       - the level of notification:
%                   0  print notification
%                   1  print notifications as warnings
%                   2  print notification, produce error
% Outputs:
%  'data' - cell array of strings, items on a line
%
% Examples:
%  -
%
% Authors:
%  Pekka Paalanen, MVPR in 2009
%
% Project:
%  -
%
% References:
%
% See also .
%
function [kosh] = mvpr_chkconfig(oldconf, currconf, items, level);

if isempty(items)
	if isempty(oldconf)
		al = {};
	else
		al = fieldnames(oldconf);
	end
	bl = fieldnames(currconf);
	items = unique({ al{:} bl{:} });
end

kosh = 0;

for i = 1:length(items)
	miss=0;
	if ( ~isempty(oldconf) ) & ( ~isfield(oldconf, items{i}) )
		message(level, ['Field ''' items{i} ...
		   ''' missing in OLD configuration.']);
		miss = 1;
		kosh = 1;
	end
	
	if ~isfield(currconf, items{i})
		message(level, ['Field ''' items{i} ...
		   ''' missing in CURRENT configuration.']);
		miss = 1;
		kosh = 1;
	end
	
	if miss==1
		continue;
	end
	
	if isempty(oldconf)
		continue;
	end
	
	if ~isequalwithequalnans( oldconf.(items{i}), currconf.(items{i}) )
		fprintf(['OLD.' items{i} ' = ']);
		disp(oldconf.(items{i}));
		fprintf(['CURRENT.' items{i} ' = ']);
		disp(currconf.(items{i}));
		message(level, ['Field ''' items{i} ...
		   ''' value has changed. ']);
		kosh = 1;
	end
end

if (kosh==1) & (level > 1)
	error('Configuration mismatch.');
end



function message(level, txt);

if level < 1
	disp(txt);
elseif level < 2
	warning(txt);
else
	disp(txt);
end
