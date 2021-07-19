function [a,b,siga,sigb,chi2,q]=xy_linefit(x,y,sigx,sigy)
% fit a line (y = a + b*x) to data with errors in x and y
% The algorithm can be found in Numerical Recipes, chapter 15.3.
% x is the vector of x values, sigx the vector of the associated standard deviations.
% y is the vector of y values, sigy the vector of the associated standard deviations.
% a and b are the estimated parameters, siga and sigb the associated standard errors.
% chi2 is the remaining error, q the chi^2 probability. A small value of q indicates a poor fit.
% J. Ditterich, 8/02

% 05/12/03 JD fixed bug in chi2-test

global xx yy sx sy ww aa offs

% some checks
if var([length(x) length(y) length(sigx) length(sigy)])
    error('XY_LINEFIT: The lengths of all input vectors have to be identical!');
end;

% transpose vectors if necessary
if size(x,1)>size(x,2)
    x=x';
end;

if size(y,1)>size(y,2)
    y=y';
end;

if size(sigx,1)>size(sigx,2)
    sigx=sigx';
end;

if size(sigy,1)>size(sigy,2)
    sigy=sigy';
end;

% initialization
scale=sqrt(var(x)/var(y));
nn=length(x);
xx=x;
yy=y*scale;
sx=sigx;
sy=sigy*scale;
ww=sqrt(sx.^2+sy.^2);

% initial guess
temp=robustfit(xx,yy);
b=temp(2);

% algorithm
offs=0;
ang=[0 atan(b) 0 0 atan(b) 1.571];
ch=[0 0 0 chixy(ang(4)) chixy(ang(5)) chixy(ang(6))];
[temp1,temp2,temp3,temp4,temp5,temp6]=mnbrak(ang(2),ang(3),'chixy');
ang(1)=temp1;
ang(2)=temp2;
ang(3)=temp3;
ch(1)=temp4;
ch(2)=temp5;
ch(3)=temp6;
b=brent(ang(1),ang(2),ang(3),'chixy',1e-3);
chi2=chixy(b);
a=aa;
q=1-gammainc(chi2*.5,.5*(nn-2));
r2=1/sum(ww);
bmx=1e30;
bmn=1e30;
offs=chi2+1;

for j=1:6
    if ch(j)>offs
        d1=abs(ang(j)-b);
        d1=rem(d1,pi);
        d2=pi-d1;
        
        if ang(j)<b
            temp=d1;
            d1=d2;
            d2=temp;
        end;
        
        if d1<bmx
            bmx=d1;
        end;
        
        if d2<bmn
            bmn=d2;
        end;
    end;
end;

if bmx<1e30
    bmx=zbrent('chixy',b,b+bmx,1e-3)-b;
    amx=aa-a;
    bmn=zbrent('chixy',b,b-bmn,1e-3)-b;
    amn=aa-a;
    sigb=sqrt(.5*(bmx^2+bmn^2))/(scale*cos(b)^2);
    siga=sqrt(.5*(amx^2+amn^2)+r2)/scale;
else
    sigb=nan;
    siga=nan;
end;

a=a/scale;
b=tan(b)/scale;

% local functions
function res=chixy(bang);
global xx yy sx sy ww aa offs
b=tan(bang);
ww=(b*sx).^2+sy.^2;
ww=max(1./ww,1e-30*ones(1,length(ww)));
avex=(ww*xx')/sum(ww);
avey=(ww*yy')/sum(ww);
aa=avey-b*avex;
res=ww*(yy-aa-b*xx)'.^2-offs;

function [ax,bx,cx,fa,fb,fc]=mnbrak(ax,bx,func);
fa=feval(func,ax);
fb=feval(func,bx);

if fb>fa
    temp=ax;
    ax=bx;
    bx=temp;
    temp=fa;
    fa=fb;
    fb=temp;
end;

cx=bx+1.618034*(bx-ax);
fc=feval(func,cx);

while fb>fc
    r=(bx-ax)*(fb-fc);
    q=(bx-cx)*(fb-fa);
    temp=max(abs(q-r),1e-20);
    
    if q<r
        temp=-temp;
    end;
    
    u=bx-((bx-cx)*q-(bx-ax)*r)/(2*temp);
    ulim=bx+100*(cx-bx);
    
    if (bx-u)*(u-cx)>0
        fu=feval(func,u);
        
        if fu<fc
            ax=bx;
            bx=u;
            fa=fb;
            fb=fu;
            return;
        elseif fu>fb
            cx=u;
            fc=fu;
            return;
        end;
        
        u=cx+1.618034*(cx-bx);
        fu=feval(func,u);
    elseif (cx-u)*(u-ulim)>0
        fu=feval(func,u);
        
        if fu<fc
            bx=cx;
            cx=u;
            u=cx+1.618034*(cx-bx);
            fb=fc;
            fc=fu;
            fu=feval(func,u);
        end;
    elseif (u-ulim)*(ulim-cx)>=0
        u=ulim;
        fu=feval(func,u);
    else
        u=cx+1.618034*(cx-bx);
        fu=feval(func,u);
    end;
    
    ax=bx;
    bx=cx;
    cx=u;
    fa=fb;
    fb=fc;
    fc=fu;
end;

function [xmin,ymin]=brent(ax,bx,cx,f,tol);
e=0;
a=min(ax,cx);
b=max(ax,cx);
x=bx;
w=bx;
v=bx;
fw=feval(f,x);
fv=fw;
fx=fw;

for iter=1:100
    xm=.5*(a+b);
    tol1=tol*abs(x)+1e-10;
    tol2=2*tol1;
    
    if abs(x-xm)<=(tol2-.5*(b-a))
        xmin=x;
        ymin=fx;
        return;
    end;
    
    if abs(e)>tol1
        r=(x-w)*(fx-fv);
        q=(x-v)*(fx-fw);
        p=(x-v)*q-(x-w)*r;
        q=2*(q-r);
        
        if q>0
            p=-p;
        end;
        
        q=abs(q);
        etemp=e;
        e=d;
        
        if (abs(p)>=abs(.5*q*etemp))|(p<=q*(a-x))|(p>=q*(b-x))
            if x>=xm
                e=a-x;
            else
                e=b-x;
            end;
            
            d=.381966*e;
        else
            d=p/q;
            u=x+d;
            
            if (u-a<tol2)|(b-u<tol2)
                d=abs(tol1);
                
                if xm-x<0
                    d=-d;
                end;
            end;
        end;
    else
        if x>=xm
            e=a-x;
        else
            e=b-x;
        end;
        
        d=.381966*e;
    end;
    
    if abs(d)>=tol1
        u=x+d;
    else
        if d<0
            u=x-tol1;
        else
            u=x+tol1;
        end;
    end;
    
    fu=feval(f,u);
    
    if fu<=fx
        if u>=x
            a=x;
        else
            b=x;
        end;
        
        v=w;
        w=x;
        x=u;
        fv=fw;
        fw=fx;
        fx=fu;
    else
        if u<x
            a=u;
        else
            b=u;
        end;
        
        if (fu<=fw)|(w==x)
            v=w;
            w=u;
            fv=fw;
            fw=fu;
        elseif (fu<=fv)|(v==x)|(v==w)
            v=u;
            fv=fu;
        end;
    end;
end;

error('Too many iterations in brent');

function res=zbrent(func,x1,x2,tol);
a=x1;
b=x2;
c=x2;
fa=feval(func,a);
fb=feval(func,b);

if ((fa>0)&(fb>0))|((fa<0)&(fb<0))
    error('Root must be bracketed in zbrent');
end;

fc=fb;

for iter=1:100
    if ((fb>0)&(fc>0))|((fb<0)&(fc<0))
        c=a;
        fc=fa;
        d=b-a;
        e=d;
    end;
    
    if abs(fc)<abs(fb)
        a=b;
        b=c;
        c=a;
        fa=fb;
        fb=fc;
        fc=fa;
    end;
    
    tol1=2*3e-8*abs(b)+.5*tol;
    xm=.5*(c-b);
    
    if (abs(xm)<=tol1)|(fb==0)
        res=b;
        return;
    end;
    
    if (abs(e)>=tol1)&(abs(fa)>abs(fb))
        s=fb/fa;
        
        if a==c
            p=2*xm*s;
            q=1-s;
        else
            q=fa/fc;
            r=fb/fc;
            p=s*(2*xm*q*(q-r)-(b-a)*(r-1));
            q=(q-1)*(r-1)*(s-1);
        end;
        
        if p>0
            q=-q;
        end;
        
        p=abs(p);
        min1=3*xm*q-abs(tol1*q);
        min2=abs(e*q);
        
        if 2*p<min(min1,min2)
            e=d;
            d=p/q;
        else
            d=xm;
            e=d;
        end;
    else
        d=xm;
        e=d;
    end;
    
    a=b;
    fa=fb;
    
    if abs(d)>tol1
        b=b+d;
    else
        if xm<0
            b=b-tol1;
        else
            b=b+tol1;
        end;
    end;
    
    fb=feval(func,b);
end;

error('Maximum number of iterations exceeded in zbrent');
