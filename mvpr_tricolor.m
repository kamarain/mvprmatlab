function [C] = tricolor(S,type,ls,system)
% [C] = tricolor(S,'type','ls',system)
%
% TRICOLOR calculates and converts color coordinates
% into different color coordinate systems.
%
% S      = Color coordinates in some color coordinate system.
% type   = Color coordinate system of S. Possible strings are:
%          'xyY','XYZ','RGB','upvpY','Lab','Luv'.
% ls     = Light source. Possible strings are: 'A','B','C','D65'.
% system = 1931, 31, 2  = CIE 1931 system,
%          1964, 64, 10 = CIE 1964 system.
%	
% OUTPUT:  C(1:3,:)     xyz      Chromaticity coordinates
%          C(4:6,:)     XYZ      Tristimulus values
%          C(7:9,:)     RGB      Tristimulus values
%          C(10:12,:)   L*a*b*   CIELAB 1976
%          C(13:14,:)   u'v'     CIE 1976 UCS diagram
%          C(15:16,:)   u*v*     CIELUV (1976),  L* = C(10,:)
%
% See also: COLORS, CSPACE.


% Creator : Seppo Leppajarvi
% email   : seppo.leppajarvi@lut.fi

% If TRICOLOR gives an error message of non-agreeing matrix sizes,
% usually there has been divisions by zero. Check Y or L coordinates
% of your input coordinates, zeros in there are the most probable
% causes of errors.

if nargin < 3 ls = 'D65'; end;
ls = upper(ls);

if nargin < 4 system = 1931; end;
if isstr(system) system = str2num(system); end;
if (system == 1964 | system == 64 | system == 10)
  system = 1964;
else
  system = 1931;
end;

% Set position of reference white (calc. from 380:10:780)
if system == 1931
  if strcmp(ls(1),'A')      X0 = 109.83;  Y0 = 100;  Z0 =  35.55;
  elseif strcmp(ls(1),'B')  X0 =  99.07;  Y0 = 100;  Z0 =  85.22;
  elseif strcmp(ls(1),'C')  X0 =  98.04;  Y0 = 100;  Z0 = 118.10;
  elseif strcmp(ls,'D65')   X0 =  95.02;  Y0 = 100;  Z0 = 108.81;
  else                      X0 =  95.02;  Y0 = 100;  Z0 = 108.81;
  end;
else % (calc. from 380:5:780)
  if strcmp(ls(1),'A')      X0 = 111.15;  Y0 = 100;  Z0 =  35.20;
  elseif strcmp(ls(1),'B')  X0 =  99.19;  Y0 = 100;  Z0 =  84.36;
  elseif strcmp(ls(1),'C')  X0 =  97.28;  Y0 = 100;  Z0 = 116.14;
  elseif strcmp(ls,'D65')   X0 =  94.81;  Y0 = 100;  Z0 = 107.33;
  else                      X0 =  94.81;  Y0 = 100;  Z0 = 107.33;
  end;
end;

% XYZ -> RGB matrix
M = [ 2.3647   -0.8966   -0.4681;
     -0.5153    1.4264    0.0888;
      0.0052   -0.0144    1.0092];

% %%%% CONVERT INPUT VALUES INTO XYZ COORDINATES %%%%%%%%%%%%
if strcmp(type,'xyY')
  X = (S(1,:) ./ S(2,:)) .* S(3,:);
  Y = S(3,:);
  Z = ((1-S(1,:)-S(2,:)) ./ S(2,:)) .* S(3,:);

elseif strcmp(type,'upvpY')
  x = 27 * S(1,:) ./ (18*S(1,:) - 48*S(2,:) + 36);
  y = 12 * S(2,:) ./ (18*S(1,:) - 48*S(2,:) + 36);
  Y = S(3,:);
  X = (x ./ y) .* Y;
  Z = ((1-x-y) ./ y) .* Y;

elseif strcmp(type,'XYZ')
  X = S(1,:);  Y = S(2,:);  Z = S(3,:);

elseif strcmp(type,'RGB')
  XYZ = inv(M) * S;
  X = XYZ(1,:);
  Y = XYZ(2,:);
  Z = XYZ(3,:);

elseif strcmp(type,'Lab')
  Ledge = 903.292*0.008856;
  L = S(1,:);
  a = S(2,:);
  b = S(3,:);
  
  F = find(L > Ledge);
  if ~isempty(F)
    Y(F) = ((L(F) + 16) / 116).^3 * Y0;
    YY(F) = (Y(F) / Y0).^(1/3);
  end;
  F = find(L <= Ledge);
  if ~isempty(F)
    Y(F) = (L(F)*Y0) / 903.292;
    YY(F) = 7.787 * (Y(F)/Y0) + (16/116);
  end;
  
  X = (a/500 + YY).^3 * X0;
  Z = (YY - b/200).^3 * Z0;
  C = tricolor([X;Y;Z],'XYZ',ls);
  
  F = find(C(11,:) < a-10^(-13) | C(11,:) > a+10^(-13));
  if ~isempty(F)
    X(F) = (a(F)/500 + YY(F) - (16/116)) / 7.787 * X0;
  end;
  F = find(C(12,:) < b-10^(-13) | C(12,:) > b+10^(-13));
  if ~isempty(F)
    Z(F) = (YY(F) - b(F)/200 - (16/116)) / 7.787 * Z0;
  end;

elseif strcmp(type,'Luv')
  Ledge = 903.292*0.008856;
  L  = S(1,:);
  ut = S(2,:);
  vt = S(3,:);

  up0 = 4*X0 / (X0 + 15*Y0 + 3*Z0);
  vp0 = 9*Y0 / (X0 + 15*Y0 + 3*Z0);
  
  I = find(L > Ledge);
  if ~isempty(I)
    Y(I) = ((L(I)+16)/116 ).^3 * Y0;
  end;
  I = find(L <= Ledge);
  if ~isempty(I)
    Y(I) = L(I) / 903.292 * Y0;
  end;  
  up = ut ./ (13*L) + up0;
  vp = vt ./ (13*L) + vp0;

  x = 27 * up ./ (18*up - 48*vp + 36);
  y = 12 * vp ./ (18*up - 48*vp + 36);
  X = (x ./ y) .* Y;
  Z = ((1-x-y) ./ y) .* Y;
end;


% CALCULATION OF COLOR COORDINATES

% %%%%%%%%% Relative XYZ coordinates %%%%%%%%%%%%%%%%%%%%%
div = X + Y + Z;
x = X./div;
y = Y./div;
z = Z./div;

% %%%%%%%%% RGB coordinates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R =  2.3647*X - 0.8966*Y - 0.4681*Z;
G = -0.5153*X + 1.4264*Y + 0.0888*Z;
B =  0.0052*X - 0.0144*Y + 1.0092*Z;

% %%%%%%%%% CIELAB coordinates %%%%%%%%%%%%%%%%%%%%%%%%%%%
FX = X/X0;
FY = Y/Y0;
FZ = Z/Z0;

I = find(FY > 0.008856);
if ~isempty(I)
  Lt(I) = 116 * FY(I).^(1/3) - 16.0;
  YY(I) = FY(I).^(1/3);
end
I = find(FY <= 0.008856);
if ~isempty(I)
  Lt(I) = 903.292 * FY(I);
  YY(I) = (7.787 * FY(I) + 16/116);
end

I = find(FX > 0.008856);
if ~isempty(I)
  XX(I) = FX(I).^(1/3);
end
I = find(FX <= 0.008856);
if ~isempty(I)
  XX(I) = (7.787 * FX(I) + 16/116);
end

I = find(FZ > 0.008856);
if ~isempty(I)
  ZZ(I) = FZ(I).^(1/3);
end
I = find(FZ <= 0.008856);
if ~isempty(I)
  ZZ(I) = (7.787 * FZ(I) + 16/116);
end

at = 500 * (XX - YY);
bt = 200 * (YY - ZZ);

% %%%%%%%%% CIELUV co-ordinates %%%%%%%%%%%%%%%%%%%%%%%%%%%
up = 4*X ./ (X + 15*Y + 3*Z);     % up = 4*x ./ (-2*x + 12*y + 3);
vp = 9*Y ./ (X + 15*Y + 3*Z);     % vp = 9*y ./ (-2*x + 12*y + 3);

up0 = 4*X0 / (X0 + 15*Y0 + 3*Z0);
vp0 = 9*Y0 / (X0 + 15*Y0 + 3*Z0);

ut  = 13 * Lt .* (up - up0);
vt  = 13 * Lt .* (vp - vp0);

% %%%%%%%%% Construct output matrix %%%%%%%%%%%%%%%%%%%%%%%
C = [x;y;z;X;Y;Z;R;G;B;Lt;at;bt;up;vp;ut;vt]; 
