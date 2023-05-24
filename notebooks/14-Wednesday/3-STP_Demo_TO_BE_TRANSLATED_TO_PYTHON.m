% SIMPLE MARKRAM-TSODYKS STP DEMO
% USES IAF_STP.m
close all
figure
set(gcf,'units','normal','position',[0.005 0.04 0.9 0.8])
SP1 = subplot(2,1,1)
set(SP1,'position',[0.1 0.1 0.8 0.6])
hold on
%%% INTERACTIVE GRAPHICS
button1 = uicontrol('units','normal','style','pushbutton','fontsize',[14],'fontweight','bold','String','RUN','position',[0.1 0.8 0.12 0.08],'Callback','[V RELEASE]=IAF_STP(1:max(str2num(get(P4,''string'')))+100,str2num(get(P4,''string'')),str2num(get(P1,''string'')),str2num(get(P2,''string'')),str2num(get(P3,''string'')),0);');
%resetbutton = uicontrol('units','normal','style','pushbutton','String','RESET','position',[0.05 0.05 0.1 0.08],'Callback','XOR_demo;');

%Paramaters
P1 = uicontrol('units','normal','style','edit','String',num2str(0.5),'position',[0.25 0.8 0.07 0.05]);
P2 = uicontrol('units','normal','style','edit','String',num2str(200),'position',[0.4 0.8 0.07 0.05]);
P3 = uicontrol('units','normal','style','edit','String',num2str(20),'position',[0.55 0.8 0.07 0.05]);
P4 = uicontrol('units','normal','style','edit','String',num2str([100 200 300]),'position',[0.7 0.8 0.12 0.05]);

%Text labels for Paramaters
T1 = uicontrol('units','normal','style','text','String','U(''Pr'')','fontsize',[10],'foregroundcolor','b','fontweight','bold','position',[0.25 0.87 0.07 0.04]);
T2 = uicontrol('units','normal','style','text','String','tFac','fontsize',[10],'foregroundcolor','g','fontweight','bold','position',[0.4 0.87 0.07 0.04]);
T3 = uicontrol('units','normal','style','text','String','tRec','fontsize',[10],'foregroundcolor','r','fontweight','bold','position',[0.55 0.87 0.07 0.04]);
T3 = uicontrol('units','normal','style','text','String','Spike Times','fontsize',[10],'foregroundcolor','k','fontweight','bold','position',[0.7 0.87 0.12 0.04]);

%LEGENDS
L1 = uicontrol('units','normal','style','text','String','F*D','fontsize',[14],'foregroundcolor','b','fontweight','bold','position',[0.25 0.7 0.07 0.04]);
L2 = uicontrol('units','normal','style','text','String','F','fontsize',[14],'foregroundcolor','g','fontweight','bold','position',[0.4 0.7 0.07 0.04]);
L3 = uicontrol('units','normal','style','text','String','D','fontsize',[14],'foregroundcolor','r','fontweight','bold','position',[0.55 0.7 0.07 0.04]);
