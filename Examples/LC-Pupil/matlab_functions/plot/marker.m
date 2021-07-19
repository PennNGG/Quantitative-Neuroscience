function h_=marker(x,y,marker,cmap,markersize,xalign,yalign)
%MARKER  Creates a user defined marker.
%   H = MARKER(X,Y,CDATA[,CMAP[,SIZE[,HALIGN[,VALIGN]]]])  creates a user defined
%   marker CDATA (integer matrix) with colormap CMAP where each integer in CDATA
%   corresponds to a color in CMAP (increasing order). SIZE is the marker size in
%   points. If CDATA is not a square matrix, then the marker's shortest side will be
%   streched so that both its width and height equals SIZE (SIZE defaults to 6).
%   If CMAP is omitted, its colormap will default to b/w. Furthermore, CMAP must have
%   exactly as many rows as the number of different integers in CDATA.
%   MARKER does not yet support transparency.
%   HALIGN is the horizontal alignment and can be either of the following:
%
%      'left'
%      'center'  (default)
%      'right'
%
%   VALIGN is the vertical alignment and can be either of the following:
%
%      'top'
%      'middle'  (default)
%      'bottom'
%
%   Example:
%      cross=[0 0 2 1 2 0 0
%             0 0 0 1 0 0 0
%             2 0 0 1 0 0 2
%             1 1 1 2 1 1 1
%             2 0 0 1 0 0 2
%             0 0 0 1 0 0 0
%             0 0 2 1 2 0 0];
%      cmap=[1 1 1;0 0 1;1 0 1];
%      marker(.5,.5,cross,cmap,6,'cen','bot')
%      axis([0 1 0 1])
%
%   See also PLOT, GET, SET.

% Copyright (c) 2003-07-22, B. Rasmus Anthin.

error(nargchk(3,7,nargin))

if nargin<4
   codes=unique(marker(:));
   cmap=[0 0 0;ones(length(codes)-1,3)];
end
if nargin<5
   msiz=6;
else
   msiz=markersize;
end
if nargin<6
   xalign='c';
end
if nargin<7
   yalign='m';
end

 %if isempty(get(gca,'child')) & ~ishold
 %axis([x-.5 x+.5 y-.5 y+.5]);
 %end
ax=axis;
%delta ticks
dxt=diff(ax(1:2));
dyt=diff(ax(3:4));

units=get(gca,'units');
set(gca,'units','points')
pos=get(gca,'pos');
set(gca,'units',units)

%delta points
dxp=pos(3);
dyp=pos(4);

%ticks per points
xtpp=dxt/dxp;
ytpp=dyt/dyp;

dx=msiz*xtpp;
dy=msiz*ytpp;

switch(xalign(1))
case 'l'
   xpos=[x x+dx];
case 'r'
   xpos=[x-dx x];
otherwise  %case 'c'
   xpos=[x-dx/2 x+dx/2];
end
switch(yalign(1))
case 't'
   ypos=[y-dy y];
case 'b'
   ypos=[y y+dy];
otherwise  %case 'm'
   ypos=[y-dy/2 y+dy/2];
end

marker=flipud(marker);
cdata=zeros([size(marker) 3]);
codes=unique(marker(:));
for i=1:size(marker,1)
   for j=1:size(marker,2)
      cdata(i,j,1:3)=cmap(marker(i,j)==codes,:);
   end
end
h=image(cdata);
set(h,'xdata',xpos)
set(h,'ydata',ypos)
%set(h,'cdatamapping','scaled')
%colormap(cmap)
axis xy
axis(ax)

obj.type='marker';
obj.handle=h;
obj.size=msiz;
obj.cdata=cdata;
obj.x=x;
obj.y=y;
obj.xalign=xalign;
obj.yalign=yalign;
set(h,'userdata',obj)
resizefcn=['MARKER_ch=get(gca,''child'');' ...
           'for MARKER_i=1:length(MARKER_ch),' ...
              'MARKER_chi=MARKER_ch(MARKER_i);' ...
              'MARKER_ud=get(MARKER_chi,''userdata'');' ...
              'if isstruct(MARKER_ud) & isfield(MARKER_ud,''type'') & strcmp(MARKER_ud.type,''marker''),' ...
                 'MARKER_ax=axis;' ...
                 'MARKER_dxt=diff(MARKER_ax(1:2));' ...
                 'MARKER_dyt=diff(MARKER_ax(3:4));' ...
                 'MARKER_units=get(gca,''units'');' ...
                 'set(gca,''units'',''points''),' ...
                 'MARKER_pos=get(gca,''pos'');' ...
                 'set(gca,''units'',MARKER_units),' ...
                 'MARKER_dxp=MARKER_pos(3);' ...
                 'MARKER_dyp=MARKER_pos(4);' ...
                 'MARKER_xtpp=MARKER_dxt/MARKER_dxp;' ...
                 'MARKER_ytpp=MARKER_dyt/MARKER_dyp;' ...
                 'MARKER_dx=MARKER_ud.size*MARKER_xtpp;' ...
                 'MARKER_dy=MARKER_ud.size*MARKER_ytpp;' ...
                 'switch(MARKER_ud.xalign(1)),' ...
                 'case ''l'',' ...
                 '   MARKER_xpos=[MARKER_ud.x MARKER_ud.x+MARKER_dx];' ...
                 'case ''r'',' ...
                 '   MARKER_xpos=[MARKER_ud.x-MARKER_dx MARKER_ud.x];' ...
                 'otherwise,' ...
                 '   MARKER_xpos=[MARKER_ud.x-MARKER_dx/2 MARKER_ud.x+MARKER_dx/2];' ...
                 'end,' ...
                 'switch(MARKER_ud.yalign(1)),' ...
                 'case ''t'',' ...
                 '   MARKER_ypos=[MARKER_ud.y-MARKER_dy MARKER_ud.y];' ...
                 'case ''b'',' ...
                 '   MARKER_ypos=[MARKER_ud.y MARKER_ud.y+MARKER_dy];' ...
                 'otherwise,' ...
                 '   MARKER_ypos=[MARKER_ud.y-MARKER_dy/2 MARKER_ud.y+MARKER_dy/2];' ...
                 'end,' ...
                 'set(MARKER_chi,''xdata'',MARKER_xpos),' ...
                 'set(MARKER_chi,''ydata'',MARKER_ypos),' ...
              'end,' ...
           'end,' ...
           'clear MARKER_ch MARKER_i MARKER_chi MARKER_ud MARKER_held MARKER_ax,' ...
           'clear MARKER_dxt MARKER_dyt MARKER_units MARKER_pos,' ...
           'clear MARKER_dxp MARKER_dyp MARKER_xtpp MARKER_ytpp,' ...
           'clear MARKER_dx MARKER_dy MARKER_xpos MARKER_ypos' ...
        ];
set(gcf,'resizefcn',resizefcn)

set(gca,'xlimmode','auto')
set(gca,'ylimmode','auto')
set(gca,'zlimmode','auto')

if nargout, h_=h;end