%MVPR_NORMALIZESAMPLEMATRIX Sample matrix normalisation
%
%   m = sg_normalizesamplematrix(m)
%
% Normalizes sample matrix for illumination invariance. Each sample 
% (Gabor responses for one point in all frequencies and rotations) is
% normalized so that norm(sample)==1.
%
% Output:
%  m - Normalized sample matrix.
%
% Input:
%  m - Original sample matrix.
%
% Author(s):
%    Jarmo Ilonen, MVPR
%
% Project:
%  SimpleGabor (http://www2.it.lut.fi/project/simplegabor/)
%
% Copyright:
%
%   Simple Gabor Toolbox (mvpr_sg_* ) is Copyright
%   (C) 2006-2010 by Jarmo Ilonen and Joni-Kristian Kamarainen.
%
% References:
%  [1] Ilonen, Jarmo, "Supervised local image feature detection",
%  PhD Thesis, Dept. of Information Technology, Lappeenranta
%  University of Technology, 2007.
%
% See also MVPR_SG_RESP2SAMPLEMATRIX.M .
%
function meh=mvpr_sg_normalizesamplematrix(meh)

n=size(meh);

featlen=n(end);

if length(n)==3
  meh=(1./repmat(sqrt(sum(abs(meh).^2,3)),[1,1,featlen])).*meh;
  return;
end;


if length(n)==2
  meh=(1./repmat(sqrt(sum(abs(meh).^2,2)),[1,featlen])).*meh;
  return;
end;

error('Could not decipher response structure');


