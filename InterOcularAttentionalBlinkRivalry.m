function testPsychToolbox()
global ptb_drawformattedtext_disableClipping;
ptb_drawformattedtext_disableClipping = 1;
Design = [];
% randomize grating presentation here
TrainingRunOrder = make_trialTypeMatrix(1,6,[1 5 10 4 2 2]);
RunOrder = Shuffle(1: size(TrainingRunOrder));
RunOrder = TrainingRunOrder(RunOrder,:);
RunOrder = horzcat(RunOrder, zeros(size(RunOrder,1),2));

Pad = 1.5;% number of seconds to pad front and backend
monWidth = 28.7;
viewDist = 94;
stim.TextSize =16;

Screen('Preference', 'SkipSyncTests', 1);
screenInfo = openExperiment(monWidth, viewDist, max(Screen('Screens')));
Screen('ColorRange', screenInfo.curWindow, 255,1);
wPtr= screenInfo.curWindow;  
 
resp.button =[{'downarrow'} {'leftarrow'} {'uparrow'} {'rightarrow'} {'enter'}]; %  1 = counterclockwise, 2=clockwise 

keylist = zeros(1,256);
for i = 1:length(resp.button)
    keylist(KbName(resp.button{i})) = 1;
end

black = [0 0 0];
white = [255 255 255];
red  = [255,0, 0];
   
Screen('FillRect', wPtr, white); 

screenInfo.centerLeft=[(screenInfo.screenRect(3)/2)-400 (screenInfo.screenRect(4)/2)];
screenInfo.centerRight = [(screenInfo.screenRect(3)/2)+400 (screenInfo.screenRect(4)/2)];
fixation = [0, 0, 20, 20];
Lrect = CenterRectOnPoint(fixation, screenInfo.centerLeft(1,1), screenInfo.centerLeft(1,2));
Rrect = CenterRectOnPoint(fixation, screenInfo.centerRight(1,1), screenInfo.centerRight(1,2));
shift = [0, 100, 0, 100; -100, 0, -100, 0; 0, -100, 0, -100; 100, 0, 100, 0];
color = [black; black; black; black];
%make this look better
    letterPosition1 = zeros(size(RunOrder,1) / 2, 2);
    letterPosition1(:,1) = '3';
    letterPosition1(:,2) = '8';
    letterPosition2 = zeros(size(RunOrder,1) / 2, 2);
    letterPosition2(:,1) = '8';
    letterPosition2(:,2) = '3';
    letterPosition3 = vertcat(letterPosition1,letterPosition2);
    order = Shuffle(1: size(letterPosition3));
    shuffled3s = letterPosition3(order,:);
    letterPosition1 = zeros(size(RunOrder,1) / 2, 2);
    letterPosition1(:,1) = '6';
    letterPosition1(:,2) = '9';
    letterPosition2 = zeros(size(RunOrder,1) / 2, 2);
    letterPosition2(:,1) = '9';
    letterPosition2(:,2) = '6';
    letterPosition3 = vertcat(letterPosition1,letterPosition2);
    order = Shuffle(1: size(letterPosition3));
    shuffled6s = letterPosition3(order,:);
    letterPosition = [];
    for i = 1:size(RunOrder,1)
        letterPosition = vertcat(letterPosition,[shuffled3s(i,1), shuffled6s(i,1), shuffled3s(i,2), shuffled6s(i,2), randi(4) - 1]);
    end
    textures = [];
    sizes = [];
    %targetcolor = [[0,0,0],[255,0,0]];
        [texture(1,1), sizes(1,1,:,:)] = MakeTextTexture('3', black, screenInfo);
        [texture(1,2), sizes(1,2,:,:)] = MakeTextTexture('6', black, screenInfo);
        [texture(1,3), sizes(1,3,:,:)] = MakeTextTexture('8', black, screenInfo);
        [texture(1,4), sizes(1,4,:,:)] = MakeTextTexture('9', black, screenInfo);
        [texture(2,1), sizes(2,1,:,:)] = MakeTextTexture('3', red, screenInfo);
        [texture(2,2), sizes(2,2,:,:)] = MakeTextTexture('6', red, screenInfo);
        [texture(2,3), sizes(2,3,:,:)] = MakeTextTexture('8', red, screenInfo);
        [texture(2,4), sizes(2,4,:,:)] = MakeTextTexture('9', red, screenInfo);
for i = 1:4
    SOA = rand(1)*2+.5;
    WaitSecs(SOA);
    Screen('FillRect', wPtr, black, Lrect);
    Screen('FillRect', wPtr, black, Rrect);
    target = RunOrder(i,4);
    temp = color;
    temp(target,:) = red;
    
    eye = RunOrder(i,5);
    if eye==1
        eyeRect = Lrect;
    else
        eyeRect = Rrect;
    end
    for j = 1:4
        try
            Screen('TextStyle', wPtr,1);
            % DrawFormattedText(wPtr,letterPosition(i,1 + mod(j+letterPosition(i,5),4)),eyeRect(1,1)+shift(j,1),eyeRect(1,2)+shift(j,2),temp(j,:),0,0,0,1,0,eyeRect+shift(j,:));
            if target == j
                Screen('DrawTexture', wPtr, texture(2,1 + mod(j+letterPosition(i,5),4)) , [], eyeRect + shift(j, :));
            else
                Screen('DrawTexture', wPtr, texture(1,1 + mod(j+letterPosition(i,5),4)) , [], eyeRect + shift(j, :));
            end
            
        catch ME
            sca;
            rethrow(ME);
            return;
        end
    end
    Screen('Flip',wPtr);
    start = GetSecs();
    Screen('FillRect', wPtr, black, Lrect);
    Screen('FillRect', wPtr, black, Rrect);
    pause(.1);
    Screen('Flip',wPtr);
    TgtResp=[];
    while isempty(TgtResp)
        [keyIsDown,secs, RespCode] = KbCheck();
        if keyIsDown
            tmp = find(RespCode == 1)
            TgtResp = find(KbName(resp.button(1:4)) == tmp(1));
            if TgtResp>4
                
                TgtResp =[];
            else 
                deltaSecs = secs - start;
            end
        end
        secs =[];
        RespCode =[];
    end
    Screen('Flip',wPtr);
    responseTime = deltaSecs;
    RunOrder(i,7) = (RunOrder(i,4) == TgtResp);
    RunOrder(i,8) = responseTime;
end
sca;

disp(RunOrder(1:4,:));
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
function [Texture TxtSize] = MakeTextTexture(ThisText, TextColor, screenInfo)
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


