%MVPR_SG_DESCRIPTOR_MATCH Match two sets of Simple Gabor local descriptors.
%
% [m,p,D] = mvpr_sg_descriptor_match(d1_,d2_,sgS,:)
%
% Compute local simple Gabor descriptors for the image img_ at the
% points x_ .
%
%
% Output:
%  m    - Best match in d2 (index from 1 to M) for every descriptor in d1
%  p    - performance number of the match
%  D    - Full distance matrix if needed for some purposes
%
% Input:
%  d1    - NxD descriptors of D dimensions for N points.
%  d2    - MxD descriptors of D dimensions for M points.
%  sgS   - Simple Gabor structure used for extraction (needed in
%          order to perform invariance shifts correctly)
%
%  <optional>
%  method    - Matching method (Def. 1)
%               1: L2 (Euclidean) distance
%               2: L1 (Manhattan) distance
%               3: Cosine distance (angle of two unit vectors)
%               4: Mahalanobis distance (requires covariance)
%  mahal_cov - Covariance matrix for the mahalanobis distance
%              (needs to be computed from descriptors computed from
%              regions of a set of images). Default: [];
%  rot_inv   - Rotation invariance included (Def. true)
%
% Author(s):
%    Joni Kamarainen, TUT-SGN 2014
%
% Project:
%  Object3D2D
%
% Copyright:
%
%   Copyright (C) 2011 by Joni-Kristian Kamarainen.
%
% References:
%  [1] -
%
% See also MVPR_SG_CREATEFILTERBANK.M .
%
function [m,p,D] = mvpr_sg_descriptor_match(d1_, d2_, sgS_, varargin)

% 1. Parse input arguments
conf = struct(...
    'method', 1,...
    'mahal_cov', [],...
    'rot_inv', false);
conf = mvpr_getargs(conf,varargin);

numOfOrients = length(sgS_.freq{1}.orient);
if (conf.rot_inv)
    %oshifts = [0:numOfOrients];
    oshifts = [-numOfOrients:numOfOrients-1];
else
    oshifts = [0];
end;

%if (method_ == 1)
%    for ii = 1:size(d1_,1)
%        f_dist = repmat(d1_(ii,:),[size(d1_,1) 1])-d2_;
%        f_dist = sum(f_dist.*conj(f_dist),2);
%        [m_vals(ii) m_inds(ii)] = min(f_dist);
%    end;
%    m = m_inds;
%end;
m_vals_min = inf(1,size(d1_,1));
m_inds_min = nan(1,size(d1_,1));
if (nargout == 3)
    D = inf(size(d1_,1),size(d2_,1));
end;

% L2
if (conf.method == 1)
    for rot = oshifts
        dr = mvpr_sg_rotatesamples(d1_,rot,numOfOrients);
        for ii = 1:size(d1_,1)
            f_dist = repmat(dr(ii,:),[size(d2_,1) 1])-d2_;
            f_dist = sum(f_dist.*conj(f_dist),2);
            [m_vals(ii) m_inds(ii)] = min(f_dist);
            if (nargout == 3)
                D(ii,D(ii,:) > transpose(f_dist)) = ...
                    f_dist(D(ii,:) > transpose(f_dist));
            end;
        end;
        m_vals_mask = (m_vals < m_vals_min);
        m_vals_min(m_vals_mask) = m_vals(m_vals_mask);
        m_inds_min(m_vals_mask) = m_inds(m_vals_mask);
    end;
end;

% L1
if (conf.method == 2)
    for rot = oshifts
        dr = mvpr_sg_rotatesamples(d1_,rot,numOfOrients);
        for ii = 1:size(d1_,1)
            f_dist = abs(repmat(dr(ii,:),[size(d2_,1) 1])-d2_);
            f_dist = sum(f_dist.*conj(f_dist),2);
            [m_vals(ii) m_inds(ii)] = min(f_dist);
            if (nargout == 3)
                D(ii,D(ii,:) > transpose(f_dist)) = ...
                    f_dist(D(ii,:) > transpose(f_dist));
            end;
        end;
        m_vals_mask = (m_vals < m_vals_min);
        m_vals_min(m_vals_mask) = m_vals(m_vals_mask);
        m_inds_min(m_vals_mask) = m_inds(m_vals_mask);
    end;
end;

% Cosine
if (conf.method == 3)
    for rot = oshifts
        dr = mvpr_sg_rotatesamples(d1_,rot,numOfOrients);
        for ii = 1:size(d1_,1)
          f_dist = abs(acos(dr(ii,:)*d2_'))';
          [m_vals(ii) m_inds(ii)] = min(f_dist);
          if (nargout == 3)
                D(ii,D(ii,:) > transpose(f_dist)) = ...
                    f_dist(D(ii,:) > transpose(f_dist));
          end;
        end;
        m_vals_mask = (m_vals < m_vals_min);
        m_vals_min(m_vals_mask) = m_vals(m_vals_mask);
        m_inds_min(m_vals_mask) = m_inds(m_vals_mask);
    end;
end;

% Mahalanobis
if (conf.method == 4)
    for rot = oshifts
        dr = mvpr_sg_rotatesamples(d1_,rot,numOfOrients);
        for ii = 1:size(d1_,1)
            f_dist = (repmat(dr(ii,:),[size(dr,1) 1])-d2_);
            f_dist = real(diag(f_dist*conf.mahal_cov*f_dist'));
            [m_vals(ii) m_inds(ii)] = min(f_dist);
        end;
        m_vals_mask = (m_vals < m_vals_min);
        m_vals_min(m_vals_mask) = m_vals(m_vals_mask);
        m_inds_min(m_vals_mask) = m_inds(m_vals_mask);
    end;
end;
m = m_inds_min;
p = m_vals_min;