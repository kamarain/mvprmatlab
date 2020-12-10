     Machine Vision and Pattern Recognition (MVPR) Matlab Toolbox
     ============================================================

This "toolbox" contains various Matlab functions which have
been developed during research projects. The functions have
been first found reusable and then slowly added to this public
repository.

Mvprmatlab was started in Lappeenranta University of Technology,
but now many of the original authors have moved to other universities
and companies.

Generally all code if free for non-commercial use, but you must check
each individual file for copyrights and licenses! Many functions also
contain references to the publications for which the functions were
developed and the authors appreciate if those publications are
cited by the works using their code.

Note also, that some functions are "wrappers" to existing code
published by other and then you may need to download and install
other (publicly available) code. Instructions are often available
in corresponding functions (via >> help <FUNC>).

Contact author: Joni Kamarainen, Tampere University of Technology

Authors: See each M-file.

Before using any M-files and especially before adding new or editing
existing files you should read this document.

For description of package contents see Contents.m file.

All Matlab m-files should contain sufficient documentation.

Contents
1. How to use/contribute
2. Changelog
3. TODO

                        --- 1. HOWTO ---

I. Use
Just check it out, e.g.,

  $ hg clone https://kamarain@bitbucket.org/kamarain/mvprmatlab

and add it to your Matlab path.

II. Contribute
 1. Rename you file to mvpr_<something>.m (please, use as short and as
    descriptive name as possible).
 2. Make sure that the help information is in accordance with other
    mvpr M-files.
 3. Add information about the project the file was made and add authors. 
 4. Add your file to mvprmatlab.
 5. Add new description to Contents.m  (if there is no appropriate
    section in Contents.m, then introduce a new one). 
 6. Thank you very much for contributing.


                        --- 2. CHANGELOG ---
Major updates:

[Thu Jun 27 17:57:07 EEST 2013]
Added OpenCV detector and descriptor functionality. Compile the binary
under opencv_descriptors and move it to binaries directory. Currently
supported: SIFT, SURF and BRIEF. - lanxu

[Wed Jun  9 14:42:54 EEST 2010]
Added simple Gabor feature functionality. Moved here under the
SimpleGabor project directories in the CVS.


    ***   First version made Thu Oct 1 13:11:46 EEST 2009 ***

$Id: README.txt 24 2010-06-09 11:43:09Z jkamarai $

                        --- 3. TODO ---

1. mvpr_imread should be made to support also colour images!

[h2d Todo]
1. h2d_corresp_isvalid.m should be done properly that it would be 
   reliably used everywhere needed.

2. Iterative gradient based methods should be implemented and along with 
   them different kind of error functions.

