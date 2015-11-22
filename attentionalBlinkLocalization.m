function attentionalBlinkLocalization(sj, run, thresh)
% Create Design matrix to store run order.
% Labels: [{1 'SOA'} {2 'post-flash rest'} {3 'target location'}
% {4 'flash eye'} {5 'prime orientation'} {6 'rivalry response time'}
% {7 'target response'}
% SOA between target and mask = 100ms
% flexible ISI between target and mask -- necessarily shorten duration of
% target
% mask duration 100ms
% SOA between target onset and rivalry onset = variable
Design = [];
TrainingRunOrder = make_trialTypeMatrix(1,5,[1 5 4 2 2]);
RunOrder = Shuffle(1: size(TrainingRunOrder));
RunOrder = TrainingRunOrder(RunOrder,:);
empty = zeros(320, 1);
RunOrder = horzcat(RunOrder, empty);
RunOrder = horzcat(RunOrder, empty);
disp(Design);

behavior =1;


Pad = 1.5;% number of seconds to pad front and backend
monWidth = 40.6;%59.7; % in centimeters %%%%%%%%%%COMMENT ME OUT IN THE SCANNER!!!!!!!!!
viewDist = 94;
stim.TextSize =16;

[deviceNumber, productNames, jnk] = GetKeyboardIndices(['Apple Internal Keyboard / Trackpad']);

load /Users/blakelab/Documents/Research/Jocelyn/BROrient/linearizedCLUT.mat
mainscreen = 0; %which screen is main screen
screenInfo = openExperiment(monWidth, viewDist, mainscreen);
Screen('LoadNormalizedGammaTable', screenInfo.curWindow, linearizedCLUT);

Screen('ColorRange', screenInfo.curWindow, 255,1); % [, maximumvalue][, clampcolors=1]
window= screenInfo.curWindow;
% HideCursor

black = [0 0 0]; %find(LumSteps==0) -1;
white = [255 255 255]; %find(LumSteps==1) -1;
red = [255,0, 0];

Priority(9);
KbName('UnifyKeyNames');
number = sprintf(num2str(sj), '%02d');
load (sprintf('/Users/blakelab/Documents/Research/Jocelyn/Sona_BRO/Bullseye/Data/SJ%dBullCalibrate.mat', sj));

load (sprintf('/Users/blakelab/Documents/Research/Jocelyn/Sona_BRO/eyeCal/caldist_%d.mat', sj));
eye1 = [cal.params{size(cal.params,2)}.x_offset_1 cal.params{size(cal.params,2)}.y_offset_1];
eye2 = [cal.params{size(cal.params,2)}.x_offset_2 cal.params{size(cal.params,2)}.y_offset_2];
screenInfo.centerLeft=[(screenInfo.screenRect(3)/2)-eye1(1) (screenInfo.screenRect(4)/2)-eye1(2)];
screenInfo.centerRight = [(screenInfo.screenRect(3)/2)+eye2(1) (screenInfo.screenRect(4)/2)-eye2(2)];
screenInfo.RotLeft = cal.params{size(cal.params,2)}.rot_1;
screenInfo.RotRight = cal.params{size(cal.params,2)}.rot_2;

for i = 1:length(stim.targetradius) %radius of grating in visual angle
    DisplayRadius = screenInfo.ppd*stim.targetradius(i); % distance from fixation in pixels
    
    [Leftxloc(:,:) Leftyloc(:,:)] = getCircleDisplayCoordinate(CircleDivision,screenInfo.centerLeft(1), screenInfo.centerLeft(2), DisplayRadius);
    [Rightxloc(:,:) Rightyloc(:,:)] = getCircleDisplayCoordinate(CircleDivision,screenInfo.centerRight(1), screenInfo.centerRight(2), DisplayRadius);
    
    fix.TgtPositions(i,:,:) = [Leftxloc(:, TargetIdx)' Leftyloc(:, TargetIdx)' Rightxloc(:, TargetIdx)' Rightyloc(:, TargetIdx)'];  % eccen, loc. Last index xyleft, xy right
    
end

return

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
