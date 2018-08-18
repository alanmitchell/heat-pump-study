function y = reshapeNoError( x, m )
%RESHAPENOERROR is a function that takes a vector X and reshapes it into a
%matrix than has M rows using reshape function. Instead of resulting in an
%error when the length of vector X is not divisible by M (like reshape
%function does), reshapeNoError cuts of extra samples at the end of vector
%X to make it reshapable.

newlength = floor(length(x)/m);
y = x(1:newlength*m);
y = reshape(y,m,newlength);

end

