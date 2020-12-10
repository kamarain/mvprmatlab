%MVPR_HND_TRANS N-D homography transformation
%
% [Xn] = mvpr_hnd_trans(X_,H_)
%
% Transform N-D coordinates X_ using the transformation matrix H_.
%
% Output:
%  Xn - DxN (inhomogeneous) or (D+1)xN (homogeneous) coordinates
%
% Input:
%  X - DxN (inhomogeneous) or (D+1)xN (homogeneous) coordinates
%  H - (D+1)x(D+1) transform matrix (2D and 3D in ref. [1])
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
function [Xn] = mvpr_hnd_trans(X_, H_);

D = size(H_,1)-1;

%
% Construct homogeneous vectors if not
if (size(X_,1) == D)
  % non-homogenous (return same)
  Xn = H_*[X_; ones(1,size(X_,2))];
  Xn = Xn(1:D,:)./repmat(Xn(D+1,:),[D 1]);
else
  % homogenous (return same)
  Xn = H_*X_;
end;
