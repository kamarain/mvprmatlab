%MVPR_H2D_AFF Construct 2-D homography matrix restricted to 
%affinity transformation
%
% [H_A] = mvpr_h2d_aff(theta_,t_,delta1_,delta2_,phi_)
%
% Output:
%   H_A - 3x3 matrix of affine transformation
%
% Input:
%  Transformation parameters (according to refs. [1-2]):
%   theta - 1x1 Rotation angle, in degrees
%       t - 2x1 Translation vector [tx ty]
%  delta1 - 1x1 scale to direction 1 (phi)
%  delta2 - 1x1 scale to direction 2 (phi+90)
%     phi - 1x1 scale angle, in degrees
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
%  [1] Kamarainen, J.-K., Paalanen, P., Experimental study on Fast
%  2D Homography Estimation From a Few Point Correspondence,
%  Research Report, Machine Vision and Pattern Recognition Research
%  Group, Lappeenranta University of Technology, Finland, 2008.
%
%  [2] Hartley, R., Zisserman, A., Multiple View Geometry in
%  Computer Vision, 2nd ed, Cambridge Univ. Press, 2003.
%
% See also MVPR_H2D_TRANS.M .
%
function [H_A] = mvpr_h2d_aff(theta_,t_,delta1_,delta2_,phi_);

% Convert to radians
theta = theta_*pi/180;
phi = phi_*pi/180;

% Rotation matrix
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
t = [t_(1) t_(2)]';

D = [delta1_ 0; 0 delta2_];
Rphi = [cos(phi) -sin(phi); sin(phi) cos(phi)];

% Final results composed of isometry part and
% non-isotropic scaling part
A = R * Rphi' * D * Rphi;
H_A = [[A; 0 0] [t; 1]];
