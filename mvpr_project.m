%MVPR_PROJECT - Divide column vectors by their last element
%
% [y] = project(x)
%
% Returns a matrix with one less row than in input.
% This is the conversion from homogenous to inhomogenous coordinates.
%
% Output:
%  y - (N-1)xM inhomogeneous coordinates
%
% Input:
%  x - NxM homogeneous coordinates
%
% Author(s):
%    Pekka Paalanen, MVPR in 2009.
%
% Project:
%  HomoGr (http://www.it.lut.fi/project/homogr/)
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

%
function y = mvpr_project(x);

N = size(x, 1) - 1;
y = x(1:N, :) ./ repmat(x(N+1, :), N, 1);
