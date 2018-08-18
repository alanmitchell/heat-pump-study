function y = resampleByAvg( x, n )
%RESAMPLEBYAVG is a function that resamples X to a lower sample rate by
%averageing N adjacent samples. If the length of X is not divisible by N,
%the extra samples at the end are lost.

newlength = floor(length(x)/n);
y = x(1:newlength*n);
y = reshape(y,n,newlength);
y = nanmean(y);

%Shape y the same way as x with respect to row vector versus column vector:
[n_rows,n_columns] = size (x);
if n_columns==1
    y=y';
end

end

