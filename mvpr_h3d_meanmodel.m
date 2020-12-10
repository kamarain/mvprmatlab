%MVPR_H3D_MEANMODEL Mean model of K point sets <EXPERIMENTAL BY JONI>
%
% [Xm,mgd,Xt] = mvpr_h3d_meanmodel(X_,tr_,:)
%
% For 3-D points patterns in X_ compute their mean model
% under the selected 3-D homography tr_. In principle, the function
% works exactly as MVPR_H2D_MEANMODEL.M, but in 3D.
%
% Output:
%  Xm  - Nx3 points corresponding the mean model of K examples.
%  mgd - Mean geometric distance provided by the model (computed by
%        transforming the mean model to original space making
%        measure comparable over diff. homographies).
%  Xt  - KxNx3 points, X_ transformed to the mean model space
%
% Input:
%  X_  - KxNx3 coordinates of point patterns of N different points
%        (landmarks, N corresponds to the label number) from K
%        different training examples
%  tr_ - Transformation under which the mean model is searched (see
%  [3] for 2-D counterparts) 
%     0:   No transformation
%     1:   Isometry (mvpr_hnd_corresp_umeyama.m)
%     2:   Similarity (mvpr_hnd_corresp_umeyama.m)
%     3:   Affinity (NOT SUPPORTED YET)
%     4:   Projectivity (NOT SUPPORTED YET)
%
% Optional input:
%     'randRepeats' - How many times the whole process with a
%                     random start is repeated and the model
%                     producing the smallest mgd is selected
%                     (Default = 3) 
%     'debugLevel'  - 0 <DEFAULT>, 1 or 2
%
% Author(s):
%    Joni Kamarainen, MVPR in 2009.
%
% Project:
%  SpatModel (http://www.it.lut.fi/project/spatmodel/)
%
% Copyright:
%   Copyright (C) 2008 by Joni-Kristian Kamarainen.
%
% References:
%  [1] Kamarainen, J.-K., Hamouz, M., Kittler, J., Paalanen, P.,
%  Ilonen, J., Drobchenko, A., Object Localisation Using Generative
%  Probability Model for Spatial Constellation and Local Image
%  Features, In Proc. of the ICCV 2007 Workshop on Non-Rigid
%  Registration and Tracking Through Learning (NRTL2007) (Rio de
%  Janeiro, Brazil, 2007). 
%
%  [2] Cootes, T.F., Taylor, C.J., Cooper, D.H. and Graham, J.,
%  Active Shape Models -- Their Training and Application, Computer
%  Vision and Image Understanding 61(1), 1995.
%
%  [3] Kamarainen, J.-K., Paalanen, P., Experimental study on Fast
%  2D Homography Estimation From a Few Point Correspondence,
%  Research Report, Machine Vision and Pattern Recognition Research
%  Group, Lappeenranta University of Technology, Finland, 2008.
%
% See also MVPR_H2D_CORRESP.M and MVPR_H2D_MEANMODEL.M .
%
function [bestXm,bestMgd,bestXt,varargout] = mvpr_h3d_meanmodel(X_,tr_,varargin)

%
% Define some useful values
numOfSamples = size(X_,1);
numOfFeats = size(X_,2);

%
% Read optional parameters
conf = struct(...
    'randRepeats', 3,...
    'debugLevel', 0);
conf = mvpr_getargs(conf, varargin);

bestXm = [];
bestXt = [];
bestMgd = inf;
for randInd = 1:conf.randRepeats
  %
  % Main loop which iteratively transforms next point set X to the
  % mean model Xm, then updates the mean model and continues until
  % all points used in the mean model. The first (random) point is
  % used as the initial model
  
  % Take in random order
  modelExamples = X_(randperm(size(X_,1)),:,:);
  
  % Main loop
  for exampleInd = 2:size(X_,1)
    
    % Current model is the mean of transformed ones
    Xm = squeeze(mean(modelExamples(1:exampleInd-1,:,:),1));
    
    % Select next point
    X = squeeze(modelExamples(exampleInd,:,:))';
    
    % Perform homography estimation using the best default homography
    % estimation method (see [3])
    switch(tr_)
      
     case 0,
      % No transformation
      H = eye(4)
      Xt = mvpr_hnd_trans(X,H);
      modelExamples(exampleInd,:,:) = Xt';
      
     case 1,
      H = mvpr_hnd_corresp_umeyama(X,Xm',1);
      %H = h2d_corresp(X,Xm','hType','isometry');
      Xt = mvpr_hnd_trans(X,H);
      %Xt = h2d_trans(X,H);
      modelExamples(exampleInd,:,:) = Xt';
      
     case 2,
      H = mvpr_hnd_corresp_umeyama(X,Xm',0);
      %H = h2d_corresp(X,Xm','hType','similarity');
      Xt = mvpr_hnd_trans(X,H);
      %Xt = h2d_trans(X,H);
      modelExamples(exampleInd,:,:) = Xt';
      
     case 3
      error('NOT SUPPORTED YET');
      %H = h2d_corresp(X,Xm','hType','affinity');
      %Xt = h2d_trans(X,H);
      %modelExamples(exampleInd,:,:) = Xt';
      
     case 4
      error('NOT SUPPORTED YET');
      %H = h2d_corresp(X,Xm','hType','projectivity');
      %Xt = h2d_trans(X,H);
      %modelExamples(exampleInd,:,:) = Xt';
      
     otherwise,
      error('Unknown transformation requested');
    end;
  end;
  
  % Final model
  Xm = squeeze(mean(modelExamples,1));
  
  % Transform all points to the final model and compute the model
  % error (by vice versa transforming the mean model to the points)
  Xt = zeros(size(X_));
  for pointInd = 1:size(X_,1)
    X = squeeze(X_(pointInd,:,:))';
    switch(tr_)
      
     case 0,
      H = eye(4);
      Xt(pointInd,:,:) = mvpr_hnd_trans(X,H)';
      
     case 1,
      H = mvpr_hnd_corresp_umeyama(X,Xm',1);
      %H = h2d_corresp(X,Xm','hType','isometry');
      Xt(pointInd,:,:) = mvpr_hnd_trans(X,H)';
      %Xt(pointInd,:,:) = h2d_trans(X,H)';
      
     case 2,
      H = mvpr_hnd_corresp_umeyama(X,Xm',0);
      %H = h2d_corresp(X,Xm','hType','similarity');
      Xt(pointInd,:,:) = mvpr_hnd_trans(X,H)';
      %Xt(pointInd,:,:) = h2d_trans(X,H)';
      
     case 3,
      error('NOT SUPPORTED YET');
      %H = h2d_corresp(X,Xm','hType','affinity');
      %Xt(pointInd,:,:) = h2d_trans(X,H)';
      
     case 4,
      error('NOT SUPPORTED YET');
      %H = h2d_corresp(X,Xm','hType','projectivity');
      %Xt(pointInd,:,:) = h2d_trans(X,H)';
      
     otherwise,
      error('Unknown transformation requested');
    end;    
    
    %geomDists(pointInd) = sum(sqrt(sum((Xm-squeeze(Xt(pointInd,:,:))).^2,2)));
    %geomDists(pointInd) = sum(sqrt(sum((X'-squeeze(Xtp(pointInd,:,:))).^2,2)));
    %geomDists(pointInd) = sum(sqrt(sum((X'-h2d_trans(Xm',inv(H))').^2,2)));
    geomDists(pointInd) = sum(sqrt(sum((X'-mvpr_hnd_trans(Xm',inv(H))').^2,2)));
  end;
  
  % Mean geometric distance to model
  mgd = mean(geomDists);
 
  % Check if better than the current
  if (mgd < bestMgd)
    bestMgd = mgd;
    bestXt = Xt;
    bestXm = Xm;
  
    %%%% DEBUG 1 %%%%
    if (conf.debugLevel >= 1)
      fprintf('[DEBUG[1]: Repeat no %4d - best mean geometric error = %f\n',randInd, mgd);
    end;
  
  end;
end; % randRepeats
