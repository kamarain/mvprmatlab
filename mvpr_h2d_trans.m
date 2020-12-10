%MVPR_H2D_TRANS 2-D homography transformation
%
% [Xn] = mvpr_h2d_trans(X_,H_)
%
% Transform 2-D coordinates X_ using the transformation matrix H_.
%
% Output:
%  Xn - 2xN (inhomogeneous) or 3xN (homogeneous) coordinates
%
% Input:
%  X - 2xN (inhomogeneous) or 3xN (homogeneous) coordinates
%  H - 3x3 transform matrix (ref. [1])
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
%  [1] Hartley, R., Zisserman, A., Multiple View Geometry in
%  Computer Vision, 2nd ed, Cambridge Univ. Press, 2003.
%
% See also MVPR_H2D_<ISO,SIM,AFF,PRO>.M .
%%
function [Xn] = mvpr_h2d_trans(X_, H_);

%
% Construct homogeneous vectors if not
if (size(X_,1) == 2)
  % non-homogenous (return same)
  Xn = H_*[X_; ones(1,size(X_,2))];
  Xn = Xn(1:2,:)./[ Xn(3,:); Xn(3,:) ];
else
  % homogenous (return same)
  Xn = H_*X_;
end;
