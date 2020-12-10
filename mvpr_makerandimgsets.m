%MVPR_MAKE_RAND_SETS Makes random training and test sets from
%                    images listed in a file
%
% [] = mvpr_make_rand_sets(imgListFile_,trPort_,:)  
%
% This function reads images and their class names one by one from
% imgListFile_ which contains one entry per line (lines are copied
% as is):
% <FILE1_1> <FILE1_2> ...
% <FILE2_1> <FILE2_2> ...
% ...
%
% FILEX_1 can, for example, be the image name and FILEX_2, its
% ground truth file name.
% 
% TrPort_ ([0,1]) is selected for the training and remaining for the testing and these
% files with full paths (along with annotation file names) are
% saved to <imgListFile_>_train.txt and <imgListFile_>_test.txt
%
% This function can be useful once you have annotated some set of
% images using the MVPR_ANNO_IMGLIST.M funtion.
%
% Note: The function does not test whether any of the files exist
% or not!
%
% Example:
%  >> make_rand_sets('caltech101/filelists/Faces_easy.txt', 0.5)
%
% Output:
%  Saved to <imgListFile_>_train.<ext> and <imgListFile_>_test.<ext>
%
% Input:
%  imgListFile_ - File containing images to be processed
%  trPort_      - Proportion of training images [0,1]
%
% <Optional>
%  'main_dir'  - Directory appended to the beginning of each file
%                entry - if cell (e.g. {'/foo/images',
%                'foo/groundtruth'}, then appended to according
%                line entries (Def: ''). 
%  'save_dir'  - Where training and testing lists saved (Def. '.')
%  'gt_id'     - Id appended to each entry name: FILE =>
%                FILE<gt_id>.FILEEXT (Def. '', can be cell
%                structure similar to main_dir.
%  'fileid'    - Added to the names of the train and test image
%                files as <ORIGNAME>_<fileid>_train.txt,
%                etc. (Def. '')
%
% Author(s):
%    Joni Kamarainen, MVPR in 2009.
%
% Project:
%  Object3d2d (http://www.it.lut.fi/project/object/)
%
% Copyright:
%   -
%
% References:
%
% See also MVPR_ANNO_IMGLIST.M and MVPR_ANNO_IMGPOINTS.M .
%
function [] = mvpr_makerandimgsets(imgListFile_,trPort_,varargin)

conf = struct('main_dir', '',...
              'save_dir','.',...
              'gt_id', '',...
              'fileid', '');
conf = mvpr_getargs(conf,varargin);


fh = mvpr_lopen(imgListFile_, 'read');
entryLine = mvpr_lread(fh);

[foo saveFileName saveFileExt] = fileparts(imgListFile_);
if isempty(conf.fileid)
    fh_tr = mvpr_lopen([saveFileName '_train' saveFileExt], 'write');
    fh_te = mvpr_lopen([saveFileName '_test' saveFileExt], 'write');
else
    fh_tr = mvpr_lopen([saveFileName '_' conf.fileid '_train' saveFileExt], 'write');
    fh_te = mvpr_lopen([saveFileName '_' conf.fileid '_test' saveFileExt], 'write');
end;

imgNum = 0;
while ~isempty(entryLine)
  imgNum = imgNum+1;
  randNum = rand();
  if (randNum <= trPort_)
    fprintf('\r Img#:%5d -> Training',imgNum);
    write_fh = fh_tr;
  else
    fprintf('\r Img#:%5d -> Testing',imgNum);
    write_fh = fh_te;
  end;

  newLine = [];
  for entryInd = 1:length(entryLine)
      [entryDir entryName entryExt] = fileparts(entryLine{entryInd});
      newLine = sprintf('%s %s', newLine,...
                        [fullfile(conf.main_dir,entryDir,entryName,conf.gt_id) entryExt]);
  end;      
  mvpr_lwrite(write_fh,newLine);

  entryLine = mvpr_lread(fh);
end;
fprintf('\n');
mvpr_lclose(fh);
mvpr_lclose(fh_tr);
mvpr_lclose(fh_te);