function [C] = colors(spec,lsource,system)

% [C] = colors(spec,'lsource',system)
%
% COLORS calculates color coordinates for input spectra.
% Wavelengths outside colorimetric range [360 nm, 830 nm] ignored.
% Linear interpolation is used, if wavelengths with decimal part are
% encountered.
%
% spec     = input spectra, the 1st column is wavelength (nm)
%            and the rest of the columns are color spectra.
%            Use relative values (0=0%, 1=100% reflectance).
% lsource  = Light source. Available source types are:
%            'A'  'B'  'C'  'D65'  (D65 default).
% system   = Color-matching functions to use:
%            1931 - CIE 1931 Std Colorim System (2-degree curves), default.
%            1964 - CIE 1964 Suppl Std Colorim System (10-degree curves).
%	
% OUTPUT:    C(1:3,:)     xyz      Chromaticity coordinates
%            C(4:6,:)     XYZ      Tristimulus values
%            C(7:9,:)     RGB      Tristimulus values
%            C(10:12,:)   L*a*b*   CIELAB 1976
%            C(13:14,:)   u'v'     CIE 1976 UCS diagram
%            C(15:16,:)   u*v*     CIELUV (1976),  L* = C(10,:)
%
% See also: TRICOLOR, CSPACE.


% Creator : Seppo Leppajarvi
% Email   : seppo.leppajarvi@lut.fi
%
% This program comes with absolute NO WARRANTY!

% NOTE 1: B and C light source curves are interpolated from 5nm
% inverval curves to 1nm interval curves)
%
% NOTE 2: Commented out of program
%            C(17:19,:)   uvw      CIE 1960 UCS diagram
%            C( 20  ,:)   w'       CIE 1976 UCS diagram (w' = 1-u'-v')
%            C(21:23,:)   UVW      Tristimulus values
%            C(24:26,:)   U*V*W*   CIEUVW (1960)


% %%%%%%%%% GET PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%

% Select light source, default is D65 (last column in lso matrix)
load resources/ls_abcd.dat; lso = ls_abcd;
if nargin < 2 lsource = 'D65'; end;
lsource = upper(lsource);

if(strcmp(lsource(1), 'A'))      lcol = 2;
elseif (strcmp(lsource(1), 'B')) lcol = 3;
elseif (strcmp(lsource(1), 'C')) lcol = 4;
elseif (strcmp(lsource, 'D65'))  lcol = 5;
else                             lcol = 5;
end;

% Select color-matching functions from 1931 or 1964 System.
if nargin < 3 system = 1931; end;
if isstr(system) system = str2num(system); end;
if (system == 1964 | system == 64 | system == 10)
  load resources/xyz1964.dat; st = xyz1964;
else
  load resources/xyz1931.dat; st = xyz1931;
end;

% %%%%%%%% PRE-PROCESSING OF THE INPUT SPECTRA %%%%%%%%%%%%%%%%%

% 1) Remove duplicate wavelengths, sort spectra into
%    acsending wavelength order.
[y,i] = sort(spec(:,1));
spec  = spec(i,:);
p = find(diff(y) == 0);
spec(p,:) = [];

% 2) Remove wavelengths outside tristimulus curves (outside 360-830nm)
l = size(spec,1);
spec(find((spec(:,1)-st(size(st,1),1))>0 | (spec(:,1)-st(1,1))<0),:) = [];
% spec(find((spec(:,1)-lso(size(lso,1),1))>0 | (spec(:,1)-lso(1,1))<0),:) = [];
if size(spec,1) ~= l
  disp(['COLORS: Wavelengths outside range [' int2str(st(1,1)) '..' ...
	int2str(st(size(st,1),1)) '] ignored.']);
end;

% 3) Select correct wavelengths from tristimulus curves and light sources
wave = spec(:,1);
if sum(abs(wave-round(wave))) > 0 % interpolation needed
  ciex  = interp1(st(:,1), st(:,2), wave);
  ciey  = interp1(st(:,1), st(:,3), wave);
  ciez  = interp1(st(:,1), st(:,4), wave);
  light = interp1(lso(:,1), lso(:,lcol), wave);
else                              % no interpolation needed
  lso   = lso(spec(:,1) - lso(1,1) + 1,:);
  light = lso(:,lcol);
  st    = st(spec(:,1)  - st(1,1)  + 1,:);
  ciex  = st(:,2);
  ciey  = st(:,3);
  ciez  = st(:,4);
end;


% CALCULATION OF COLOR COORDINATES

% %%%%%%%%%% Constants %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate exact values for reference white
if min(wave) < 420 & max(wave) > 680
  k = 100 / (ciey' * light);
  X0 = k * (ciex' * light);
  Y0 = 100;                 % Y0 = k * (ciey' * light);
  Z0 = k * (ciez' * light);
else  % Use precalculated values, if spectra too narrow
  if system == 1931 % (calc. from 380:10:780)
    if lcol == 2      X0 = 109.83;  Y0 = 100;  Z0 =  35.55;
    elseif lcol == 3  X0 =  99.07;  Y0 = 100;  Z0 =  85.22;
    elseif lcol == 4  X0 =  98.04;  Y0 = 100;  Z0 = 118.10;
    elseif lcol == 5  X0 =  95.02;  Y0 = 100;  Z0 = 108.81;
    else              X0 =  95.02;  Y0 = 100;  Z0 = 108.81;
    end;
  else % (calc. from 380:5:780)
    if lcol == 2      X0 = 111.15;  Y0 = 100;  Z0 =  35.20;
    elseif lcol == 3  X0 =  99.19;  Y0 = 100;  Z0 =  84.36;
    elseif lcol == 4  X0 =  97.28;  Y0 = 100;  Z0 = 116.14;
    elseif lcol == 5  X0 =  94.81;  Y0 = 100;  Z0 = 107.33;
    else              X0 =  94.81;  Y0 = 100;  Z0 = 107.33;
    end;
  end;
end;


% %%%%%%%%% CIE XYZ coordinates %%%%%%%%%%%%%%%%%%%%%%%%%%
k = 100 / (ciey' * light);
X = k * ( (ciex .* light)' * spec(:,2:size(spec,2)) );
Y = k * ( (ciey .* light)' * spec(:,2:size(spec,2)) );
Z = k * ( (ciez .* light)' * spec(:,2:size(spec,2)) );

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
  Lt(I) = 116 * FY(I).^(1/3) - 16;
  YY(I) = FY(I).^(1/3);
end
I = find(FY <= 0.008856);
if ~isempty(I)
  Lt(I) = 903.292 * FY(I);
  YY(I) = 7.787 * FY(I) + 16/116;
end

I = find(FX > 0.008856);
if ~isempty(I)
  XX(I) = FX(I).^(1/3);
end
I = find(FX <= 0.008856);
if ~isempty(I)
  XX(I) = 7.787 * FX(I) + 16/116; 
end

I = find(FZ > 0.008856);
if ~isempty(I)
  ZZ(I) = FZ(I).^(1/3);
end
I = find(FZ <= 0.008856);
if ~isempty(I)
  ZZ(I) = 7.787 * FZ(I) + 16/116;
end

at = 500 * (XX - YY);
bt = 200 * (YY - ZZ);

% %%%%%%%%% CIELUV co-ordinates %%%%%%%%%%%%%%%%%%%%%%%%%%%
up = 4*X ./ (X + 15*Y + 3*Z);     % up   = 4*x ./ (-2*x + 12*y + 3);
vp = 9*Y ./ (X + 15*Y + 3*Z);     % vp   = 9*y ./ (-2*x + 12*y + 3);     

up0 = 4*X0 / (X0 + 15*Y0 + 3*Z0);
vp0 = 9*Y0 / (X0 + 15*Y0 + 3*Z0);

ut = 13 * Lt .* (up - up0);
vt = 13 * Lt .* (vp - vp0);

% %%%%%%%%% Modified XYZ co-ordinates %%%%%%%%%%%%%%%%%%%%%%%%%%%
% I = find(FY > 0.008856);
% if ~isempty(I) YY(I) = ( 116 * FY(I).^(1/3) - 16 ) / sqrt(3); end
% I = find(FY <= 0.008856);
% if ~isempty(I) YY(I) = (903.3 * FY(I)) / sqrt(3); end
%
% I = find(FX > 0.008856);
% if ~isempty(I) XX(I) = ( 116 * FX(I).^(1/3) - 16 ) / sqrt(3); end
% I = find(FX <= 0.008856);
% if ~isempty(I) XX(I) = (903.3 * FX(I)) / sqrt(3); end
%
% I = find(FZ > 0.008856);
% if ~isempty(I) ZZ(I) = ( 116 * FZ(I).^(1/3) - 16 ) / sqrt(3); end
% I = find(FZ <= 0.008856);
% if ~isempty(I) ZZ(I) = (903.3 * FZ(I)) / sqrt(3); end

% commented out of program
% wp   = 1 - (up + vp);
%
% u = 4*X ./ (X + 15*Y + 3*Z);     %u   = 4*x ./ (-2*x + 12*y + 3);
% v = 6*Y ./ (X + 15*Y + 3*Z);     %v   = 6*y ./ (-2*x + 12*y + 3);    
% w   = 1 - (u + v);
%
% u0 = 4*X0 / (X0 + 15*Y0 + 3*Z0);
% v0 = 6*Y0 / (X0 + 15*Y0 + 3*Z0);
%
% U = 2*X;
% V = Y;
% W = (-X + 3*Y + Z) / 2;
%
% Wt = 25*Y.^(1.0/3.0) - 17;
% Ut = 13*Wt .* (u - u0);
% Vt = 13*Wt .* (v - v0);

% %%%%%%%%% Construct output matrix %%%%%%%%%%%%%%%%%%%%%%%
%C = [x;y;z;X;Y;Z;R;G;B;Lt;at;bt;up;vp;ut;vt;XX;YY;ZZ]; 
C = [x;y;z;X;Y;Z;R;G;B;Lt;at;bt;up;vp;ut;vt]; 
