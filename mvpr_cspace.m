function [ha,CD] = cspace(type,f,C,n,cmode,idx,txt,hax);

% [ha,CD] = cspace('type',f,C,n,cmode,idx,txt,hax);
%   CSPACE plots standard CIE color spaces on screen.
%   If chromaticity plane is to be filled, CSPACE
%   needs file 'ciexy2.mat'.
%
%   'type' = Color space to plot. Possible strings are:
%            'xyY','upvpY','Lab','Luv'.
%    f     = Fill the chromaticity plane using color grid of size f^2.
%            Negative values use slow filling, zero means no filling.
%            Use slow filling if monitor can display 256 or less colors.
%    C     = Color coordinates of samples to plot.
%    n     = Plot style, see PLOT. n=1 plots sample numbers.
%    cmode = Coloring mode (0-6), see SRGB for more information.
%            0 uses neural net to create pleasing results (default).
%    idx   = Indexes of samples beside which the texts in TXT are written.
%    txt   = Texts to show beside samples in IDX.
%    hax   = Axis handles to which to plot.
%
%    ha(1) = axis handle to filled chromaticity plane.
%    ha(2) = axis handle to plane, where samples will be plotted.
%            (NOTE: type VIEW(3) to get 3D-view of this axis.)
%    ha(3) = axis handle to lightness-axis.
%    CD    = Color coordinates of spectral locus.
%            (Makes sense in xyY- and u'v'Y -spaces.)
%
% See also: COLORS, TRICOLOR, SRGB.

% Creator : Seppo Leppajarvi
% email   : seppo.leppajarvi@lut.fi

if nargin < 2 f     = 0;  end;
if nargin < 3 C     = []; end;
if nargin < 4 n     = '*';  end;
if nargin < 5 cmode = 0;  end;
if nargin < 6 idx   = []; end;
if nargin < 7 txt   = []; end;
if nargin < 8 hax   = []; end;

if f < 0  fast = 0; f = abs(f); else fast = 1; end;
if cmode == 0  pmode = 1;  else pmode = cmode; end;
if isstr(n) == 0
  if n == 0  n = '*'; else n = '1'; end;
end;
if size(C,1) == 3  C = tricolor(C,type); end;

% Create coordinate axes
if isempty(hax)
  clf;
  ha(1) = axes('Position',[0.10 0.11 0.6 0.815]);
  ha(2) = axes('Position',[0.10 0.11 0.6 0.815]);
  ha(3) = axes('Position',[0.80 0.11 0.1 0.815]);
else
  ha = hax;
  axes(ha(1)); hold on;
  axes(ha(2)); hold on;
  axes(ha(3)); hold on;
end;

% Calculate color coordinates of spectral locus
if strcmp(type,'xyY') | strcmp(type,'upvpY')
  wave = (360:5:830)';
  D = diag(diag(ones(length(wave))));
  CD = colors([wave D]);
end;

% Set initial values
if strcmp(type,'xyY')
  x = 1; y = 2; z = 5; z2 = z;
  xlab = 'x'; ylab = 'y'; zlab = 'Y'; z2lab = zlab;
  tit = 'CIE 1931 Chromaticity diagram';
elseif strcmp(type,'upvpY')
  x = 13; y = 14; z = 5; z2 = z;
  xlab = 'u'''; ylab = 'v'''; zlab = 'Y'; z2lab = zlab;
  tit = 'CIE 1976 UCS Chromaticity diagram';
elseif strcmp(type,'Lab')
  x = 11; y = 12; z = 10; z2 = z;
  xlab = 'a*'; ylab = 'b*'; zlab = 'L*'; z2lab = zlab;
  tit = 'CIE 1976 L*a*b* Color Space';
elseif strcmp(type,'Luv')
  x = 15; y = 16; z = 10; z2 = z;
  xlab = 'u*'; ylab = 'v*'; zlab = 'L*'; z2lab = zlab;
  tit = 'CIE 1976 L*u*v* Color Space';
elseif strcmp(type,'XYZ')
  x = 4; y = 6; z = 5; z2 = z;
  xlab = 'X'; ylab = 'Z'; zlab = 'Y'; z2lab = zlab;
  tit = 'XYZ-tristimulus values';
elseif strcmp(type,'RGB')
  x = 7; y = 8; z = 9; z2 = 10;
  xlab = 'R'; ylab = 'G'; zlab = 'B'; z2lab = 'L*';
  tit = '(CIE)RGB-ristimulus values';
elseif strcmp(type,'mXYZ')
  x = 17; y = 18; z = 19; z2 = z;
  xlab = 'XX'; ylab = 'YY'; zlab = 'ZZ'; z2lab = zlab;
  tit = 'Modified XYZ-tristimulus values';
end;

% Find extends
ext = [0 0 0 0 0 100];
if ~isempty(C)
  mini = 1; maxi = 1;
  if size(C,2) > 1
    [i,mini] = min(C([x y z],:)');
    [i,maxi] = max(C([x y z],:)');
  end;
  axes(ha(2)); view(3);
  h = plot3(C(x,[mini maxi]),C(y,[mini maxi]),C(z,[mini maxi]),'*');
  ext = get(gca,'Zlim');
  view(2);
  ext = [get(gca,'XLim') get(gca,'Ylim') ext];
  delete(h);
end;

if strcmp(type,'xyY')
  a1 = 0.001; a2 = 1;
  b1 = 0.001; b2 = 1;
  ext = [0 1 0 1 ext(5:6)];
elseif strcmp(type,'upvpY')
  a1 = 0.001; a2 = 0.64+0.001;
  b1 = 0.001; b2 = 0.6+0.001;
  ext = [0 0.7 0 0.65 ext(5:6)];
elseif strcmp(type,'Lab') | strcmp(type,'Luv') 
  if ~isempty(C)
    a1 = ext(1); a2 = ext(2);
    b1 = ext(3); b2 = ext(4);
  else
    a1 = -100; a2 = 100;
    b1 = -100; b2 = 100;
  end;
  ext = [a1 a2 b1 b2 ext(5:6)];
elseif strcmp(type,'XYZ') | strcmp(type,'RGB')
  if ~isempty(C)
    a1 = ext(1); a2 = ext(2);
    b1 = ext(3); b2 = ext(4);
  else
    a1 = 0; a2 = 100;
    b1 = 0; b2 = 100;
  end;
  ext = [a1 a2 b1 b2 ext(5:6)];
end;  

if f ~= 0
  astep = (a2 - a1) / f;
  bstep = (b2 - b1) / f;
end;

axes(ha(2));
view(2);
hold on;

% Plot spectral locus and wave numbers
if strcmp(type,'xyY') | strcmp(type,'upvpY')
  rgb = srgb(CD,pmode);
  for i = 2:size(CD,2)
    h = plot3(CD(x,i-1:i),CD(y,i-1:i),ext(5)*ones(1,2));
    set(h,'Color',rgb(:,i));
  end;
end;

if ~isempty(idx) & ~isempty(txt)
  if     ~isempty(C)  text(C(x,idx),C(y,idx),C(z,idx),txt);
  elseif ~isempty(CD) text(CD(x,idx),CD(y,idx),CD(z,idx),txt); end;  
end;

% Plot samples on color space
if ~isempty(C)
  rgb = srgb(C,pmode);
  
  if ~isempty(findstr('.ox+*',n))       % Plot single points
    if f ~= 0
      plot3(C(x,:),C(y,:),C(z,:),['w' n]);
    elseif f == 0
      for i = 1:size(C,2)
	h = plot3(C(x,i),C(y,i),C(z,i),n);
	set(h,'Color',rgb(:,i));
      end;
    end;
  elseif ~isempty(findstr('-:-.--',n))  % Plot continuous lines
    if f ~= 0
      plot3(C(x,:),C(y,:),C(z,:),['w' n]);
    elseif f == 0
      for i = 2:size(C,2)
	h = plot3(C(x,i-1:i),C(y,i-1:i),C(z,i-1:i),n);
	set(h,'Color',rgb(:,i));
      end;
    end;    
  elseif n == '1'            % Plot numbers
    if f ~= 0  r = ones(size(rgb));
    else r = rgb; end;
    for i = 1:size(C,2)
      h = text(C(x,i),C(y,i),C(z,i),int2str(i));
      set(h,'Color',r(:,i),'HorizontalAlignment','center');
    end;
  end;
  
  % Plot lightness axis
  axes(ha(3));
  view(2);
  hold on;

  if ~isempty((findstr('-:-.--',n)) & strcmp(n,'.') == 0)  n = '*'; end;
  if strcmp(n,'1') == 0    % Plot points
    for i = 1:size(C,2)
      h = plot(0.5,C(z2,i),n);
      set(h,'Color',rgb(:,i));
    end;
  else         % Plot numbers
    for i = 1:size(C,2)
      h = text(0.5,C(z2,i),int2str(i));
      set(h,'Color',rgb(:,i),'HorizontalAlignment','center');
    end;
  end;    
  
end;

% Fill chromaticity plane
if f ~= 0
  % Make grid over chromaticity plane, colors are calculated at grid cell
  % center points
  [X,Y] = meshgrid(a1:astep:a2-astep,b1:bstep:b2-bstep);
  [rx,cx] = size(X);
  gr = [X(:)+astep/2 Y(:)+bstep/2]';

  % Calculate x,y -coordinates at grid centers
  if strcmp(type,'Lab') | strcmp(type,'Luv')
    xy = tricolor([50*ones(1,size(gr,2)); gr],type);
  elseif strcmp(type,'upvpY') | strcmp(type,'xyY')
    xy = tricolor([gr; 50*ones(1,size(gr,2))],type);
  elseif strcmp(type,'XYZ')
    xy = tricolor([gr(1,:); 50*ones(1,size(gr,2)); gr(2,:)],type);
  elseif strcmp(type,'RGB')
    xy = tricolor([gr; ext(5)*ones(1,size(gr,2))],type);
  end;

  % Let neural net find RGB-coordinates corresponding x,y,1 -coordinates
  % and scale RGB-coordinates into range [0,1]
  if cmode == 0
    xy = [xy(1:2,:); ones(1,size(xy,2))];
    b1tmp = b1; b2tmp = b2; 
    load ciexy2
    RGB = simuff(xy,w1,b1,'tansig',w2,b2,'tansig');
    RGB(RGB<0) = zeros(sum(sum(RGB<0)),1); 
    b1 = b1tmp; b2 = b2tmp;
  else
    RGB = srgb(xy,pmode);
  end;  


  % Actual fill operation.
  axes(ha(1));
  view(2);
  hold on;
  
  if fast ~= 0         % If monitor can display millions of colors, use this
    % SURF needs extra extra row and column to work properly
    % (  [X,Y] = meshgrid(a1:astep:a2,b1:bstep:b2)  )
    X = [X a2*ones(rx,1); a1:astep:a2];
    Y = [[Y; b2*ones(1,cx)]  (b1:bstep:b2)']; 
    Z = ext(5)*ones(size(X));
    c = rx*cx;
    col = reshape(1:c,rx,cx);
    colormap(RGB');
    surf(X,Y,Z,col);
    shading('flat');
  else                 % ... if not, use this (slow).
    vx = [-1 1 1 -1 -1] * astep / 2;
    vy = [-1 -1 1 1 -1] * bstep / 2;
    cz = ext(5)*ones(size(vy));
    for i = 1:size(RGB,2)
      cx = gr(1,i); cy = gr(2,i);
      fill3(cx+vx,cy+vy,cz,RGB(:,i)');
      h = plot3(cx+vx,cy+vy,cz);
      set(h,'Color',RGB(:,i));
    end;
  end;

  % Remove points outside spectral locus
  if strcmp(type,'xyY') | strcmp(type,'upvpY')
    xoff = 0; %astep / 2;
    yoff = 0; %bstep / 2;
    W = [[CD(x,1); ext(3)-yoff] [ext(2)+xoff; ext(3)-yoff] [ext(2)+xoff; ...
	ext(4)+yoff] [ext(1)-xoff; ext(4)+yoff] [ext(1)-xoff; ext(3)-yoff] ...
	  [CD(x,1); ext(3)-yoff] CD([x y],:) CD([x y],1) [CD(x,1); ...
	ext(3)-yoff]];
    fill3(W(1,:),W(2,:),ext(5)*ones(size(W)),'k');
  end;
  
end;


% Set titles, labels and axis extends
axes(ha(3))
if strcmp(type,'RGB')
  if size(C,2) > 0  tmp1 = min(C(z2,:)); tmp2 = max(C(z2,:));
  else tmp1 = 0; tmp2 = 100; end;
  if tmp1 == tmp2 rgbext = [tmp1-0.5 tmp1+0.5];
  else rgbext = [tmp1 tmp2]; end;
  set(gca,'Ylim',rgbext,'Xlim',[0 1],'Box','on');
else
  set(gca,'Ylim',[ext(5:6)],'Xlim',[0 1],'Box','on');
end;
grid on;
title(z2lab,'Fontsize',16);

axes(ha(1));
axis([ext]);
axis off;
if f ~= 0
  axis(ext);  axis('square');
else 
  set(ha(1),'Visible','off');
end;

axes(ha(2));
if f ~= 0  set(gca,'Color','none'); end;
axis([ext]);
axis('square');
set(ha(2),'Box','on');
grid on;
xlabel(xlab,'Fontsize',16);
ylabel(ylab,'Fontsize',16);
zlabel(zlab,'Fontsize',16);
title(tit,'Fontsize',16);
