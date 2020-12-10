%MVPR_UNPROJECT - add unit element to column vectors
%
% y = mvpr_unproject(x)
% y = mvpr_unproject(x, rho)
%
% Returns a matrix with one more rows than in input.
% This is the conversion from inhomogenous to homogenous coordinates.
%
% Output:
%  y - NxM homogeneous coordinates
%
% Input:
%  x   - (N-1)xM inhomogeneous coordinates
%  rho - can be
%        * undefined: vectors are augmented with 1, as the normal
%          case 
%        * scalar: all vectors are augmented with the constant rho 
%        * row vector: vectors are augmented with respective rho
%          elements 
%
% Author(s):
%  Pekka Paalanen, MVPR in 2009.
%
% Project:
%  -
%
% Copyright:
%   -
%
% References:
%  [1] Hartley, R., Zisserman, A., Multiple View Geometry in
%  Computer Vision, 2nd ed, Cambridge Univ. Press, 2003.
%
% See also MVPR_H2D_TRANS.M .
%%
function y = mvpr_unproject(x, rho);

if nargin < 2
	rho = 1;
end

N = size(x, 2);

if length(rho) == 1
	y = [x; (rho * ones(1, N))];
else
	y = [x; rho];
end
