%MVPR_H2D_SIM Construct 2-D homography matrix restricted to 
%(orientation preserving) similarity transformation
%
% [H_S] = mvpr_h2d_sim(theta_,t_,s_)
%
%
% Output:
%   H_S - 3x3 matrix of similarity transformation
%
% Input:
%  Transformation parameters (according to refs. [1-2]):
%   theta - 1x1 Rotation angle, in degrees
%       t - 2x1 Translation vector [tx ty]
%       s - 1x1 Isotropic (same for both coordinates) scale
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
%%
function [H_S] = mvpr_h2d_sim(theta_, t_, s_);

% Convert to radians
theta = theta_*pi/180;

% Rotation matrix
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
t = [t_(1) t_(2)]';
H_S = [ s_*[R; 0 0] [t; 1]];
