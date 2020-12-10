%MVPR_SG_FILTERWITHBANK - Gabor filtering with filterbank (special)
%
%    !!!! EXPERIMENTAL VERSION FOR SPECIAL PURPOSES !!!!
%
% This is an alternate version of SG_FILTERWITHBANK which computes
% responses of each filter frequency scaled to as low resolution as
% possible. Amplitudes of responses are normalized (unlike with
% SG_FILTERWITHBANK). 
%
% Note that other functions working with response structure 
% returned by SG_FILTERWITHBANK do not work because the resolutions
% are not the same for all filters.
%
% See MVPR_SG_FILTERWITHBANK.M for more details on parameter which
% may not be all supported by this function!
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
% See also MVPR_SG_FILTEWITHBANK.M .
%
function [m]=mvpr_sg_filterwithbank2(s, bank, varargin)

conf = struct(...,
       'points',[], ...
       'domain',0, ...
       'max_zoom',0 ...
       );

conf = mvpr_getargs(conf, varargin);

[N(2) N(1)]=size(s);

m.N=[N(2) N(1)];

% downscale as much as possible separately for every filter
  
for find=1:length(bank.freq)
	m.zoom(find)=0.5/bank.freq{find}.orient{1}.fhigh;

	if conf.max_zoom>0 && m.zoom(find)>conf.max_zoom
  		m.zoom(find)=conf.max_zoom;
	end;   
  
  	if m.zoom(find)<1
		printf('Zoom factor smaller than 1, wtf?\n');
		m.zoom(find)=1;
	end;    

	% the responsesize is always wanted to be divisible by two
   	m.respSize(find,:)=round(N/m.zoom(find)/2)*2; 
    
	% actual zoom factor
	m.actualZoom(find,:)=(N./m.respSize(find));
      
end;


% perform the filtering

fs=fft2(ifftshift(s));
  
% the loop for calculating responses at all frequencies
  
for find=1:length(bank.freq),
    	f0=bank.freq{find}.f;
    
    	m.freq{find}.f=f0;
        
    	% zero memory for filter responses, each frequency is of different size now 
    	if isempty(conf.points)
      		m.freq{find}.resp=zeros(length(bank.freq{find}.orient),m.respSize(find,2),m.respSize(find,1));
    	end;      
    
    	% loop through orientations
    	for oind=1:length(bank.freq{find}.orient),
      
      		a= bank.freq{find}.orient{oind}.envelope;
      		fhigh=bank.freq{find}.orient{oind}.fhigh;
      
      		m.freq{find}.zoom=m.zoom(find);
        	f2_=zeros(m.respSize(find,2),m.respSize(find,1));
        
        	lx=a(2)-a(1);
        	ly=a(4)-a(3);

        	% coordinates for the filter area in filtered fullsize image
        	xx=mod( (0:lx) + a(1) + N(1) , N(1) ) + 1;
        	yy=mod( (0:ly) + a(3) + N(2) , N(2) ) + 1;
        
        	% coordinates for the filter area in downscaled response image
        	xx_z=mod( (0:lx) + a(1) + m.respSize(find,1) , m.respSize(find,1) ) + 1;
        	yy_z=mod( (0:ly) + a(3) + m.respSize(find,2) , m.respSize(find,2) ) + 1;
 
        	% filter the image
        	f2_(yy_z,xx_z) = bank.freq{find}.orient{oind}.filter .* fs(yy,xx);
        
      		% set the responses to response matrix and normalize amplitudes for the zoom factor
      		m.freq{find}.resp(oind,:,:)=fftshift(ifft2(f2_))./prod(m.actualZoom(find,:));
        end;    

end;

