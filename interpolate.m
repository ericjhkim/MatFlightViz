% Interpolation function

function new_vec = my_interp(old_vec,len)
    xo = 1:length(old_vec);
    xn = linspace(1,length(old_vec),len);
    new_vec = interp1(xo,old_vec,xn);
end