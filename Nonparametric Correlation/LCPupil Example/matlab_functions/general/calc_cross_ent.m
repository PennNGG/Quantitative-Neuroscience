function [e,evc] = calc_cross_ent(choice,choicehat)
% function [e,evc] = calc_cross_ent(choice,choicehat)
% calculates cross-entropy error function

evc = choice.*log(choicehat) + (1-choice).*log(1-choicehat);

e = -sum(evc);