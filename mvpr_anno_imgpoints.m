%MVPR_ANNO_IMGPOINTS Get points of interest from image
%
%   [P] = MVPR_ANNO_IMGPOINTS(I,XS,YS,MN) loads image I and shows
%   it as blocks of size YSxXS (height (y) x width (x)), where user
%   can select points of interest by mouse click or jump to next
%   block. MN is the maximum number of point requested (one row is
%   always processed to end even though MN is met - this is
%   typically due to easier measurement of false alarms). You may
%   also give an optional parameter, which contains initial points
%   to be plotted (e.g. if you want to eval that no points was
%   missed by rerunning the whole thing?). XS or YS == -1 means
%   that the original image size is used.
%
% Output:
%  P - Nx2 list of 2D points (max(N) == MN)
%
% Input:
%  I  - File name of the image to be annotated.
%  XS - Width of a block shown at time (YSxXS)
%  YS - Heigh of a block shown at time (YSxXS)
%  MN - Maximum number of points allowed to annotate
%
% <optional>
%  'initPoints'  - Nx2 prior set points (by the same user?)
%  'otherPoints' - Cell struct of N_ix2 prio set points (by
%                  i=1.. other users?)
%
% Author(s):
%    Joni Kamarainen, MVPR in 2003
%    Jarkko Vartiainen, MVPR in 2003
%    Albert Sadovnikov, MVPR in 2003
%    Jarmo Ilonen, MVPR in 2003
%
% Project:
%  PapVision (http://www.it.lut.fi/project/papvision/)
%  Object3d2d (http://www.it.lut.fi/project/object/)
%
% Copyright:
%   -
%
% References:
%
% See also MVPR_ANNO_IMGLIST.M .
%%
function [p,modeInfo] = mvpr_anno_imgpoints(img_, xstep_, ystep_,maxnum_, ...
                                            varargin);
% Parse input arguments
conf = struct('initPoints',[],...
              'otherPoints',[]);
conf = mvpr_getargs(conf,varargin);

modeInfo = 0;

if (xstep_ ~= -1)
  numOfXSteps = ceil(size(img_,2)/xstep_);
else
  numOfXSteps = 1; % original size wanted
end;

if (ystep_ ~= -1)
  numOfYSteps = ceil(size(img_,1)/ystep_);
else
  numOfYSteps = 1; % original size wanted
end;

p = [];
numOfPoints = 0;
maxNumReached = 0; % false by default
fprintf(1,['Mouse button 1 = mark point, MB 2 = special menu, Mouse button 3 = next image window\n']);
for ys = 0:numOfYSteps-1
  for xs = 0:numOfXSteps-1
    if (xs < numOfXSteps-1)
      xvals = 1+xs*xstep_:xstep_+xs*xstep_;
    else % last "slice"
      xvals = 1+xs*xstep_:size(img_,2);
    end;      
    if (ys < numOfYSteps-1)
      yvals = 1+ys*ystep_:ystep_+ys*ystep_;
    else % last "slice"
      yvals = 1+ys*ystep_:size(img_,1);
    end;      
    clf;
    figd = imshow(img_(yvals,xvals,:));
    %set(get(get(figd,'Parent'),'Parent'),'KeyPressFcn',@myKeyPress);
    hold on;
    if (~isempty(conf.initPoints))
        % there are initial points already and we should plot and
        % use them
        pcurrb = pointsInCurrentBlock(conf.initPoints,xvals,yvals);
        for fooInd = 1:size(pcurrb,1)
            numOfPoints = numOfPoints+1;
            plot(pcurrb(fooInd,1),pcurrb(fooInd,2),'go','MarkerSize',5,'LineWidth',2);
            figd = text(pcurrb(fooInd,1),pcurrb(fooInd,2),num2str(numOfPoints));
            set(figd,'Color','green','FontSize',14);
        end;
        %numOfPoints = numOfPoints+size(pcu,1);
        p = [p; (xs*xstep_+pcurrb(:,1)) (ys*ystep_+pcurrb(:,2))];
        elseif (~isempty(conf.otherPoints))
            % others have annotated and we should just plot them
            for othInd = 1:length(conf.otherPoints)
                title('Only annotations made by others (red crosses)');
                pcurrb = pointsInCurrentBlock(conf.otherPoints{othInd},xvals,yvals);
                for fooInd = 1:size(pcurrb,1)
                    plot(pcurrb(fooInd,1),pcurrb(fooInd,2),'rx','MarkerSize',5,'LineWidth',2);
                    figd = text(pcurrb(fooInd,1),pcurrb(fooInd,2),num2str(fooInd));
                    set(figd,'Color','red','FontSize',14);
                end;
            end;
    end;
    while (1) % interest points get loop
      [x y t] = ginput(1);
      switch t,
       case 1,
	numOfPoints = numOfPoints+1;
	plot(x,y,'ro','MarkerSize',5,'LineWidth',2);
        figd = text(x,y,num2str(numOfPoints));
        set(figd,'Color','red','FontSize',14);
	p = [p; (xs*xstep_+x) (ys*ystep_+y)];
       case 2,
        selKey = input('(q=quit,c=clear all): ','s');
        switch (selKey)
         case 'q',
          close
          modeInfo = -1; % quit enforced
          return;
         case 'c',
          p = [];
          numOfPoints = 0;
          clf;
          figd = imshow(img_(yvals,xvals,:));
          hold on;
         otherwise,
          fprintf('Unknown?\n');
        end;
       case 3,
	break;
       otherwise,
      end;
    end;
    hold off;
    fprintf('\r(point number %d/%d)',numOfPoints,maxnum_);
    if (numOfPoints >= maxnum_)
      maxNumReached = 1;
    end;
  end;
  if (maxNumReached == 1) % we may stop after this row
    return;
  end;
end;
fprintf('. Done!\n');

function [] = myKeyPress(src,evnt)

keyboard;
handles = guidata(src);
%if strcmp(evnt.Key,'q')
%  delete(handles
return;

function [p] = pointsInCurrentBlock(points_,xvals_,yvals_)
% search points inside this block
p = [];
initInds = find(points_(:,1) >= min(xvals_)); % above min X
foo = points_(initInds,:);
if (~isempty(foo))
    initInds = find(foo(:,1) <= max(xvals_)); % below max X
    foo = foo(initInds,:);
    if (~isempty(foo))
        initInds = find(foo(:,2) >= min(yvals_)); % above min Y
        foo = foo(initInds,:);
        if (~isempty(foo))      
            initInds = find(foo(:,2) <= max(yvals_)); % below max Y
            foo = foo(initInds,:);
            if (~isempty(foo))      
                p(:,1) = foo(:,1)-min(xvals_)+1;
                p(:,2) = foo(:,2)-min(yvals_)+1;
            end;
        end;
    end;
end;
