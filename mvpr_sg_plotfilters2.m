%MVPR_SG_PLOTFILTERS2 Displays Gabor filter bank
%
% sg_plotfilters(N, fmax, m, n)
%
% This function displays a Gabor filter bank in frequency space.
% It is mainly meant to be called from sg_createfilterbank
% with verbose option.
%
% Output:
%  -
%
% Input:
%   N - size of the image, [height width].
%   fmax - frequency of the highest frequency filter
%   m - number of filter frequencies.
%   n - number or filter orientations
%
% Optional arguments are
%   k         - factor for selecting filter frequencies
%               (1, 1/k, 1/k^2, 1/k^3...), default is sqrt(2)
%   p         - crossing point between two consecutive filters, 
%               default 0.5
%   gamma     - gamma of the filter
%   eta       - eta of the filter
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
function mvpr_sg_plotfilters2(N,fmax,m,n,varargin)

conf = struct(...,
       'gamma',0, ...
       'eta',0,...
       'k',sqrt(2),...
       'p',0.5 ...
       );
       
       
conf = mvpr_getargs(conf, varargin);     
       
[gamma_,eta_]=mvpr_sg_solvefilterparams(conf.k, conf.p,m,n);

if conf.gamma==0,
  conf.gamma=gamma_;
end;

if conf.eta==0
  conf.eta=eta_;
end;

f=fmax*conf.k.^-(0:(m-1));

o=(0:(n-1))*pi/n;

%N=200

map=zeros(N(1),N(2));

count=1;
for ff=f
  for oo=o %+ pi + pi/no
    % be verbose
    fprintf('Preparing filter bank for display, %d/%d\r',count,length(f)*length(o));
    count=count+1;
    
    % create the filter and prepare the display
    g=mvpr_sg_createfilterf2(ff,oo,conf.gamma,conf.eta,N);
    map=map+g;
  
  end;
end;
fprintf('Preparing filter bank for display, done.    \n');

imagesc(fftshift(max(max(map))-map)); colormap(gray); drawnow

tick=get(gca,'YTick');
set(gca,'YTickLabel',1-tick/max(tick)-0.5);
tick=get(gca,'XTick');
set(gca,'XTickLabel',tick/max(tick)-0.5);
