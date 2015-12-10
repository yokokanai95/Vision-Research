function testing() 
% Labels: [{1 'onset'} {2 'post-flash rest'} {3 'target location'}
% {4 'flash eye'} {5 'prime orientation'} {6 'SOA'} {7 'rivalry response time'}
% {8 'target response'}]
Design = [];
TrainingRunOrder = make_trialTypeMatrix(1,6,[1 1 5 2 2 5]);
RunOrder = Shuffle(1: size(TrainingRunOrder));
RunOrder = TrainingRunOrder(RunOrder,:);

Pad = 1.5;
monWidth = 28.7;
viewDist = 94;lk
stim.TextSize =16;

WaitSecs(Pad);

resp.button =[{'downarrow'} {'leftarrow'} {'uparrow'} {'rightarrow'} {'enter'}]; %  1 = counterclockwise, 2=clockwise

keylist = zeros(1,256);
for i = 1:length(resp.button)
    keylist(KbName(resp.button{i})) = 1;
end

Screen('Preference', 'SkipSyncTests', 1);
[wPtr, rect] = Screen('OpenWindow',max(Screen('Screens')));
xCenter = rect(3)/2;
yCenter = rect(4)/2;

black = [0 0 0];
white = [255 255 255];
red = [255,0, 0];

Screen('TextSize', wPtr, 48);
Screen('TextFont', wPtr, 'Helvetica');
Screen('TextStyle', wPtr, 0);
Screen('DrawText', wPtr,  'Press any key', xCenter, yCenter, red);
Screen('Flip',wPtr);
KbWait();
  
centerLeft=[xCenter - 500, yCenter];
centerRight = [xCenter + 500, yCenter];

Lrect = [centerLeft(1) - 50, centerLeft(2) - 50, centerLeft(1) + 50, centerLeft(2) + 50];
Rrect = [centerRight(1) - 50, centerRight(2) - 50, centerRight(1) + 50, centerRight(2) + 50];

WaitSecs(1);
Screen('Flip',wPtr);
drawFixation(wPtr,Lrect,Rrect);
WaitSecs(RunOrder(1,1) + rand(1,1)*2);
if (RunOrder(1,4) == 1)
    showTargets(RunOrder(1,3),black,red,wPtr,centerLeft);
    curRect = Lrect;
else
    showTargets(RunOrder(1,3),black,red,wPtr,centerRight);
    curRect = Rrect;
end
drawFixation(wPtr,  Lrect,Rrect);
WaitSecs(.1);
Screen('Flip',wPtr);
drawFixation(wPtr,Lrect,Rrect);
drawMasks(wPtr,curRect);
if (RunOrder(1,6) == 1)
    drawMasks(wPtr,curRect);
    displayRivalryStim(wPtr,Lrect,Rrect);
    WaitSecs(.1);
    Screen('Flip',wPtr);
    drawFixation(wPtr,Lrect,Rrect);
    displayRivalryStim(wPtr,Lrect,Rrect);
    start = mach_absolutetime();
else
    drawMasks(wPtr,curRect);
    WaitSecs(.1);
    Screen('Flip',wPtr);
    drawFixation(wPtr,Lrect,Rrect);
    WaitSecs((RunOrder(1,6)-2)*.1);
    drawFixation(wPtr,Lrect,Rrect);
    displayRivalryStim(wPtr,Lrect,Rrect);
    start = mach_absolutetime();
end
Screen('Flip',wPtr);
KbWait();
responseTime = mach_absolutetime();
Screen('DrawText', wPtr,  'Where was the target?', xCenter, yCenter, red);

[secs,key] = KbWait();

if (find(key==resp.button(1:4)) == RunOrder(1,3))
    accuracy = 1;
else
    accuracy = 0;
end
trialResult = horzcat(RunOrder(1,:),responseTime,accuracy);
Design = vertCat(Design,trialResult);
Screen('Flip',wPtr);
sca;

return;
  
function drawFixation(wPtr,Lrect,Rrect)
black = [0 0 0];
Screen('FillOval', wPtr, black, Lrect);
Screen('FillOval', wPtr, black, Rrect);
return;

function showTargets(target,black,red,wPtr,eyecenter) 
color3 = black;
color9 = black;
color8 = black;
color6 = black;
if (target == 1)
    color3 = red;
elseif (target == 2)
    color9 = red;
elseif (target == 3)
    color8 = red;
elseif(target == 4)
    color6 = red;
end
Screen('DrawText', wPtr, '3', eyecenter(1), eyecenter(2) + 200, color3);
Screen('DrawText', wPtr, '9', eyecenter(1) - 200, eyecenter(2), color9);
Screen('DrawText', wPtr, '8', eyecenter(1), eyecenter(2) - 200, color8);
Screen('DrawText', wPtr, '6', eyecenter(1) + 200, eyecenter(2), color6);
WaitSecs(.1);
Screen('Flip',wPtr);
return;

function drawMasks(wPtr,rect)
black = [0 0 0];
Screen('FillOval', wPtr, black, plus(rect,[0,-200,0,-200]));
Screen('FillOval', wPtr, black, plus(rect,[200,0,200,0]));
Screen('FillOval', wPtr, black, plus(rect,[0,200,0,200]));
Screen('FillOval', wPtr, black, plus(rect,[-200,0,-200,0]));
return;

function displayRivalryStim(wPtr,Lrect,Rrect)
red = [255,0,0];
Screen('FillOval', wPtr, red, Lrect);
Screen('FillOval', wPtr, red, Rrect);
return;

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