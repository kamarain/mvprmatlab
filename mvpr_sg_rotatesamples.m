%MVPR_SG_ROTATESAMPLES Rotate samples (shift in orientation)
%
%   m = sg_rotatesamples(matr,rot,n)
%
% Rotates samples in sample matrix for rotation invariance. 
%
% Output:
%  -
%
% Input:
%   matr  - Sample matrix, either two or three dimensional
%   rot   - Rotation. How many steps the responses are rotated.
%           Usually values [0,n-1] should be used but any
%           integer value, also negative values, will work.
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
% See also MVPR_SG_RESP2SAMPLEMATRIX and MVPR_SG_SCALESAMPLES
%
function feh=sg_rotatesamples(matr,rot,norient)

dim=ndims(matr);

ntotal=size(matr,dim);

if mod(ntotal,norient)~=0
  error('sg_rotatesamples:invalid_matrix','Invalid number of orientations');
end,

ind=0:ntotal-1; % indexes
find=floor(ind/norient); % frequencies

rind=mod(ind,norient)-rot;  % orientations and the shift

new_ind=find*norient+mod(rind,norient); % new indexes after rotation

% the indexes that "wrap" and are complex conjugates of the current values
wrap_ind=new_ind( mod(rind,norient*2) >= norient )+1;

if dim==2
  feh(:,new_ind+1)=matr; 

  feh(:,wrap_ind)=conj(feh(:,wrap_ind));

end;

if dim==3
  feh(:,:,new_ind+1)=matr;
  feh(:,:,wrap_ind)=conj(feh(:,:,wrap_ind));
end;

