% [BESTH BESTS BESTIDX] = MVPR_H2D_CORRESP_MULTI(X1, X2, INDIST)
% == WARNING! THIS FUNCTION IS HIGHLY EXPERIMENTAL! ==
% This function is almost identical to the mvpr_h2d_corresp_ransac but it
% returns N best results instead of one single result
% 
%
% Outputs:
% BESTH  -  Best transformations
% BESTS  -  Best scores
% BESTIDX - Best indices
%

function [bestH bestScores idxs inliers] = mvpr_h2d_corresp_multi(X1_, X2S_, inDist_, varargin)

% Parse input arguments
conf = struct('hType', 'projectivity', ...
              'numBest', 1, ...
              'riters',100,...
              'srcMinDist',2,...
              'dbgImg1',[], ...
              'dbgImg2',[]);
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
end

% Test that are separate
if (~checkuniqueness(X1(1:2,:),inDist_))
	warning('Source point set is too compact for given inlier distance.');
end


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
end
%keyboard
%if size(X2S,1) < minNum
%	bestH = [];
%	bestScores = [-inf];
%	idxs = [];
%	return;
%end
if (size(X1,2) <= minNum)
    error(['Given correspondence point number is equal '...
           'or less than the minimum required for this homography '...
           '- and running this method makes no sense.']);
end

rCorrs1 = nan(1,minNum);
rCorrs2 = nan(1,minNum);
rCorr1Coords = nan(size(X1,1),minNum);
rCorr2Coords = nan(size(X1,1),minNum);
bestScore = -inf;
bestH = ones(3);

homographys = [];
scores = [];
allInliers = {};

checkedPairs = [];

% TODO: Fix the problem of not unique feature pairs which decreases the actual
% numbe of iterations
ite = 1;
for riter = 1:conf.riters
	
	% Select min number of random correspondences
	foo = randperm(size(X1,2));

	%% check if this pair is already checked
%	if riter > 1
%		fooComp = repmat(foo(1:minNum), size(checkedPairs, 1),1);
%		fooComp = (checkedPairs - fooComp);
%		
%		
%		
%		if sum(sum(abs(fooComp),2) == 0) > 0
%			%% Found
%			% skip
%			%keyboard;
%			continue;
%		else
%			checkedPairs(ite,:) = foo(1:2);
%		end
%	else
%		checkedPairs(ite,:) = foo(1:2);
%	end

	
	rCorrs1(1:minNum) = foo(1:minNum);
	rCorr1Coords(:,:) = X1(:,rCorrs1);
	for randnum = 1:minNum
		rCorrs2(randnum) = ceil(size(X2S{rCorrs1(randnum)},2)*rand(1));
		rCorr2Coords(:,randnum) = X2S{rCorrs1(randnum)}(:,rCorrs2(randnum));
	end

	% Test that are separate
	% TODO remove and use mvpr_checkdistance in future
	if (~checkuniqueness(rCorr2Coords(1:2,:),conf.srcMinDist))
		continue;
	end

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
	end

	% Trans all points using H and check num of inliers
	TX1 = mvpr_h2d_trans(X1,H);
	thisScore = 0;
	inliers = nan(1,size(X1,2));
	for fooNum = 1:size(X1,2)
%		dists = X2S{fooNum}-repmat(TX1(:,fooNum),[1 size(X2S{fooNum},2)]);
%		dists = sqrt(sum(dists.^2,1));
        dists = transpose( sqrt( mvpr_feature_matchmatrix(X2S{fooNum},TX1(:,fooNum)) ) );
		distMask = (dists <= inDist_);
		if (sum(distMask) >= 1)
			thisScore = thisScore+1;
			foo = find(distMask == 1);
			inliers(fooNum) = foo(1); % just the first if multiple
		end
		
	end

	homographys(ite,:,:) = H;
	scores(ite) = thisScore;
	allInliers{ite} = inliers;
	ite = ite + 1;
	
	%    if (thisScore > bestScore)
	%        bestScore = thisScore;
	%        bestH = H;        
	%        bestInliers = inliers;
	%        bestX1 = [];
	%        bestX2 = [];
	%        for fooInd = 1:size(X1,2)
	%            if (~isnan(inliers(fooInd)))
	%                bestX1 = [bestX1 X1(:,fooInd)];
	%                bestX2 = [bestX2 X2S{fooInd}(:,inliers(fooInd))];
	%            end;
	%        end;
	%    end;
	
end
%keyboard;
%indis = find(checkedPairs(:,1) > 0);

% zero inliers = no point to continue
if length(allInliers) > 0

	if size(scores,2) < conf.numBest
	% We might not want too see error, because it is way too common.
	%	error('Not enough matches found.');
	
		% Fill out the output parameters
		homographys(end+1:conf.numBest,:,:) = 0;
		scores(end+1:conf.numBest) = 0;
		allInliers(end+1:conf.numBest) = { nan(size(allInliers{end})) };
	end


	% Sort output parameters by number the number matching landmarks in
	% descensding order (best first) and take conf.numBest results for output
	% parameters
	[values indices] = sort(scores, 'descend');

	inliers	= cell(conf.numBest,1);
	for i = 1:conf.numBest
		inliers{i} = allInliers{indices(i)};
	        bestX1 = [];
	        bestX2 = [];
		for fooInd = 1:size(X1,2)
			if (~isnan(inliers{i}(fooInd)))
				bestX1 = [bestX1 X1(:,fooInd)];
				bestX2 = [bestX2 X2S{fooInd}(:,inliers{i}(fooInd))];
			
			end
		end
		if ~isempty(bestX1),
			bestH(:,:,i) = mvpr_h2d_corresp(bestX1,bestX2,'hType',conf.hType);		
		else
			bestH(:,:,i) = 0;
		end;
		idxs{i} = find(~isnan(inliers{i}));
	end

	bestScores = values(1:conf.numBest);
else
	% return null
	inliers = {};
	bestScores = [];
	idxs = {};

end % enough inliers
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
end
end




























%%MVPR_H2D_CORRESP_MULTI Exact 2-D homography (any) from point
%%correspondence (best transformation selected by random sampling)
%%
%% NOTE: This function is highly experimental, it surely works, but
%% there are no evidence that it would be better than those more
%% elegant methods (e.g. DLT) descibed in the literature in any
%% particular application. Read the "NOTE X" section at the end of
%% this e-mail.
%%
%% [bestH bestXt bestParams] = mvpr_h2d_corresp_ransam(X1_,X2_,tr_,r_,h_,:)
%%
%% Computes the exact 3x3 transformation of type tr_ transforming
%% 2-D points X1_ to 2-D points X2_ using the correspondence
%% information. The method runs r_ iterations where a minimum
%% number of random samples are selected and used in the homography
%% estimation. The final homography is generated by (weighted)
%% average over h_ (set to much less than r_) best estimates
%% according to the trasfer error (in X2_ space). For affinity and
%% projectivity the h_=1 is the only option.
%%
%% NOTE 0: h_ = 1 means that only the best sample is used <RECOMMENDED>
%%
%% NOTE 1: do not use any normalisation (they break the isometry
%% restriction)
%%
%% NOTE 2: This method returns unity transformation if the
%% estimation points are detected ill-configured !!
%%
%% NOTE 3: This method utilises explicitly estimated transformation
%% parameters, which must be provided by the underlying exact
%% methods. The method using only the one best could be implemented
%% even without the parameters and maybe that is how this really
%% should be implemented!
%%
%% NOTE 4: SIMILARITY+ is still experimental - for more information
%% see the comments inside the exact implementation function.
%%
%% Output:
%%  bestH      -  3x3 transform matrix
%%  bestXt     -  2xN transformed points (using bestH)
%%  bestParams - Transformation parameters
%%               Isometry: 1: theta, 2&3: tx,ty
%%               Similarity: 1: theta, 2&3: tx,ty, 4: s
%%               Similarity+: 1: theta, 2&3: tx,ty, 4: delta1, 5: delta2
%%               Affinity: 1: theta, 2&3: tx,ty, 4: delta1, 5: delta2, 6: beta
%%
%% Input:
%%  X1_    - 3xN coordinates (homogenous)
%%  X2_    - 3xN coordinates (homogenous)
%%  tr_    - Homography type
%%	1   : isometry
%%	2   : similarity
%%	2.5 : similarity+
%%           varargin(1) : scale angle alpha [1]
%%           varargin(2) : estimation direction (1: from model, 2:to
%%                         model) [1]
%%	3   : affinity
%%
%%  r_     - Number of random repeats (eg. 10, 100, 500...)
%%  h_     - How many best used in averaging (e.g. 1, 2, 3, 5...)
%%
%% Author(s):
%%    Joni Kamarainen, MVPR in 2009.
%%
%% Project:
%%  HomoGr (http://www.it.lut.fi/project/homogr/)
%%
%% Copyright:
%%
%%   Homography estimation toolbox (mvpr_h[23n]d_* ) is Copyright
%%   (C) 2008 by Joni-Kristian Kamarainen.
%%
%% References:
%%  [1] Kamarainen, J.-K., Paalanen, P., Experimental study on Fast
%%  2D Homography Estimation From a Few Point Correspondence,
%%  Research Report, Machine Vision and Pattern Recognition Research
%%  Group, Lappeenranta University of Technology, Finland, 2008.
%%
%% See also MVPR_H2D_CORRESP.M
%%
%%%
%function [bestH bestXt bestParams] = mvpr_h2d_corresp_multi(points1, points2, varargin)


%T = mvpr_h2d_corresp(points1, points2)

%iterations = 500;
%scores = zeros(iterations,1);
%%
%% Random loop for estimations
%for iterInd = 1:iterations
%	randInds = randperm(size(points1, 1));
%	
%	% SIMILARITY estimation
%	rX1 = points1(randInds(1:2),:);
%	rX2 = points2(randInds(1:2),:);
%	
%	if mvpr_h2d_corresp_isvalid(rX1, rX2, 2)
%		[H theta tx ty s] = mvpr_h2d_corresp_exsim(rX1, rX2);
%        else
%		theta = 0;
%		tx = 0;
%		ty = 0;
%		s = 1;
%		H = diag([1 1 1]);
%	end
%	params(iterInd, :) = [theta tx ty s];

%	points1
%	pointsT = mvpr_h2d_trans(points1, H);

%	dists = sqrt(sum((points2 - points1).^2,2));

%	score = sum(sqrt(sum((points2 - pointsT).^2,2)) < 15);
%	scores(iterInd) = score;
%	%errors(iterInd) = sum(sqrt(sum((points2 - pointsT).^2,1)));
%	errors(iterInd) = sum(sqrt(sum((points2 - pointsT).^2,2)));
%	
%end
%[foo sortInds] = sort(scores,'descend');

%bestInds = sortInds(1:1);
%sortInds(1:5);
%theta = params(bestInds, 1);
%tx = params(bestInds, 2);
%ty = params(bestInds, 3);
%s = params(bestInds, 4);

%bestH = mvpr_h2d_sim(theta, [tx ty], s)
%bestParams = [theta tx ty s];

%%keyboard;

%end

