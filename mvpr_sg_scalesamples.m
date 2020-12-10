%MVPR_SG_SCALESAMPLES Scale samples (shift in frequency)
%
%   m = sg_scalesamples(matr,sc,m,n)
%
% Scales samples in sample matrix for scale invariance. Returns responses for
% nf frequencies (frequencies [r:nf+r] from the original sample matrix).
%
% Output:
%  -
%
% Input:
%   matr  - Sample matrix, either two or three dimensional
%   sc    - Scaling, how many steps the frequencies are shifted.
%           Extra frequencies must be specified with 
%           sg_createfilter(), and the value must be
%           [0,extra_freq].
%   m     - Number of usable frequencies in the sample matrix
%   n     - Number of orientations in the sample matrix
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
% See also MVPR_SG_*.M .
%
function feh=mvpr_sg_scalesamples(matr,sc,nf,norient)

dim=ndims(matr);

ntotal=size(matr,dim);

if mod(ntotal,norient)~=0
  error('sg_scalesamples:invalid_matrix','Invalid number of orientations');
end,

favail=ntotal/norient;

if nf+sc>favail~=0
  error('sg_scalesamples:invalid_matrix','Not enough frequencies available');
end,


ind=1:(nf*norient);
orig_ind=ind + sc*norient;

if dim==2
  feh=matr(:,orig_ind); 

end;

if dim==3
  feh=matr(:,:,orig_ind);
end;

