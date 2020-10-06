function [outputArg] = sat(inputArg,upper_bound, lower_bound)
%SAT Summary of this function goes here
%   Detailed explanation goes here
if nargin == 2
    if size(upper_bound,1) == size(inputArg, 1) * 2
        lower_bound = -upper_bound(size(upper_bound, 1)/2+1:end);
        upper_bound = upper_bound(1:size(upper_bound, 1)/2);
    else
        lower_bound = -upper_bound;
    end
end
outputArg = inputArg;
I = find(outputArg < lower_bound);
outputArg(I) = lower_bound(I);
I = find(outputArg > upper_bound);
outputArg(I) = upper_bound(I);
end

