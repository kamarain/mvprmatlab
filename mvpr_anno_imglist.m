%MVPR_ANNO_IMGLIST Interactive locate feature annotation
%
% [] = mvpr_anno_imglist(imgListFile_,imgMainDir_,saveDir_,
%                        userName_,varargin)  
%
% This function reads images and their class names one by one from
% imgListFile_ which should have the following ascii structure:
%
% <CLASSNAME> <RELATIVE_PATH_TO_IMAGE>
% ...
% ...
% 
% Path is relative to imgMainDir_ . User is let to annotate the
% loaded image and then the annotated points are saved under the
% same name and file structure in saveDir_ . Every file is further
% assigned with the user ID userName_ .
%
% Function is dirty but simple - enjoy.
%
% TODO: this should check annotations of different user names and
% show them with different colours!
%
% Example:
%  >> mvpr_anno_imglist('resources/caltech101_Faces_easy.txt',...
%     '/wrk/www2_projects/mvpr/caltech101/',...
%     '/wrk/www2_projects/mvpr/caltech101/landmarks',...
%     'jkamarai')
%
% Output:
%
% Input:
%  imgListFile_ - File containing images to be processed
%  imgMainDir_  - Directory from where relative file names work
%  saveDir_     - Directory where annotations saved
%  userName_    - ID added to every annotation file name
%
% <optional>
%  'blockSizeX'     - If image processed in block this is width (-1 is
%                     no blocks (DEFAULT)
%  'blockSizeY'     - If image processed in block this is height (-1 is
%                     no blocks (DEFAULT)
%  'maxNumOfPoints' - Maximum for each image (DEFAULT Inf)
%  'minNumOfPoints' - Minimum for each image (DEFAULT 0)
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
% See also MVPR_ANNO_IMGPOINTS.M and MVPR_MAKERANDIMGSETS.M .
%%
function [] = mvpr_anno_imglist(imgListFile_,imgMainDir_,...
                                saveDir_,userName_,varargin)

% Parse input arguments
conf = struct('blockSizeX',-1,...
              'blockSizeY',-1,...
              'maxNumOfPoints',inf,...
              'minNumOfPoints',0,...
              'className',[]);
conf = mvpr_getargs(conf,varargin);

if ~isempty(conf.className)
    disp(['Class name explicitly given, assuming that it does not ' ...
          'exist in the file list.']);
end;
    
%
% 1. Go through all given images and let the user annotate 
%

% open file that contains image and position files
fh = mvpr_lopen(imgListFile_, 'read');

% read image and position file names
entryPair = mvpr_lread(fh);
numOfExamples = 0;
while ~isempty(entryPair)
  numOfExamples = numOfExamples+1;
  entryPair = mvpr_lread(fh);
end;
mvpr_lclose(fh);


fh = mvpr_lopen(imgListFile_, 'read');
loopToFirstEmpty = 0;
for entryNum = 1:numOfExamples
  entryPair = mvpr_lread(fh);
  if isempty(conf.className)
      entryPair{2};
  else
      entryPair{1}; %no class name in the file
  end;
  className = entryPair{1};

  fprintf('Img#:%5d/%5d (class: %s)\n',entryNum,numOfExamples,className);
  
  %
  % First construct the save file name save dot coordinates to file
  % of same name 
  if isempty(conf.className)
      [lmSaveDir lmSaveName foo foo] = fileparts(entryPair{2});
  else
      [lmSaveDir lmSaveName foo foo] = fileparts(entryPair{1});
  end;      
  lmSaveFile = fullfile(saveDir_,...
                        lmSaveDir,...
                        [lmSaveName '_' userName_ '.dot']);
  % mkdir if a case it does not exist
  if (isdir(fileparts(lmSaveFile)) == 0)
    mkdir(fileparts(lmSaveFile));
  end;
  % Check all annotations made by other user name
  otherAnnFiles = dir(fullfile(saveDir_,lmSaveDir,...
                               [lmSaveName '_*' '.dot']));
  clear otherSaveFiles;
  if (length(otherAnnFiles) > 0)
      for annInd = 1:length(otherAnnFiles)
          otherSaveFiles{annInd} = fullfile(saveDir_,lmSaveDir,otherAnnFiles(annInd).name);
      end;
  else
      otherSaveFiles = [];
  end;
  
  readEntry = 1;
  % check that if also point file exists you also reread that
  if ((exist(lmSaveFile,'file') || ~isempty(otherSaveFiles)) && (entryNum == 1))
    loopToFirstEmpty = input('Loop to the first empty (0=> No): ');
  end;
  if (exist(lmSaveFile,'file'))
    initPoints = load(lmSaveFile);
  else
      initPoints = [];
  end;

  if (~isempty(otherSaveFiles))
      clear otherPoints;
      for annInd = 1:length(otherSaveFiles)
          otherPoints{annInd} = load(otherSaveFiles{annInd});
      end;
  else
      otherPoints = [];
  end;
  
  if (loopToFirstEmpty && (exist(lmSaveFile,'file') || ~isempty(otherSaveFiles)))
      readEntry = 0; % skip to next as this already annotated
  end;
  if (readEntry)

      if isempty(conf.className)
          img = imread(fullfile(imgMainDir_,entryPair{2}));
      else;
          img = imread(fullfile(imgMainDir_,entryPair{1}));
      end;

      % get points
    [points modeInfo] = mvpr_anno_imgpoints(img,...
                                            conf.blockSizeX,...
                                            conf.blockSizeY, ...
                                            conf.maxNumOfPoints, ...
                                            'initPoints',initPoints,...
                                            'otherPoints',otherPoints);
    if (~isempty(points))
      pointFid = fopen(lmSaveFile,'w');
      fprintf(pointFid,'%2.2f %2.2f\n',transpose(points));
      fclose(pointFid);
    end;
    if (modeInfo == -1)
      return;
    end;
  end;
  
end;
mvpr_lclose(fh);