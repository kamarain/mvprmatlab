% [MATCHES SCORES] = MVPR_FEATURE_MATCH(DESCR1, DESCR2)
% Matches feature descriptors DESCR1 to DESCR2 and return matches with 
% scores.
%
% NOTE: YOU PROBABLY DON'T WANT TO USE THIS BUT MVPR_FEATURE_MATCH_MATRIX.M
%
% Optional:
% 'threshold'  -  Threshold for similarity check
%
% Output:
%  MATCHES        Matches between DESCR1 and DESCR2
%  SCORES         Distances between matches
%
%
function [matches scores] = mvpr_feature_match(descr1, descr2, varargin)	

conf = struct('threshold', 1.5);
conf = mvpr_getargs(conf,varargin);
if ~exist('vl_ubcmatch')
	error('VLFEAT not found!')
end
[matches scores] = vl_ubcmatch(descr1, descr2, conf.threshold);

end
