% MVPR Matlab Toolbox
% $Id: Contents.m 85 2012-10-09 07:56:22Z jkamarai $
%
% [M]achine [V]ision and [P]attern [R]ecognition Matlab toolbox is 
% a collection of functions implemented and added by various
% researchers in the MVPR Laboratory, Dept. of Information
% Technology, Lappeenranta University of Technology (LUT),
% Finland. 
%
% These functions have typically been developed during the projects
% and therefore their history information is somewhere in the
% project directories in the version control (CVS/SVN). We have
% tried to mention the corresponding project and authors in each
% file in the case you need to get more detailed information.
%
% If contributing, read "README.txt" first and see the existing
% functions for coding regulations (please, follow if any way
% possible)!
%
% Copyrights for these functions are M-file dependent, so before
% you can use any of these functions outside the laboratory, you
% must read the copyrights. The authors have however agreed that
% the included M-functions can be freely used (but not distributed
% or moved elsewhere) for scientific purposes by all researchers in
% the LUT MVPR research group.
%
% Currect categories of different functions:
%  * Functions for functions
%  * File I/O functions (text and image files).
%  * Reading, writing, formatting and manipulating images.
%  * Graphics
%  * Interest point/region detection and description.
%  * Homography estimation and transformation.
%  * Spatial models of local features
%  * Gabor features (simple Gabor feature space)
% See detailed function lists in the following.
%
% Functions for functions.
%   mvpr_getargs      - Parse variable argument list into a struct.
%   mvpr_warning_wrap - Warning function wrapper (to support old
%                       Matlab versions). 
%   mvpr_require      - Check for required version of a toolbox/library.
%   mvpr_chkconfig    - Compare saved and current configurations.
%
% File I/O functions (text and image files).
%   mvpr_lopen         - Open list file for reading or writing.
%   mvpr_lclose        - Close list file.
%   mvpr_lwrite        - Write a line of data into a list file.
%   mvpr_lread         - Read a line from list file.
%   mvpr_lwritecomment - Write a comment line into a list file.
%   mvpr_lcountentries - Counts how many valid lines in the given file.
%
% Reading, writing, formatting and manipulating images.
%   mvpr_imread    - Read image as GRAY scale.
%   mvpr_imconvert - Convert ("any") image to gray scale.
%   mvpr_imtrans   - Homogenous transformation of an image.
%   mvpr_imcompose - Compose given image to a larger image.
%
% Graphics
%   mvpr_drawcircle- Draw a filled circle
%
% Interest point/region detection and description.
%   mvpr_vlfeat_sift         - Detect and extract SIFT features.
%   mvpr_vlfeat_sift_files   - Detect and extract SIFT features
%                              (read images from file). 
%
% Homography estimation and transformation.
%   Main interface:
%   mvpr_h2d_corresp         - Estimate 2-D homography between point
%                              correspondence. 
%   Parameterised transforms:
%   mvpr_h2d_iso             - Construct 2-D homography matrix
%                              restricted to (orientation preserving)
%                              isometry transformation.
%   mvpr_h2d_sim             - Construct 2-D homography matrix
%                              restricted to (orientation preserving)
%                              similarity transformation. 
%   mvpr_h2d_aff             - Construct 2-D homography matrix
%                              restricted to affinity transformation.
%   mvpr_h2d_pro             - Construct 2-D homography matrix
%                              (projectivity).
%   mvpr_h2d_trans           - 2-D homography transformation.
%   mvpr_hnd_trans           - N-D homography transformation.
%   mvpr_project             - Divide column vectors by their last
%                              element. 
%   mvpr_unproject           - Add unit element to column vectors.
%
%   Implemented estimation methods (called from main interface):
%   mvpr_h2d_corresp_exiso   - Exact 2-D homography (isometry) from
%                              point correspondence.
%   mvpr_h2d_corresp_exsim   - Exact 2-D homography (similarity) from
%                              point correspondence.
%   mvpr_h2d_corresp_exaff   - Exact 2-D homography (affinity) from
%                              point correspondence.
%   mvpr_h2d_corresp_ransam  - Exact 2-D homography (any) from point 
%                              correspondence (best transformation
%                              selected by random sampling).
%   mvpr_h2d_corresp_ransac  - Estimate 2-D homography (any) between
%                              point correspondence (allows outlier
%                              check). 
%   mvpr_hnd_corresp_umeyama - Estimate similarity transform in n-D.
%   mvpr_h2d_corresp_dlt     - Construct 2-D homography from point
%                              correspondence using Direct Linear
%                              Transform.
%   Supporting functions for the estimation methods:
%   mvpr_h2d_corresp_isvalid     - Checks if the given point set is
%                                  valid for estimating the specific
%                                  homography.
%   mvpr_hnd_corresp_coorddenorm - Denormalise the transformation
%                                  estimated using normalised
%                                  coordinates.
%   mvpr_hnd_corresp_coordnorm   - Normalise coordinates.
%
%   General functions:
%   mvpr_h2d_version             - Return version string.
%
%   Demos:
%   mvpr_h2d_demo01              - A simple homography demo.
%
% Spatial models of local features.
%   mvpr_h2d_meanmodel - Mean model of K point sets 
%   mvpr_h3d_meanmodel - Mean model of K point sets <EXPERIMENTAL BY JONI>
%
% Gabor features (simple Gabor feature space)
%   mvpr_sg_demo.m                  - Simple Gabor demo script
%   mvpr_sg_createfilterbank.m      - Creates Gabor filter bank
%   mvpr_sg_filterwithbank.m        - Gabor filtering with filterbank
%   mvpr_sg_filterwithbank2.m       - Gabor filtering with filterbank (special)
%   mvpr_sg_resp2samplematrix.m     - Response to sample matrix structure
%   mvpr_sg_normalizesamplematrix.m - Sample matrix normalisation
%   mvpr_sg_createfilterf2.m        - Creates a 2-d Gabor filter in
%                                     frequency domain 
%   mvpr_sg_solvefilterparams.m     - Solve Gabor filter parameters
%   mvpr_sg_plotfilters2            - Displays Gabor filter bank
%   mvpr_sg_scalesamples            - Scale samples (shift in frequency)
%   mvpr_sg_rotatesamples           - Rotate samples (shift in orientation)
%
% Graphics
%   mvpr_gridimage - Plot image set as a single big image (in grid)
%
% See also README.txt.
%
