function m = myMode(in)% function m = mode(in)% gets the mode of an array% RCS INFO: $Id: mode.m,v 1.1 1998/12/02 00:06:28 lab Exp lab $%% written by jig% clear the nansin_array = in(find(~isnan(in)));% find the unique valuesuniqs = munique(in_array);% loop through and find the most common entryfound_index = 1;found_length = 0;for i = 1:length(uniqs)  if length(find(in_array==uniqs(i))) > found_length    found_length = length(find(in_array==uniqs(i)));    found_index = i;  end  endm = uniqs(found_index);