%MVPR_SG_RESP2SAMPLEMATRIX Response to sample matrix structure
%
%   m = sg_resp2samplematrix(r)
%
% Converts response structure returned by sg_filterwithbank to a
% matrix more suitable for e.g. using with classifiers. 
%
% If responses were computer for all points, a [height x width x
% filter_values] matrix will be created. Filter values are arranged in
% [f1o1 f1o2 ... f2o1 f2o2 ... ] order. If responses for only some
% points were computer, matrix will be of format 
% [point x filter_values].
%
% Output:
%  m - Normalised responses.
%
% Input:
%  -
% <optional>
%   'normalize' - set to 1 to normalize responses. For info on 
%                 normalization see mvpr_sg_normalizesamplematrix()
%
% Example:
%   s = sg_resp2samplematrix(r,'normalize',1);
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
% See also MVPR_SG_FILTERWITHBANK.M, MVPR_SG_SCALESAMPLES.M,
% MVPR_SG_ROTATESAMPLES.M and MVPR_SG_NORMALIZESAMPLEMATRIX.M .
%
function meh=mvpr_sg_resp2samplematrix(r,varargin)

conf=struct(...
     'normalize',0 ...
         );
     
conf = mvpr_getargs(conf, varargin);     
     
nf=length(r.freq);
of=length(r.freq{1}.resp(:,1,1));

n=size(r.freq{1}.resp);


% handle case with responses from all points
if length(n)==3
  meh=zeros(n(2),n(3),nf*of);
  
  for i=1:nf
    for u=1:of
      meh(:,:,(i-1)*of+(u-1) + 1)=r.freq{i}.resp(u,:,:);
    end;
  end;
  if conf.normalize>0,
    meh=(1./repmat(sqrt(sum(abs(meh).^2,3)),[1,1,nf*of])).*meh;
  end;
  return;
end;

% case with only some responses
if length(n)==2
  meh=zeros(n(2),nf*of);
  
  for i=1:nf
    for u=1:of
      meh(:,(i-1)*of+(u-1) + 1)=r.freq{i}.resp(u,:);
    end;
  end;
  if conf.normalize>0,
    meh=(1./repmat(sqrt(sum(abs(meh).^2,2)),[1,nf*of])).*meh;
  end;
  return;
end;

error('Could not decipher response structure');


