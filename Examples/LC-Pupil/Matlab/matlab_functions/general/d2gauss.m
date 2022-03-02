function h = d2gauss(n1,std1,n2,std2,theta)
% function h = d2gauss(n1,std1,n2,std2,theta)
% This function returns a 2D Gaussian filter with size n1*n2; theta is 
% the angle that the filter rotated counter clockwise; and sigma1 and sigma2
% are the standard deviation of the Gaussian functions.
r=[cos(theta) -sin(theta);
   sin(theta)  cos(theta)];
for i = 1 : n2 
    for j = 1 : n1
        u = r * [j-(n1+1)/2 i-(n2+1)/2]';
        h(i,j) = gauss(u(1),std1)*gauss(u(2),std2);
    end
end
h = h / sqrt(sum(sum(h.*h)));
