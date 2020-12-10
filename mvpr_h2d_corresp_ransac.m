%MVPR_H2D_CORRESP Estimate 2-D homography between point correspondence
%
% [H] = mvpr_h2d_corresp(X1_,X2S_,inDist_,:)
%
% Computes an estimate of 3x3 geometric transformation (homography)
% from 2-D points X1_ to the best matching combination of 2-D
% points in X2S_ cell structure (contains multiple correspondence for
% each point in X1_). 
%
%
% Output:
%  H - 3x3 transform matrix
%
% Input:
%  X1_     - 2xN (inhomogeneous) or 3xN (homogeneous) coordinates
%  X2S_    - A cell of N entries each containing a 2xNi
%            (inhomogeneous) or 3xNi (homogeneous) coordinates 
%            (correspondence "candidates").
%  [NOTE: if X1_ is a cell struct, then the meanings of variables are switched!]
%  inDist_ - Inlier distance (under this distance a correspondence
%            accepted as an "inlier". This must be given in the
%            known target domain, i.e. always the one which is
%            matrix of X1_ or X2S_ .
%            or not)
%
%  <optional>
% 'hType'      - Homography type (see [1] or [2]):
%                'projectivity' (DEFAULT)
%                'affinity'
%                'similarity'
%                'isometry'
% 'riters'     - Random iterations (Def. 100).
% 'srcMinDist' - Source domain minimum distance that a
%                min. required num of correspondences is accepted
%                (Def. 2)
%
% Author(s):
%    Joni Kamarainen, MVPR in 2009.
%
% Project:
%  HomoGr (http://www.it.lut.fi/project/homogr/)
%
% Copyright:
%
%   Homography estimation toolbox (mvpr_h[23n]d_* ) is Copyright
%   (C) 2008 by Joni-Kristian Kamarainen.
%
% References:
%  [1] Kamarainen, J.-K., Paalanen, P., Experimental study on Fast
%  2D Homography Estimation From a Few Point Correspondence,
%  Research Report, Machine Vision and Pattern Recognition Research
%  Group, Lappeenranta University of Technology, Finland, 2008.
%
%  [2] Hartley, R., Zisserman, A., Multiple View Geometry in
%  Computer Vision, 2nd ed, Cambridge Univ. Press, 2003.
%
% See also .
%
function [bestH] = mvpr_h2d_corresp_ransac(X1_,X2S_,inDist_,varargin)

% Parse input arguments
conf = struct('hType','projectivity','riters',100,'srcMinDist',2,...
              'dbgImg1',[],'dbgImg2',[]);
conf = mvpr_getargs(conf,varargin);

%%
%% Construct homogeneous vectors if not
%if (size(X1_,1) == 2)
%  X1 = [X1_; ones(1,size(X1_,2))];
%else
%  X1 = X1_;
%end;
%if (size(X2_,1) == 2)
%  X2 = [X2_; ones(1,size(X2_,2))];
%else
%  X2 = X2_;
%end;

% switch is the source points have multiple entries
if (iscell(X1_))
  X1 = X2S_;
  X2S = X1_;
  targetDomain = 1;
else
  X1 = X1_;
  X2S = X2S_;
  targetDomain = 2;
end;

% Test that are separate
if (~checkuniqueness(X1(1:2,:),inDist_))
    warning('Source point set is too compact for given inlier distance.');
end;

%
% Check that enough correspondences
switch conf.hType
 case 'isometry',
  minNum = 2;
 case 'similarity',
  minNum = 2;
 case 'affinity',
  minNum = 3;
 case 'projectivity',
  minNum = 4;
 otherwise,
  error(['Unkown homography: ' conf.hType]);
end;
if (size(X1,2) <= minNum)
    error(['Given correspondence point number is equal '...
           'or less than the minimum required for this homography '...
           '- and running this method makes no sense.']);
end;

rCorrs1 = nan(1,minNum);
rCorrs2 = nan(1,minNum);
rCorr1Coords = nan(size(X1,1),minNum);
rCorr2Coords = nan(size(X1,1),minNum);
bestScore = -inf;
bestH = ones(3);
for riter = 1:conf.riters
    % Select min number of random correspondences
    foo = randperm(size(X1,2));
    rCorrs1(1:minNum) = foo(1:minNum);
    rCorr1Coords(:,:) = X1(:,rCorrs1);
    for randnum = 1:minNum
        rCorrs2(randnum) = ceil(size(X2S{rCorrs1(randnum)},2)*rand(1));
        rCorr2Coords(:,randnum) = X2S{rCorrs1(randnum)}(:,rCorrs2(randnum));
    end;
    
    % Test that are separate
    if (~checkuniqueness(rCorr2Coords(1:2,:),conf.srcMinDist))
        continue;
    end;

    % Compute transform
    switch conf.hType
     case 'isometry',
      H = mvpr_h2d_corresp_exiso(rCorr1Coords(1:2,:), rCorr2Coords(1:2,:));
     case 'similarity',
      H = mvpr_h2d_corresp_exsim(rCorr1Coords(1:2,:), rCorr2Coords(1:2,:));
     case 'affinity',
      H = mvpr_h2d_corresp_exaff(rCorr1Coords(1:2,:), rCorr2Coords(1:2,:));
     case 'projectivity',
      [nX1 nX2 Un Tn] = mvpr_hnd_corresp_coordnorm(...
          rCorr1Coords(1:2,:),rCorr2Coords(1:2,:),1);
      nX1 = [nX1; rCorr1Coords(3,:)];
      nX2 = [nX2; rCorr2Coords(3,:)];
      nH = mvpr_h2d_corresp_dlt(nX1,nX2,0);
      H = mvpr_hnd_corresp_coorddenorm(nH, Un, Tn);
    end;
    
    % Trans all points using H and check num of inliers
    TX1 = mvpr_h2d_trans(X1,H);
    thisScore = 0;
    inliers = nan(1,size(X1,2));
    for fooNum = 1:size(X1,2)
        dists = X2S{fooNum}-repmat(TX1(:,fooNum),[1 size(X2S{fooNum},2)]);
        dists = sqrt(sum(dists.^2,1));
        distMask = (dists <= inDist_);
        if (sum(distMask) >= 1)
            thisScore = thisScore+1;
            foo = find(distMask == 1);
            inliers(fooNum) = foo(1); % just the first if multiple
        end;
    end;
    if (thisScore > bestScore)
        bestScore = thisScore;
        bestH = H;
        bestInliers = inliers;
        bestX1 = [];
        bestX2 = [];
        for fooInd = 1:size(X1,2)
            if (~isnan(inliers(fooInd)))
                bestX1 = [bestX1 X1(:,fooInd)];
                bestX2 = [bestX2 X2S{fooInd}(:,inliers(fooInd))];
            end;
        end;
    end;
end;

bestH = mvpr_h2d_corresp(bestX1,bestX2,'hType',conf.hType);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  INTERNAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
%
function [u] = checkuniqueness(pointCoords_,uDist_)

u = true;
for fooind = 1:size(pointCoords_,2)
    fooCoords = pointCoords_;
    fooCoords(:,fooind) = realmax;
    fooDists = fooCoords-repmat(pointCoords_(:,fooind),[1 size(fooCoords,2)]);
    fooDists = sqrt(sum(fooDists.^2,1));
    if (sum(fooDists < uDist_) > 0)
        u = false;
    end;
end;

%function [] = dbg_plotmatches(sImg_,sFrames_,cImg_,cFrames_)
%
%[dbgImg dbgOff] = o3d2d_makedebugimg(sImg_,cImg_);
%cla reset;
%imshow(dbgImg);
%title('Matches found');
%hold on;
%set(gcf,'DoubleBuffer','on');
%
%for foo = 1:size(sFrames_,2)
%  plot(sFrames_(1,foo),sFrames_(2,foo),'yd','MarkerSize',10,'LineWidth',2);
%  plot(cFrames_(1,foo)+dbgOff,cFrames_(2,foo),'yd','MarkerSize',10,'LineWidth',2);
%  plot([sFrames_(1,foo) cFrames_(1,foo)+dbgOff],...
%       [sFrames_(2,foo) cFrames_(2,foo)]','y-','LineWidth',2);
%end;
%drawnow
%hold off;
