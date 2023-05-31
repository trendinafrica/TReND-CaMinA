% BCM: simple implementation of BCM for unsupervised orientation selectivity

clear

rand('seed',56)				%%% 5617
numtrials = 500;					%%% 100
numLGNCells = 7;				%%% total = num x num
numCortexCells = 3;			%%%
numStim = 3;
alpha    = 0.025;          % 0.025 Learning Rate
wInh     = 0.15;           % 0.15 Lateral Inhibition
graphics = 1;
count=0;

lgn = zeros(numLGNCells,numLGNCells);
lgn_flag = zeros(numLGNCells,numLGNCells);
cortexV = zeros(1,numCortexCells);
cortexThr = 0.25*ones(1,numCortexCells); % = TOTALW for HEBB
cortexPlast = zeros(1,numCortexCells);
cortexSET = ones(1,numCortexCells)*0.35;
cortexAVG = zeros(1,numCortexCells);
cortexDEV = zeros(1,numCortexCells);

historyV = zeros(numStim,numtrials);

%%% WEIGHT MATRIX %%%   col #1=inputs to cortical unit #1
w = zeros(numCortexCells,numLGNCells,numLGNCells);
for i=1:numCortexCells
   w(i,1:numLGNCells,1:numLGNCells) = 0.05*rand(numLGNCells,numLGNCells);
end

%%% LGN %%%

INPUT = zeros(numStim,numLGNCells,numLGNCells);

INPUT(1,:,:) = [  0 0 0 0 0 0 0
   0 0 0 1 0 0 0
   0 0 0 1 0 0 0
   0 0 0 1 0 0 0
   0 0 0 1 0 0 0
   0 0 0 1 0 0 0
   0 0 0 0 0 0 0 ];

INPUT(2,:,:) = [
   0 0 0 0 0 0 0
   0 0 0 0 0 0 0
   0 0 0 0 0 0 0
   0 1 1 1 1 1 0
   0 0 0 0 0 0 0
   0 0 0 0 0 0 0
   0 0 0 0 0 0 0 ];

INPUT(3,:,:) = [
   0 0 0 0 0 0 0
   0 1 0 0 0 0 0
   0 0 1 0 0 0 0
   0 0 0 1 0 0 0
   0 0 0 0 1 0 0
   0 0 0 0 0 1 0
   0 0 0 0 0 0 0 ];





%%%%% GRAPHICS %%%%%
clf
set(gcf,'color',[0 0 0],'doublebuffer','on')
map = parula;
numcolors = length(map);
colormap(map)
splgn = subplot(4,4,13);
%set(gca,'position',[0.3300    0.56    0.3270    0.3439])
%set(splgn,'position',[0.1 0.2 0.8 0.2]);
%spcortex = subplot(2,2,3);
%set(spcortex,'position',[0.1 0.45 0.8 0.1]);
%sphistory = subplot(2,2,2);
spcolorbar = subplot(2,4,8)
set(spcolorbar,'position',[0.9388    0.45    0.03    0.22])
imagesc([64:-1:1]'); axis off;
for i=1:numCortexCells
   spw(i) = subplot(4,4,i+4);
end
for i=1:numCortexCells
   spn(i) = subplot(4,4,i);
end

subplot(spw(1)); set(gca,'position',[0.1    0.45    0.2    0.22])
subplot(spw(2)); set(gca,'position',[0.39    0.45    0.2    0.22])
subplot(spw(3)); set(gca,'position',[0.7    0.45    0.2    0.22])

subplot(spn(1)); set(gca,'position',[0.1    0.75    0.2    0.22])
subplot(spn(2)); set(gca,'position',[0.39    0.75    0.2    0.22])
subplot(spn(3)); set(gca,'position',[0.7    0.75    0.2    0.22])

subplot(splgn); set(gca,'position',[0.35    0.1    0.3    0.32])

subplot(splgn); set(gca,'units','pixels')
subplot(spw(1)); set(gca,'units','pixels')
subplot(spw(2)); set(gca,'units','pixels')
subplot(spw(3)); set(gca,'units','pixels')
subplot(spn(1)); set(gca,'units','pixels')
subplot(spn(2)); set(gca,'units','pixels')
subplot(spn(3)); set(gca,'units','pixels')
subplot(spcolorbar); set(gca,'units','pixels')

set(gcf,'position',[0 0 560*1.5 420*1.5])
%set(gcf,'position',[0 0 560*1 420*1.])

%shift = [220 200 0 0];
shift = [130 130 0 0];
subplot(spw(1)); set(gca,'position',[get(gca,'position')+shift])
subplot(spw(2)); set(gca,'position',[get(gca,'position')+shift])
subplot(spw(3)); set(gca,'position',[get(gca,'position')+shift])
subplot(spn(1)); set(gca,'position',[get(gca,'position')+shift]); axis off;
subplot(spn(2)); set(gca,'position',[get(gca,'position')+shift]); axis off
subplot(spn(3)); set(gca,'position',[get(gca,'position')+shift]); axis off

subplot(spcolorbar); set(gca,'position',[get(gca,'position')+shift])

%shift = [180 100 40 40];
shift = [110 40 40 40];

subplot(splgn); set(gca,'position',[get(gca,'position')+shift])

triangle = [0.25 0.5 0.75 0.25; 0 0.75 0 0];
subplot(spn(1)); patch(triangle(1,:),triangle(2,:),'b'); set(gca,'xlim',[0 1]); set(gca,'ylim',[0 1]);
subplot(spn(2)); patch(triangle(1,:),triangle(2,:),'b'); set(gca,'xlim',[0 1]); set(gca,'ylim',[0 1]);
subplot(spn(3)); patch(triangle(1,:),triangle(2,:),'b'); set(gca,'xlim',[0 1]); set(gca,'ylim',[0 1]);
%%% MAKE MOVIE %%%
%M = moviein(200);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n=1:numtrials
    n
   for stim=1:numStim

      %%% LGN %%%

      lgn = squeeze(INPUT(stim,:,:));

      %%% CORTEX %%%

      for i=1:numCortexCells
         cortexV(i) = sum(sum( lgn.*squeeze(w(i,:,:)) ));
         if (cortexV(i)>1) cortexV(i)=1; end;
      end
      for i=1:numCortexCells
         %FULL LATERAL INHIBITION%
         cortexV(i) = cortexV(i)-(sum(cortexV)-cortexV(i))*wInh;
      end

      cortexAVG = cortexAVG*0.8 + cortexV*0.2;
      %cortexAVG = cortexAVG*0.5 + cortexV*0.5;

      %%%%%%%%%%%%%%%%%%%%%%%%%% PLASTICITY %%%%%%%%%%%%%%%%%%%%%%%%%%%%
         cortexThr = (cortexAVG.^2)./cortexSET;
         cortexPlast = cortexV.*(cortexV-cortexThr); %performs a bit better than just (cortexV-cortexThr);
         for i=1:numCortexCells
      	   dW = alpha*lgn * cortexPlast(i);
      	   w(i,:,:)=dW + squeeze(w(i,:,:));
      	   w(i,find(squeeze(w(i,:,:))<0))= 0;
         end
      %%%%%%%%%%%%%%%%%%%%%%%%%% PLASTICITY %%%%%%%%%%%%%%%%%%%%%%%%%%%%





      %%% GRAPHICS %%%
      if (graphics ==1 &  ( rem(n+1,3)==0 | n==1 ))
         subplot(splgn)
         imagesc(lgn,[0 1])
         set(gca,'XTickLabel',[]); set(gca,'YTickLabel',[]);


         %subplot(spcortex)
         %imagesc(cortexV,[0 2])
         %set(gca,'XTickLabel',[]); set(gca,'YTickLabel',[]);
         %subplot(sphistory)
         %plot([historyV ; historyMOD ; historyGAIN; historyAVG]')
         %set(gca,'xlim',[0 numStim*numtrials])

         for i=1:numCortexCells
      	   subplot(spw(i));
      	   imagesc(squeeze(w(i,:,:)),[0 0.6])
            set(gca,'XTickLabel',[]); set(gca,'YTickLabel',[]);
            %colorbar
            color = ceil(cortexV(i)*(numcolors-1)+1);
            subplot(spn(i)); cla; patch(triangle(1,:),triangle(2,:),map(color,:) ); set(gca,'xlim',[0 1]); set(gca,'ylim',[0 1]);
         end

         drawnow;
         if (n==1 & stim==1) pause; end
         %M(:,n) = getframe;
         count=count+1;
         %filename = sprintf('%d%s',count,'.wmf');
         %eval(['print -dmeta ' filename]);
      end


   end	   			% end graphics


   historyV(:,n)=cortexV;

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end			
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end numtrials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% NOTES ON BCM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Real competition only starts late, because for a synapse to
%   decrease in strength, gain must be negative, for gain to be negative
%   modification threshold has to be above the voltage produced by the
%   nonprefered stimuli, since modif. threshold is direct function of
%   AVG, average must be pretty high meaning at least one stimulus is
%   producing a strong response.  Thus real competition only starts when
%   average is already close to SET.


