% [SM] = MVPR_FEATURE_MATCHMATRIX(D1, D2) Local region descriptor matching
%
% [sm] = mvpr_feature_matchmatrix(D1,D2,:)
%
% Matches feature descriptors D1 to D2 and returns the distance
% matrix sm .
%
% Output:
%  sm    - NxN Match matrix between N descriptors.
%
% Input:
%  D1    - DxN matrix of D-dim descriptors for N points.
%  D2    - DxN matrix of D-dim descriptors for N points.
%
%  <optional>
% 'hamming' - Use Hamming distance (Def. false)
%             * used for backward compatibility, correct use is via
%             the method option (false is ingored and true
%             overrides the method option)
% 'method'  - Matching method:
%             'L2'      : L2-norm distance (default)
%             'hamming' : Hamming distance
%             'sg'      : Simple Gabor -> mvpr_sg_descriptor_match()
%                         requires sgS structure
% 'sgS'     - Simple Gabor structure (required for method=sg)
%
% Author(s):
%    Jukka Lankinen, TUT-SGN 2014
%    Joni Kamarainen, TUT-SGN 2014
%
% Project:
%  Object3D2D
%
% Copyright:
%
%   Copyright (C) 2011 by the authors.
%
% References:
%  [1] -
%
% See also MVPR_FEATURE_EXTRACT.M .
%
function [scorematrix] = mvpr_feature_matchmatrix(descr1, descr2, varargin)	

% Parse input arguments
conf = struct('hamming', false,...
              'method', 'L2',...
              'sgS', []);
conf = mvpr_getargs(conf, varargin);

% For backward compatibility overrides method
if conf.hamming
  conf.method = 'hamming';
end;

%
% Hamming distance (binary descriptors)
%
if (strcmp(conf.method,'hamming'))
  % convert to binary
  bdescr1 = [''];
  bdescr2 = [''];
  for a = 1:size(descr1,2)
    % Calculate the hamming distance matrix
    dec1 = descr1(:,a);
    bin1 = [];
    for i = 1:length(dec1)
      %if(d1(i) > 255 || d2(i) > 255)
      %	error('The binary values over 8 bits! Fix this.');
      %end
      bin1 = [bin1 dec2bin(dec1(i),8)];
      %bin2 = [bin2 dec2bin(d2(i),8)];
    end
    bdescr1(:,a) = bin1;
  end
  for b = 1:size(descr2,2)
    % Calculate the hamming distance matrix
    dec1 = descr2(:,b);
    bin1 = [];
    for i = 1:length(dec1)
      %if(d1(i) > 255 || d2(i) > 255)
      %	error('The binary values over 8 bits! Fix this.');
      %end
      bin1 = [bin1 dec2bin(dec1(i),8)];
      %bin2 = [bin2 dec2bin(d2(i),8)];
    end
    bdescr2(:,b) = bin1;
    
  end
  for a = 1:size(bdescr1,2)
    for b = 1:size(bdescr2,2)
      %d1 = bdescr1(:,a);
      %d2 = bdescr2(:,b);
      %% Calculate the hamming distance matrix
      %bin1 = [];
      %bin2 = [];
      %for i = 1:length(d1)
      %	if(d1(i) > 255 || d2(i) > 255)
      %		error('The binary values over 8 bits! Fix this.');
      %	end
      %	bin1 = [bin1 dec2bin(d1(i),8)];
      %	bin2 = [bin2 dec2bin(d2(i),8)];
      %end
      scorematrix(a,b) = sum((bdescr1(:,a) - bdescr2(:,b)) ~= 0);
    end
  end
end;

%
% L2 (Euclidean) distance
%
if (strcmp(conf.method,'L2'))
  % Create signed integers
  x = double(descr1)';
  y = double(descr2)';
  
  u=~isnan(y); y(~u)=0;
  v=~isnan(x); y(~v)=0;
  scorematrix = abs(x.^2*u'+v*y'.^2-2*x*y');
end

%
% Simple Gabor structure distance
%
if (strcmp(conf.method,'sg'))
  if (isempty(conf.sgS))
    error('You need to provide a valid sgS structure!');
  end;
  [m,p,D] = mvpr_sg_descriptor_match(transpose(descr1),...
                                     transpose(descr2),...
                                     conf.sgS);
  scorematrix = D;
end;


%% Another way to calculate the distance matrix
%x = x';
%y = y';
%
%% Calculate distances between descriptors
%i = repmat(x,1,size(y,2));
%j = y(:, ceil([1:size(y,2)*size(x,2)]/size(x,2)));
%scorematrix = reshape(sum((i-j).^2),size(x,2), size(y,2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation explained:
%     i             j
% 1 12 1 12     5 5 16 16
% 2 13 2 13  -  6 6 17 17
% 3 14 3 14     7 7 18 18
% 4 15 4 15     8 8 19 19
% 
%            =
%        sum(ans .^2)
% 
% Used reshape to have the correct matrix form

% The slowest way to calculate the distance matrix
% Use this to check the correctness if some modifications are made
%scorematrix2 = zeros(size(scorematrix));
%for a = 1:size(descr1,2)
%	for b = 1:size(descr2,2)
%		[v s] = vl_ubcmatch(descr1(:,a),descr2(:,b));
%		scorematrix2(a,b) = s;
%	end
%end
%scorematrix == scorematrix2

end

