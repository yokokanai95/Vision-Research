function AttentionalBlinkRivalry()
global ptb_drawformattedtext_disableClipping;
ptb_drawformattedtext_disableClipping = 1;
% randomize grating presentation here
% {1 - timing {200, 300, 400, 500, 600}, 2 - target , 3 - eye, 4 - grating}
Lags = [.3 .8 1.1];
TrainingRunOrder = make_trialTypeMatrix(3,4,[length(Lags) 4 2 2]);
same = 3;
insert = [1 1 1 same; 1 2 1 same; 1 3 1 same; 1 4 1 same; 2 1 1 same; 2 2 1 same; 2 3 1 same; 2 4 1 same; 3 1 1 same; 3 2 1 same; 3 3 1 same; 3 4 1 same];
TrainingRunOrder = vertcat(TrainingRunOrder, insert);
RunOrder = Shuffle(1: size(TrainingRunOrder));
RunOrder = TrainingRunOrder(RunOrder,:);
RunOrder = horzcat(RunOrder, zeros(size(RunOrder,1),3));
ROLength = size(RunOrder, 1);

Pad = 1.5;% number of seconds to pad front and backend
monWidth = 28.7;
viewDist = 94;

Screen('Preference', 'SkipSyncTests', 1);
screenInfo = openExperiment(monWidth, viewDist, max(Screen('Screens')));
Screen('ColorRange', screenInfo.curWindow, 255,1);
wPtr= screenInfo.curWindow;
PPD = screenInfo.ppd;
frameDur = screenInfo.frameDur * .001;

 
resp.button =[{'downarrow'} {'leftarrow'} {'uparrow'} {'rightarrow'} {'enter'}]; %  1 = counterclockwise, 2=clockwise 

keylist = zeros(1,256);
for i = 1:length(resp.button)
    keylist(KbName(resp.button{i})) = 1;
end

black = [0 0 0];
red  = [50 0 0];
accred = [255 0 0]
green = [0 255 0];
targDis = 1;

Screen('TextStyle', wPtr,1);
Screen('TextFont', wPtr, 'Helvetica');
  
grating = makeSineGrating(1*screenInfo.ppd,1*screenInfo.ppd, 3.5,135/57.2957795,2 *pi,screenInfo.bckgnd,8,PPD,0,.5 * PPD,screenInfo.bckgnd)-screenInfo.bckgnd;
grating135 = Screen('MakeTexture', wPtr, (grating)+screenInfo.bckgnd);
gratingRect = [0 0 size(grating)];

%load (sprintf('/Users/blakelab/Documents/Research/Jocelyn/Sona_BRO/eyeCal/caldist_%d.mat', 95));
%eye1 = [cal.params{size(cal.params,2)}.x_offset_1 cal.params{size(cal.params,2)}.y_offset_1];
%eye2 = [cal.params{size(cal.params,2)}.x_offset_2 cal.params{size(cal.params,2)}.y_offset_2];
eye1 = [400, 0]
eye2 = [200, 0]
screenInfo.centerLeft=[(screenInfo.screenRect(3)/2)-eye1(1) (screenInfo.screenRect(4)/2)-eye1(2)];
screenInfo.centerRight = [(screenInfo.screenRect(3)/2)+eye2(1) (screenInfo.screenRect(4)/2)-eye2(2)];
fixation = [0, 0, PPD*.2, PPD*.2];
cL = screenInfo.centerLeft;
cR = screenInfo.centerRight;
Lrect = CenterRectOnPoint(fixation, screenInfo.centerLeft(1,1), screenInfo.centerLeft(1,2));
Rrect = CenterRectOnPoint(fixation, screenInfo.centerRight(1,1), screenInfo.centerRight(1,2));

Screen('Flip',wPtr);
shift = [0, PPD*targDis; -PPD*targDis, 0; 0, -PPD*targDis; PPD*targDis, 0];
[letterPosition, texture, sizes, mask] = loadTextures(screenInfo, wPtr, size(RunOrder,1), black, red);
masksize = [sizes(1,1,1,1) sizes(1,1,1,2)];
Screen('DrawText', wPtr, 'Indicate the direction of the red target once you see a mixture', 100, 400);
Screen('DrawText', wPtr, 'Press any key to begin each trial', 100, 500);    
Screen('Flip',wPtr);

[numDur] = targetCalibration(Lrect, Rrect, cL, cR, wPtr, letterPosition, texture, sizes, mask, shift, frameDur, resp,masksize);
%numDur = .05
maskDur = .29 - numDur;
disp(numDur);
 
for i = 1:ROLength
    
    scrap = 0;
    while scrap == 0
       [scrap, start, keyCode] = PsychHID('KbCheck');
    end  
    Screen('FillOval', wPtr, black, Lrect);   
    Screen('FillOval', wPtr, black, Rrect);
    Screen('Flip', wPtr);
    Screen('FillOval', wPtr, black, Lrect);
    Screen('FillOval', wPtr, black, Rrect);
    % {1 - timing {200, 300, 400, 500, 600}, 2 - target , 3 - eye, 4 -
    % grating}
    SOA = rand(1)*2+.5;
    target = RunOrder(i,2);
    eye = RunOrder(i,3);
    if eye==1
        cen = cL;
    else
        cen = cR;
    end
    for k = 1:2
        if eye==k
            cen = cL;
        else
            cen = cR;
        end
    for j = 1:4
        try
            curX = cen(1,1) + shift(j,1);
            curY = cen(1,2) + shift(j,2);
            map2Ref = 1 + mod(j+letterPosition(i,5),4);
            if target == j
                
                Screen('DrawTexture', wPtr, texture(2,map2Ref) , [], CenterRectOnPoint([0,0,sizes(2,map2Ref,1,2),sizes(2,map2Ref,1,1)], curX, curY));
            else
                Screen('DrawTexture', wPtr, texture(1,map2Ref) , [], CenterRectOnPoint([0,0,sizes(1,map2Ref,1,2),sizes(1,map2Ref,1,1)], curX, curY));
            end
            
        catch ME
            sca;
            rethrow(ME);
            return;
        end
    end 
    end
    
    [timeStamp1 a b c d] = Screen('Flip',wPtr, start + SOA - .5 * frameDur);
    Screen('FillOval', wPtr, black, Lrect);
    Screen('FillOval', wPtr, black, Rrect);
    for k = 1:2
        if eye==k
            cen = cL;
        else
            cen = cR;
        end
    for j = 1:4
        try
            curX = cen(1,1) + shift(j,1);
            curY = cen(1,2) + shift(j,2);
            Screen('DrawTexture', wPtr, mask, [], CenterRectOnPoint([0,0,masksize(2),masksize(1)], curX, curY)); 
        catch ME
            sca;
            rethrow(ME);
            return;
        end;
    end
    end
    
    Screen('Flip',wPtr, start + SOA + numDur - .5 * frameDur); 
    Screen('FillOval', wPtr, black, Lrect);
    Screen('FillOval', wPtr, black, Rrect);
    Screen('Flip',wPtr, start + SOA + numDur + maskDur - .5 * frameDur);
    Screen('FillOval', wPtr, black, Lrect);
    Screen('FillOval', wPtr, black, Rrect);
    % {1 - timing {200, 300, 400, 500, 600}, 2 - target , 3 - eye, 4 -
    % grating}
    if RunOrder(i,4) == 3
        temp = randi([1 2], 1, 1)
        Screen('DrawTexture', wPtr, grating135, [], CenterRectOnPoint(gratingRect, cL(1,1),cL(1,2)), (temp - 1) * 90);
        Screen('DrawTexture', wPtr, grating135, [], CenterRectOnPoint(gratingRect, cR(1,1),cR(1,2)), (temp - 1) * 90);
    end
    Screen('DrawTexture', wPtr, grating135, [], CenterRectOnPoint(gratingRect, cL(1,1),cL(1,2)), (RunOrder(i,4)-1) * 90);
    Screen('DrawTexture', wPtr, grating135, [], CenterRectOnPoint(gratingRect, cR(1,1),cR(1,2)), (RunOrder(i,4)-1) * 90 + 90);
    % {1 - timing {200, 300, 400, 500, 600}, 2 - target , 3 - eye, 4 -
    % grating}
    [timeStamp2 a b c d] = Screen('Flip',wPtr, start + SOA + Lags(RunOrder(i,1)) - .5 * frameDur);
    start = GetSecs(); 
    TgtResp=[];
    while isempty(TgtResp)
        [keyIsDown,secs, RespCode] = KbCheck();
        if keyIsDown
            tmp = find(RespCode == 1)
            TgtResp = find(KbName(resp.button(1:4)) == tmp(1));
            if TgtResp>4
                
                TgtResp =[];
            else 
                deltaSecs = secs - timeStamp2;
            end
        end
        secs =[];
        RespCode =[];
    end
    Screen('Flip',wPtr);
    % {1 - timing {200, 300, 400, 500, 600}, 2 - target , 3 - eye, 4 -
    % grating}
    accuracy = (RunOrder(i,2) == TgtResp)
    RunOrder(i,5) = accuracy;
    RunOrder(i,6) = deltaSecs;
    RunOrder(i,7) = timeStamp2 - timeStamp1;
    
    if (accuracy)
        Screen('FillOval', wPtr, green, Lrect);
        Screen('FillOval', wPtr, green, Rrect);
    else
        Screen('FillOval', wPtr, accred, Lrect);
        Screen('FillOval', wPtr, accred, Rrect);
    end
    WaitSecs(.5);
    Screen('Flip',wPtr);
end 
disp(RunOrder(:,:));
currdir = pwd;
eval(['save ', currdir, 'data', 95, '.mat RunOrder']);
disp(numDur);
return;

%% ---------------------------------------------------------------------
%=====================================================================
%%% Subfunctions %%%
%=====================================================================
%% ---------------------------------------------------------------------

function screenInfo = openExperiment(monWidth, viewDist, curScreen)
% screenInfo = openExperiment(monWidth, viewDist, curScreen)
% Arguments:
%	monWidth ... viewing width of monitor (cm)
%	viewDist     ... distance from the center of the subject's eyes to
%	the monitor (cm)
%   curScreen         ... screen number for experiment
%                         default is 0.
% Sets the random number generator, opens the screen, gets the refresh
% rate, determines the center and ppd, and stops the update process
% Used by both my dot code and my touch code.
% MKMK July 2006

HideCursor
mfilename
% 1. SEED RANDOM NUMBER GENERATOR

screenInfo.rseed = sum(100*clock);
rand('state',screenInfo.rseed);

% ---------------
% open the screen
% ---------------

% make sure we are using openGL
AssertOpenGL;
PsychJavaTrouble;

if nargin < 3
    curScreen = 1;
end

%%%%

% Set the background to the background value.
screenInfo.bckgnd = 128;
[screenInfo.curWindow, screenInfo.screenRect] = Screen('OpenWindow', curScreen, screenInfo.bckgnd,[],32, 2);
Screen('TextSize',screenInfo.curWindow,22);
Screen('BlendFunction', screenInfo.curWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%Screen('BlendFunction', screenInfo.curWindow, GL_ONE, GL_ZERO);
Screen('TextSize',screenInfo.curWindow,20);
screenInfo.dontclear = 0; % 1 gives incremental drawing (does not clear buffer after flip)

%get the refresh rate of the screen
% need to change this if using crt, would be nice to have an if
% statement...
%screenInfo.monRefresh = Screen(curWindow,'FrameRate');
screenInfo.spf =Screen('GetFlipInterval', screenInfo.curWindow);      % seconds per frame
screenInfo.monRefresh = 1/screenInfo.spf;    % frames per second
screenInfo.frameDur = 1000/screenInfo.monRefresh;

screenInfo.center = [screenInfo.screenRect(3) screenInfo.screenRect(4)]/2;   	% coordinates of screen center (pixels)

% determine pixels per degree
screenInfo.ppd = pi * screenInfo.screenRect(3) / atan(monWidth/viewDist/2) / 360;    % pixels per degree

% if reward system is hooked up, rewardOn = 1, otherwise rewardOn = 0;
screenInfo.rewardOn = 0;

return
% ________________________________________________________________________


function trialTypeMatrix = make_trialTypeMatrix(nReps,nFactors,nLevelsPerFactor)
%============================================
% Function: make_trialTypeMatrix
% Purpose:  Sets up a matrix that can serve as condition indexes. The
%           matrix has as many rows are there are trials. The number of
%           trials is determined by the nReps*prod(nLevelsPerFactor).
%           Each column is a factor. The intent is that the values can
%           be used as indicies or identifiers for different levels of
%           that factor.
% Usage:
% trialTypeMatrix = make_trialTypeMatrix(nReps,nFactors,nLevelsPerFactor)
%
% Input:    nReps:       The number of replications of all the conditions
%           nFactors:    The number of conditions or factors in the design
%           nLevelsPerFactor: A column vector that is 1 x nFactors in
%           length. Each entry holds the number of levels of that
%           condition.
%
% Output:   trialTypeMatrix: A 2-D matrix that is nTrials long
%                            (nReps*prod(nLevelsPerFactor)) and
%                            has as many columns as factors.
%
% Author:   Barry Giesbrecht
% Date:     July 12, 2005
%==============================================

trialTypeMatrix = zeros(nReps*prod(nLevelsPerFactor),nFactors);

iFactor = 1;
while iFactor <= nFactors
    for iRep=1:nReps
        trialIdx = (prod(nLevelsPerFactor)*(iRep-1))+1;
        nTrialsPerLevel = prod(nLevelsPerFactor)/nLevelsPerFactor(iFactor);
        howFastThisFactor = prod(nLevelsPerFactor)/prod(nLevelsPerFactor(1:iFactor));
        
        trialsThisRep = 1;
        while trialsThisRep <= prod(nLevelsPerFactor)
            for thisFac = 1:nLevelsPerFactor(iFactor)
                for thisSpeed = 1:howFastThisFactor
                    trialTypeMatrix(trialIdx,iFactor) = thisFac;
                    trialIdx = trialIdx+1;
                    trialsThisRep = trialsThisRep + 1;
                end
            end
        end
    end
    iFactor = iFactor+1;
end

return;
%______________________________________________________________
%___________________________________________________________
function [Texture, TxtSize] = MakeTextTexture(ThisText, TextColor, screenInfo)
% ===================================================
%purpose: take string, and create a texture
%Input, string + screenInfo struct from openExperiment function
%Key is screenInfo.DrawWindow = offscreen window
%       screenInfo.center (x,y) coordinates of screen
%output: texture the size of the letter.
% date: March 2012
% author: Jocelyn
% =============================================
% make sure you have the background color

Screen('TextStyle', screenInfo.curWindow,0);
Screen('TextFont', screenInfo.curWindow, 'Helvetica');


Screen('TextSize',screenInfo.curWindow,40);
Screen('FillRect', screenInfo.curWindow, screenInfo.bckgnd, screenInfo.screenRect);
% Define text
TextString=[ThisText];
[normBoundsRect]=Screen('TextBounds',screenInfo.curWindow, TextString);
Screen('DrawText',screenInfo.curWindow,TextString, screenInfo.center(1)-round(normBoundsRect(3)/2),screenInfo.center(2)-round(normBoundsRect(4)/2),TextColor);
Screen('Flip', screenInfo.curWindow);
img = Screen('GetImage', screenInfo.curWindow,CenterRectOnPoint(normBoundsRect,screenInfo.center(1),screenInfo.center(2)));
TxtSize = size(img);
Texture=Screen('MakeTexture', screenInfo.curWindow, img);
return
% _________________________________________________________
function [letterPosition, texture, sizes, mask] = loadTextures(screenInfo, wPtr, ordersize, black, red)
    letterPosition1 = zeros(ordersize / 2, 2);
    letterPosition1(:,1) = '3';
    letterPosition1(:,2) = '8';
    letterPosition2 = zeros(ordersize / 2, 2);
    letterPosition2(:,1) = '8';
    letterPosition2(:,2) = '3';
    letterPosition3 = vertcat(letterPosition1,letterPosition2);
    order = Shuffle(1: size(letterPosition3));
    shuffled3s = letterPosition3(order,:);
    letterPosition1 = zeros(ordersize / 2, 2);
    letterPosition1(:,1) = '6';
    letterPosition1(:,2) = '9';
    letterPosition2 = zeros(ordersize / 2, 2);
    letterPosition2(:,1) = '9';
    letterPosition2(:,2) = '6';
    letterPosition3 = vertcat(letterPosition1,letterPosition2);
    order = Shuffle(1: size(letterPosition3));
    shuffled6s = letterPosition3(order,:);
    letterPosition = [];
    for i = 1:ordersize
        letterPosition = vertcat(letterPosition,[shuffled3s(i,1), shuffled6s(i,1), shuffled3s(i,2), shuffled6s(i,2), randi(4) - 1]);
    end
    texture = [];
    sizes = [];
    %targetcolor = [[0,0,0],[255,0,0]];
    try
        [texture(1,1), sizes(1,1,:,:)] = MakeTextTexture('3', black, screenInfo);
        [texture(1,2), sizes(1,2,:,:)] = MakeTextTexture('6', black, screenInfo);
        [texture(1,3), sizes(1,3,:,:)] = MakeTextTexture('8', black, screenInfo);
        [texture(1,4), sizes(1,4,:,:)] = MakeTextTexture('9', black, screenInfo);
        [texture(2,1), sizes(2,1,:,:)] = MakeTextTexture('3', red, screenInfo);
        [texture(2,2), sizes(2,2,:,:)] = MakeTextTexture('6', red, screenInfo);
        [texture(2,3), sizes(2,3,:,:)] = MakeTextTexture('8', red, screenInfo);
        [texture(2,4), sizes(2,4,:,:)] = MakeTextTexture('9', red, screenInfo);
        [mask, masksize] = MakeTextTexture('$', black, screenInfo);
        
        
    catch ME
        sca;
        rethrow(ME); 
        return;
    end
return;

function [targetDur] = targetCalibration(Lrect, Rrect, cL, cR, wPtr, letterPosition, texture, sizes, mask, shift, frameDur, resp, masksize)
black = [0 0 0];
green = [0 255 0];
accred = [255 0 0];
calDur = [.03 .04 .05 .06 .07]; 
targetCalMatrix = make_trialTypeMatrix(5,2,[length(calDur) 4]);
order = Shuffle(1: size(targetCalMatrix));
targetCalMatrix = targetCalMatrix(order,:);
tarCalLength = size(targetCalMatrix,1); 
targetCalMatrix = horzcat(targetCalMatrix, zeros(tarCalLength, 1));
for i = 1:tarCalLength
    scrap = 0;
    while scrap == 0
       [scrap, start, keyCode] = PsychHID('KbCheck');
    end
    Screen('FillOval', wPtr, black, Lrect);   
    Screen('FillOval', wPtr, black, Rrect);
    Screen('Flip', wPtr);
    Screen('FillOval', wPtr, black, Lrect);
    Screen('FillOval', wPtr, black, Rrect);

    SOA = rand(1) + .5;
    target = targetCalMatrix(i,2);
    curDur = calDur(targetCalMatrix(i,1));
    maskDur = .3 - curDur;
    leftor = randi ([1 2],1,1);
    for j = 1:4
        try
            if (leftor == 1)
                cen = cL;
            else
                cen = cR;
            end
            curX = cen(1,1) + shift(j,1) ;
            curY = cen(1,2) + shift(j,2);
            map2Ref = 1 + mod(j+letterPosition(i,5),4); 
            if target == j
                Screen('DrawTexture', wPtr, texture(2,map2Ref) , [], CenterRectOnPoint([0,0,sizes(2,map2Ref,1,2),sizes(2,map2Ref,1,1)], curX, curY));
            else
                Screen('DrawTexture', wPtr, texture(1,map2Ref) , [], CenterRectOnPoint([0,0,sizes(1,map2Ref,1,2),sizes(1,map2Ref,1,1)], curX, curY));
            end
             
        catch ME
            sca;
            rethrow(ME);
            return;
        end
    end 
    
    [timeStamp1 a b c d] = Screen('Flip',wPtr, start + SOA - .5 * frameDur);
    Screen('FillOval', wPtr, black, Lrect);
    Screen('FillOval', wPtr, black, Rrect);
    for j = 1:4
        try
            curX = cen(1,1) + shift(j,1);
            curY = cen(1,2) + shift(j,2);
            Screen('DrawTexture', wPtr, mask, [], CenterRectOnPoint([0,0,masksize(2),masksize(1)], curX, curY)); 
        catch ME
            sca;
            disp('caught at 439');
            rethrow(ME);
            return;
        end;
    end
    
    Screen('Flip',wPtr, start + SOA + curDur - .5 * frameDur); 
    Screen('FillOval', wPtr, black, Lrect);
    Screen('FillOval', wPtr, black, Rrect);
    Screen('Flip',wPtr, start + SOA + curDur + maskDur - .5 * frameDur);
    TgtResp=[]; 
    while isempty(TgtResp)
        [keyIsDown,secs, RespCode] = KbCheck();
        if keyIsDown
            tmp = find(RespCode == 1)
            TgtResp = find(KbName(resp.button(1:4)) == tmp(1));
            if TgtResp>4
                
                TgtResp =[];
            end
        end
        secs =[];
        RespCode =[];
    end
    Screen('Flip',wPtr);
    accuracy = (target == TgtResp);
    targetCalMatrix(i,3) = accuracy;
    
    if (accuracy)
        Screen('FillOval', wPtr, green, Lrect);
        Screen('FillOval', wPtr, green, Rrect);
    else
        Screen('FillOval', wPtr, accred, Lrect);
        Screen('FillOval', wPtr, accred, Rrect);
    end
    WaitSecs(.5);
    Screen('Flip',wPtr);
end
targetCalMatrix = sortrows(targetCalMatrix);
disp(targetCalMatrix);
meanAcc = [mean(targetCalMatrix(1:20, 3)) mean(targetCalMatrix(21:40, 3)) mean(targetCalMatrix(41:60, 3)) mean(targetCalMatrix(61:80, 3)) mean(targetCalMatrix(81:100, 3))];
found = false; 
disp(meanAcc);
for i = 1:5
   if (found == false && meanAcc(i) > .8)
       found = true;
       targetDur = calDur(i);
   end
end
if (found == false)
    disp('error: could not calibrate');
    sca;
end
return;

function [img] = makeSineGrating(ih,iw,freq,angle,phase,mean,amp,pixPerDeg,r1,r2,bcolor);

% usage: [img] = makeSineGrating(ih,iw,freq,angle,phase,mean,amp,pixPerDeg,r1,r2,bcolor)
%
% Function makes sine-wave grating and presents it either in a rectangle, circle or annulus aperature
%
% ih = image height, iw = image width (in pixels)
% freq = grating frequency in either: cycles/degree (if pixPerDeg specified) or cyc/stimulus width (iw)
% angle = angle of grating, 0=horizontal, pi/2=vertical
% mean = mean intensity level
% amp = amplitude of sinewave
% r1 and r2 = inner and outer radii of annulus (r1=0 makes circle), program makes rectangle if not specified
%
% created by Frank Tong on 2000/01/10
%disp('In makeSineGrating')
if nargin < 11; bcolor = mean; end		% bcolor = background color, default value = mean intensity

if nargin < 8; pixPerDeg = 0; end		% set pixPerDeg to 0 to specify freq in cycles/stimulus
if pixPerDeg > 0
    freq = iw/pixPerDeg*freq;			% convert freq to cycles/degree
end

[X,Y] = meshgrid(0:(iw-1),0:(ih-1));	% specify range of meshgrid
img = (sin(freq*2*pi/iw*(X.*sin(angle)+Y.*cos(angle))-phase));		% make sine wave, range from -1 to 1
img = img*amp+mean;		% values range from mean-amp to mean+amp
img(img>255) = 255;
img(img<0) = 0;

if mean > 1	| amp >1					% likely for ranges 0-255 rather than 0-1
    img = round(img);					% round img values
end


if nargin > 9							% make circle or annulus aperature
    r=sqrt((X-round(iw/2)).^2+(Y-round(ih/2)).^2); 	% calculate eccentricity of each point in grid relative to center
    img(r>r2 | r<r1) = bcolor;
end

return
%__________________________________________________________________________


