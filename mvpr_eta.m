function [remaining, total] = mvpr_eta(cur, tot, printIt)
% function [remaining, total] = eta(cur, tot, params)
% This function estimates the remaining and the total time of a for loop.
% The only arguments are the current and the last index(-ices)  index of the for
% loop. When having multiple loops, it calculates the final estimate using the 
% current inner loop timings. Therfore, in multiple loops it's indeed
% accurate when the outer loops perform the same number of iterations.
% The function prints be default the remaining and total time and also
% these values back. 
%
% Input:
% cur: the current index(-ices) of the for loop. If there is a single loop,
% it is just a single number. In nested loops, it's a vector with the
% current indices. The far left index corresponds to the most inner loop.
% tot: the last index(-ices) of the for loop. If there is a single loop,
% it is just a single number. In nested loops, it's a vector with the
% last indices. The far left index corresponds to the most inner loop.
% printIt: when set to 1, it prints the remaining and the total time for
% the loop. When set to 0, it prints nothing.
% 
% Example 1:
%
% a = randi(10, 1000, 100) ;
% tic
% for i = 1 : 1000
%   eta(i, 1000) ;
%   s = sum(a(i, :)) ;
% end
% toc
%
% Example 2:
%
% a = randi(10, 20, 100) ;
% tic
% for i = 1 : 20
%   for j = 1 : 100
%   eta([i, j], [20, 100], true) ;
%   s = a(i, j) ^ 2 ;
%   end
% end
% toc
%

%Copyright (c) 2010, Stratis Gavves
%All rights reserved.
%
%Redistribution and use in source and binary forms, with or without 
%modification, are permitted provided that the following conditions are 
%met:
%
%    * Redistributions of source code must retain the above copyright 
%      notice, this list of conditions and the following disclaimer.
%    * Redistributions in binary form must reproduce the above copyright 
%      notice, this list of conditions and the following disclaimer in 
%      the documentation and/or other materials provided with the distribution
%      
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
%AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
%IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
%ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
%LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
%CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
%ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
%POSSIBILITY OF SUCH DAMAGE.

if nargin < 3
    printIt = true ;
end

params.print = printIt ;

if numel(cur) ~= numel(tot)
    error('The arguments ''cur'' and ''tot'' must have the same number of elements.') ;
end

evalin('base', 'emp = exist(''eta_time'') ;') ;
emp = evalin('base', 'emp') ;

if emp == 1
    eta_time = evalin('base', 'eta_time') ;
    times = eta_time.timings(eta_time.timings(:, 1) ~= -1, :) ;
%     if numel(times) <= 1
%         display('More loops needed before printing') ;
%     end
    oldLoopTime = mean(multiEtime(times)) ;
    
    eta_time.timings(2 : end, :) = eta_time.timings(1 : end - 1, :) ;
    eta_time.timings(1, :) = clock ;
    times = eta_time.timings(eta_time.timings(:, 1) ~= -1, :) ;
    loopTime = mean(multiEtime(times))  ;
    if numel(cur) == 1
        curI = cur ;
        totI = tot ;
        cur = cur - (eta_time.ind - 1) ;
        tot = tot - (eta_time.ind - 1) ;
        
        remaining = loopTime * (tot - (cur - 1)) ;
        total = loopTime * tot ;
        
        if remaining < 0
            remaining = 0 ;
        end
        
        if total < 0
            total = 0 ;
        end
        
        % Printing
        if params.print == true
            strIter = ['Iteration: ' num2str(curI) '/' num2str(totI)] ;
            strPerLoop  = ['Per loop: ' num2str(loopTime, '%0.3f') 's'] ;
            if remaining > 3600
                t(1) = floor(remaining / 3600) ;
                t(2) = floor((remaining - t(1) * 3600) / 60) ;
                t(3) = remaining - t(1) * 3600 - t(2) * 60 ;
                t(t < 0) = 0 ;
                strRem = ['Remaining time: ' num2str(t(1), '%u') 'h' num2str(t(2), '%u') 'm' num2str(t(3), '%0.1f') 's'] ;
            elseif remaining > 60
                t(1) = floor(remaining / 60) ;
                t(2) = remaining - t(1) * 60 ;
                t(t < 0) = 0 ;
                strRem = ['Remaining time: ' num2str(t(1), '%u') 'm' num2str(t(2), '%0.1f') 's'] ;
            else
                strRem = ['Remaining time: ' num2str(remaining, '%0.1f') 's'] ;
            end
            if total > 3600
                t(1) = floor(total / 3600) ;
                t(2) = floor((total - t(1) * 3600) / 60) ;
                t(3) = total - t(1) * 3600 - t(2) * 60 ;
                t(t < 0) = 0 ;
                strTot = ['Total time: ' num2str(t(1), '%u') 'h' num2str(t(2), '%u') 'm' num2str(t(3), '%0.1f') 's'] ;
            elseif total > 60
                t(1) = floor(total / 60) ;
                t(2) = total - t(1) * 60 ;
                t(t < 0) = 0 ;
                strTot = ['Total time: ' num2str(t(1), '%u') 'm' num2str(t(2), '%0.1f') 's'] ;
            else
                strTot = ['Total time: ' num2str(total, '%0.1f') 's'] ;
            end
            catstr = [strIter ', ' strRem ', ' strTot ', ' strPerLoop] ;
            if prod(cur) > 1
                disp(repmat(char(8),1,numel(eta_time.disp) + 2));
            end
            disp(catstr) ;
            eta_time.disp = catstr ;
        end
    else
        curI = cur(1) ;
        totI = tot(1) ;
        cur(1) = cur(1) - (eta_time.ind - 1) ;
        tot(1) = tot(1) - (eta_time.ind - 1) ;
        
        diffs = tot - cur ;
        remaining(1) = loopTime * (tot(1) - (cur(1) - 1)) ;
        total(1) = loopTime * tot(1) ;
        remaining(2) = remaining(1) + total(1) * prod(diffs(2 : end)) ;
        total(2) = loopTime * prod(tot) ;
        
        if remaining < 0
            remaining = 0 ;
        end
        
        if total < 0
            total = 0 ;
        end
        
        % Printing
        if params.print == true
            strIter = ['Iter: (' num2str(curI, '%u') num2str(cur(2 : end - 1), ', %u') num2str(cur(end), ', %u')  ') / (' ...
                num2str(totI, '%u') num2str(tot(2 : end - 1), ', %u') num2str(tot(end), ', %u')  ')'] ;
            strPerLoop  = ['Per loop: ' num2str(loopTime, '%0.3f') 's'] ;
            if remaining(1) > 3600
                t(1) = floor(remaining(1) / 3600) ;
                t(2) = floor((remaining(1) - t(1) * 3600) / 60) ;
                t(3) = remaining(1) - t(1) * 3600 - t(2) * 60 ;
                t(t < 0) = 0 ;
                strRem = ['Cur.loop remain: ' num2str(t(1), '%u') 'h' num2str(t(2), '%u') 'm' num2str(t(3), '%0.1f') 's'] ;
            elseif remaining(1) > 60
                t(1) = floor(remaining(1) / 60) ;
                t(2) = remaining(1) - t(1) * 60 ;
                t(t < 0) = 0 ;
                strRem = ['Cur.loop remain: ' num2str(t(1), '%u') 'm' num2str(t(2), '%0.1f') 's'] ;
            else
                strRem = ['Cur.loop remain: ' num2str(remaining(1), '%0.1f') 's'] ;
            end
            
            if total(1) > 3600
                t(1) = floor(total(1) / 3600) ;
                t(2) = floor((total(1) - t(1) * 3600) / 60) ;
                t(3) = total(1) - t(1) * 3600 - t(2) * 60 ;
                t(t < 0) = 0 ;
                strTot = ['Cur.loop total: ' num2str(t(1), '%u') 'h' num2str(t(2), '%u') 'm' num2str(t(3), '%0.1f') 's'] ;
            elseif total(1) > 60
                t(1) = floor(total(1) / 60) ;
                t(2) = total(1) - t(1) * 60 ;
                t(t < 0) = 0 ;
                strTot = ['Cur.loop total: ' num2str(t(1), '%u') 'm' num2str(t(2), '%0.1f') 's'] ;
            else
                strTot = ['Cur.loop total: ' num2str(total(1), '%0.1f') 's'] ;
            end
            
            if remaining(2) > 3600
                t(1) = floor(remaining(2) / 3600) ;
                t(2) = floor((remaining(2) - t(1) * 3600) / 60) ;
                t(3) = remaining(2) - t(1) * 3600 - t(2) * 60 ;
                t(t < 0) = 0 ;
                strRem2 = ['All loops remain: ' num2str(t(1), '%u') 'h' num2str(t(2), '%u') 'm' num2str(t(3), '%0.1f') 's'] ;
            elseif remaining(2) > 60
                t(1) = floor(remaining(2) / 60) ;
                t(2) = remaining(2) - t(1) * 60 ;
                t(t < 0) = 0 ;
                strRem2 = ['All loops remain: ' num2str(t(1), '%u') 'm' num2str(t(2), '%0.1f') 's'] ;
            else
                strRem2 = ['All loops remain: ' num2str(remaining(2), '%0.1f') 's'] ;
            end
            
            if total(2) > 3600
                t(1) = floor(total(2) / 3600) ;
                t(2) = floor((total(2) - t(1) * 3600) / 60) ;
                t(3) = total(2) - t(1) * 3600 - t(2) * 60 ;
                t(t < 0) = 0 ;
                strTot2 = ['All loops total: ' num2str(t(1), '%u') 'h' num2str(t(2), '%u') 'm' num2str(t(3), '%0.1f') 's'] ;
            elseif total(2) > 60
                t(1) = floor(total(2) / 60) ;
                t(2) = total(2) - t(1) * 60 ;
                t(t < 0) = 0 ;
                strTot2 = ['All loops total: ' num2str(t(1), '%u') 'm' num2str(t(2), '%0.1f') 's'] ;
            else
                strTot2 = ['All loops total: ' num2str(total(2), '%0.1f') 's'] ;
            end
            catstr = [strIter ', ' strRem ', ' strTot ', ' strRem2 ', ' strTot2 ', ' strPerLoop] ;
            if prod(cur) > 1
                disp(repmat(char(8), 1, numel(eta_time.disp) + 2));
            end
            disp(catstr) ;
            eta_time.disp = catstr ;
        end
    end
    
    if sum(cur - tot) == 0 || sum(remaining < 0) || sum(total < 0) || 5 * oldLoopTime < loopTime || oldLoopTime / 5 > loopTime
        catstr = 'Reseting clock...' ;
        disp(repmat(char(8), 1, numel(eta_time.disp) + 2));
        disp(catstr) ;
        eta_time.disp = catstr ;
        evalin('base', 'clear eta_time') ;
        return ;
    end
    assignin('base', 'eta_time', eta_time) ;    
elseif emp == 0
    eta_time.timings(1, :) = clock ;
    eta_time.timings(2 : 10, :) = -1 ;
    eta_time.ind = max(cur(1), 1) ;
    eta_time.disp = [] ;
    total = [] ;
    remaining = [] ;
    catstr = ['Iteration: ' num2str(eta_time.ind) '/' num2str(tot(1)) '. Reseting clock.'] ;
    disp(repmat(char(8), 1, numel(eta_time.disp) + 2));
    disp(catstr) ;
    eta_time.disp = catstr ;
    assignin('base', 'eta_time', eta_time) ;
end

end

function df = multiEtime(times)
    df = zeros(size(times, 1) - 1, 1) ;
    for i = 1 : size(times, 1) - 1
        df(i) = etime(times(i, :), times(i + 1, :)) ;
    end
end
