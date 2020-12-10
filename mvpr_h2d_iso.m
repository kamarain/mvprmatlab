%MVPR_H2D_ISO Construct 2-D homography matrix restricted to 
%(orientation preserving) isometry transformation
%
% [H_E] = h2d_iso(theta_,t_)
%
%
% Output:
%   H_E - 3x3 matrix of isometry transformation
%
% Input:
%  Transformation parameters (according to ref. [1]):
%   theta - 1x1 Rotation angle, in degrees
%       t - 2x1 Translation vector [tx ty]
%
% Author(s):
%    Joni Kamarainen, MVPR in 2009.
%
% Project:
%  HomoGr (http://www.it.lut.fi/project/homogr/)
%
% Copyright:
%
%   Homography estimation toolbox (mvpr_h[23n]d_* ) is Copyright
%   (C) 2008 by Joni-Kristian Kamarainen.
%
% References:
%
%  [1] Hartley, R., Zisserman, A., Multiple View Geometry in
%  Computer Vision, 2nd ed, Cambridge Univ. Press, 2003.
%
% See also MVPR_H2D_TRANS.M .
%
function [H_E] = mvpr_h2d_iso(theta_,t_);

% Convert to radians
theta = theta_*pi/180;

% Rotation matrix
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
t = [t_(1) t_(2)]';
H_E = [ [R; 0 0] [t; 1]];
