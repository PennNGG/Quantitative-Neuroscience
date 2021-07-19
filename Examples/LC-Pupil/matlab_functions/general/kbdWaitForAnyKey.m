function kbdWaitForAnyKey
% function kbdWaitForAnyKey

keyIsDown = 0;

% wait until key pressed
while ~keyIsDown
    [keyIsDown, t, k]= PsychHID('KbCheck');
end

% wait until key released
while keyIsDown
    [keyIsDown, t, k]= PsychHID('KbCheck');
end
