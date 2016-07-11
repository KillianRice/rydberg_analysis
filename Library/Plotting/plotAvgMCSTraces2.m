function [ output_args ] = plotAvgMCSTraces2( analyVar, indivDataset )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

AvgSpectra = cell(1,indivDataset{1}.CounterAtom);
Max=0;
for mbIndex = 1:analyVar.numBasenamesAtom
    for bIndex = 1:indivDataset{mbIndex}.CounterAtom
        AvgSpectra{bIndex} = analyVar.AvgSpectra{bIndex};
%         AvgSpectra{bIndex}(analyVar.PeakBin,:,:) = 0;
        AvgSpectra{bIndex} = permute(AvgSpectra{bIndex},[2 1 3]);
        Max0 = max(AvgSpectra{bIndex}(:));
        Max  = max(Max,Max0);
    end
end

% Max = ceil(Max/100)*100;
order = Order_of_Magnitude(Max);
warning('check Order_of_Magnitude, Order_of_Magnitude2 fails for ~350')
order = order+1;
% Max = 10^order;

figure(analyVar.timevectorAtom(1)*10+2);

for bIndex = 1:indivDataset{1}.CounterAtom


    for DensityIndex = 1:indivDataset{1}.numDensityGroups{bIndex}
            subplot(...
                indivDataset{1}.numDensityGroups{1},...
                indivDataset{1}.CounterAtom,...
                bIndex+(DensityIndex-1)*indivDataset{1}.CounterAtom);                

            if analyVar.MCSTrace_x_var == 1
                [xticks, ~, xSpacing] = AxisTicksEngineeringForm(analyVar.ArrivalTime2);
                x_string = 'Arrival Time (us)';
            elseif analyVar.MCSTrace_x_var == 2
                [xticks, ~, xSpacing] = AxisTicksEngineeringForm(abs(analyVar.PushPullPotentialDiff2));
                x_string = 'Ionization Voltage (kV)';
            elseif analyVar.MCSTrace_x_var == 3
                [xticks, ~, xSpacing] = AxisTicksEngineeringForm(abs(analyVar.ElectricField2));
                x_string = 'Ionization Field (V/cm)';
            end
            xticks = xticks(1,:);
            xticks(2:end) = xticks(1:end-1);
%             xticks(1) = 0;

            [yticks, ~, ySpacing] = AxisTicksEngineeringForm(indivDataset{1}.timedelayOrderMatrix{bIndex});
            yticks = yticks-0.5*ySpacing;   
            zMatrix = AvgSpectra{bIndex}(:,:,DensityIndex);
            pcolor(xticks(2:end),yticks,zMatrix(:,2:end) );
            colormap pink
            axis square tight
            caxis([0 Max])
            ax = gca; % current axes
            set(ax,'FontSize',8);
            set(ax,'TickDir','out');
            set(ax,'TickLength', [0.02 0.02]);
            xlabel(x_string)
            ylabel('Field Delay (us)')
            title(...
                sprintf(...
                    '%s %s %s %s %s',...
                    'n0:',...
                    mat2str(DensityIndex),...
                    ', Synth:',...
                    mat2str(indivDataset{1}.synthFreq(bIndex)),...
                    'MHz'...
                )...
            )

    end
end
%     axes('Position', [0.07 0.05 0.9 0.9], 'Visible', 'off');
%     c=colorbar('FontSize',12);
%     ylabel(c,['Counts per ',mat2str(analyVar.numLoopsSets),' Loop Sets'])
    mtit(sprintf('%s %s %s %s','Date:', mat2str(analyVar.dataDirName),'Time:', mat2str(analyVar.timevectorAtom(1))))

%% single plot of raw data    
    
    FigHandle = figure;
    set(FigHandle, 'Position', [100, 100, 750, 750]);
        
    normalizationM = sum(AvgSpectra{2}(:,:,1),2);
    normalizationM = repmat(normalizationM,[1 size(AvgSpectra{2}(:,:,1),2)]);
    AvgSpectra{2}(:,:,1) = AvgSpectra{2}(:,:,1)./normalizationM;
    
    pcolor(xticks,yticks,AvgSpectra{2}(:,:,1))
    titleString = strcat({'Data Set '},mat2str(analyVar.timevectorAtom(1)));
    titleHan = title(titleString);
        set(titleHan,'Units', 'Normalized');
        set(titleHan,'Position', [.2 1.075])
        colormap pink
    ax = gca; % current axes
        set(ax,'FontSize',10);
        set(ax,'Units','normal');
        set(ax,'TickDir','out');
        set(ax,'TickLength',[.01 0.025]);
        set(ax,'xlim',[abs(xticks(1)) abs(xticks(end))])
        set(ax,'Position', [.1 .27 .75 .65]);
        xlabel(ax,x_string)
    ylabel('Field Delay (us)') 
    Colorbar = colorbar('Position', [.875 .27 .05 .65]);
    ylabel(Colorbar ,'Fractional Population')
    
    ax2=axes('units','normalized','position',[.1 .92 .75 0.000001],'xlim',[abs(xticks(1)) abs(xticks(end))],'color','none');
    set(ax2,'FontSize',10);
    set(ax2,'Xtick', abs(analyVar.ElectricField2(1,:)));
    saturationField = analyVar.Potential2Field*(analyVar.V_div_Push*analyVar.Push_Voltage-analyVar.V_div_Pull*analyVar.Pull_Voltage);
    ticknames2 = -10^6.*analyVar.PushVoltageRC.*log(...
        1-abs(xticks)/abs(saturationField)...
        ); % t = -tau*Log(1-F/F_Sat)
    ticknames2 = roundn(ticknames2,-1);
    ticknames2 = textscan(num2str(ticknames2),'%s');
    ticknames2 = ticknames2{1}';
    set(ax2,'XTickLabel',ticknames2)
    xlabel(ax2,'Ramp Time (us)')
    set(ax2,'xaxisLocation','top')
    set(ax2,'TickDir','out');

    ax3=axes('units','normalized','position',[.1 .06+2*0.06 .75 0.000001],'xlim',[abs(xticks(1)) abs(xticks(end))],'color','none');
    ticknums3 = [118 130 144 160  179  199  224  251  284  321 365];
    set(ax3,'Xtick', ticknums3);
    ticknames3 = {'44S','43S', '42S', '41S', '40S', '39S', '38S', '37S', '36S', '35S', '34S'};
    set(ax3,'XTickLabel',ticknames3)
    set(ax3,'FontSize',10);
    
    ax4=axes('units','normalized','position',[.1 .06+0.06 .75 0.000001],'xlim',[abs(xticks(1)) abs(xticks(end))],'color','none');
    ticknums4 = [112 124 137 152  169  189  211  237  267  302  343 391];
    set(ax4,'Xtick', ticknums4);
    ticknames4 = {'44P', '43P', '42P', '41P', '40P', '39P', '38P', '37P', '36P', '35P', '34P' '33P'};
    set(ax4,'XTickLabel',ticknames4)
    set(ax4,'FontSize',10);
    
    ax5=axes('units','normalized','position',[.1 .060 .7 0.000001],'xlim',[abs(xticks(1)) abs(xticks(end))],'color','none');
    ticknums5 = [109 121 133 148 164 183 204 229 258 291 329 374];
    set(ax5,'Xtick', ticknums5);
    ticknames5 = {'44D', '43D', '42D', '41D', '40D', '39D', '38D', '37D', '36D', '35D', '34D', '33D'};
    set(ax5,'XTickLabel',ticknames5)
    set(ax5,'FontSize',10);
    xlabel(ax5,'State')

%% signal vs field
    FigHandle2 = figure;
    set(FigHandle2, 'Color', [.5,.5,.5]);
    set(FigHandle2, 'Position', [100, 100, 750, 750]);
%     normalizationM = sum(AvgSpectra{2}(:,:,1),2);
%     normalizationM = repmat(normalizationM,[1 size(AvgSpectra{2}(:,:,1),2)]);
%     AvgSpectra2 = AvgSpectra{2}(:,:,1)./normalizationM;
    
%     AvgSpectra2 = permute(analyVar.AvgSpectra{2},[2 1 3]);
    AvgSpectra2 = AvgSpectra{2}(:,:,1);
    hold on
    AvgSpectra2Color = flipud(pink(size(AvgSpectra2,1)+3));
    AvgSpectra2Color = AvgSpectra2Color(4:end,:);
    for index = 1:size(AvgSpectra2,1)
        plothan = plot(xticks,AvgSpectra2(index,:),...
            analyVar.MARKERS{index},...
            'MarkerSize',analyVar.markerSize/4,...
            'color',AvgSpectra2Color(index,:));

    end
    hold off
    
    
    titleString = strcat({'Data Set '},mat2str(analyVar.timevectorAtom(1)));
    titleHan = title(titleString);
        set(titleHan,'Units', 'Normalized');
        set(titleHan,'Position', [.2 1.075])
%         colormap pink
    ax = gca; % current axes
        set(ax,'Color',[.5,.5,.5]);
        set(ax,'FontSize',10);
        set(ax,'Units','normal');
        set(ax,'TickDir','out');
        set(ax,'TickLength',[.01 0.025]);
        set(ax,'xlim',[abs(xticks(1)) abs(xticks(end))])
        set(ax,'Position', [.1 .27 .75 .65]);
    xlabel(ax,x_string)
    legendstr = textscan(num2str(indivDataset{1}.timedelayOrderMatrix{1}./1e-6),'%s');
    legendstr = legendstr{1}';
    legHandle = legend(legendstr);
    set(get(legHandle,'title'),'string','Field Delay (us)')
    ylabel('Population Normalized at each Field Delay') 
%     Colorbar = colorbar('Position', [.875 .27 .05 .65]);
%     ylabel(Colorbar ,'Fractional Population')

%% signal vs delay time
    figure();
%     FigHandle3 = gca;
%     set(FigHandle3, 'Color', [.5,.5,.5]);
%     set(FigHandle3, 'Position', [100, 100, 750, 750]);
%     normalizationM = sum(AvgSpectra{2}(:,:,1),2);
%     normalizationM = repmat(normalizationM,[1 size(AvgSpectra{2}(:,:,1),2)]);
%     AvgSpectra = AvgSpectra{2}(:,:,1)./normalizationM;
%     AvgSpectra = AvgSpectra{2}(:,:,1)./normalizationM;
    AvgSpectra = permute(analyVar.AvgSpectra{2},[2 1 3]);
    AvgSpectra = AvgSpectra(:,:,1);
    hold on
%     AvgSpectra3Color = pink(size(AvgSpectra,2)+3);
%     AvgSpectra3Color = AvgSpectra3Color(4:end,:);
    LowFieldAvgSpectra  = AvgSpectra(:,1:analyVar.PeakBin-1);
    HighFieldAvgSpectra = AvgSpectra(:,analyVar.PeakBin+1:end);
    PeakFieldAvgSpectra = AvgSpectra(:,analyVar.PeakBin);
    for index = 1:size(LowFieldAvgSpectra,2)
        plot(yticks',LowFieldAvgSpectra(:,index),...
            '-o',...
            'MarkerSize',analyVar.markerSize/4,...
            'color',[1,0,0]);
    end

    plot(yticks',PeakFieldAvgSpectra,...
        '-o',...
        'MarkerSize',analyVar.markerSize/4,...
        'color',[0,0,0]);
    
    for index = 1:size(HighFieldAvgSpectra,2)
        plot(yticks',HighFieldAvgSpectra(:,index),...
            '-o',...
            'MarkerSize',analyVar.markerSize/4,...
            'color',[0,0,1]);
    end
        
    hold off
    
    
%     titleString = strcat({'Data Set '},mat2str(analyVar.timevectorAtom(1)));
%     titleHan = title(titleString);
%         set(titleHan,'Units', 'Normalized');
%         set(titleHan,'Position', [.2 1.075])
%     ax = gca; % current axes
%         set(ax,'Color',[.5,.5,.5]);
%         set(ax,'FontSize',10);
%         set(ax,'Units','normal');
%         set(ax,'TickDir','out');
%         set(ax,'TickLength',[.01 0.025]);
%         set(ax,'xlim',[abs(xticks(1)) abs(xticks(end))])
%         set(ax,'Position', [.1 .27 .75 .65]);
%     xlabel(ax,x_string)
%     legendstr = textscan(num2str(indivDataset{1}.timedelayOrderMatrix{1}./1e-6),'%s');
%     legendstr = legendstr{1}';
%     legHandle = legend(legendstr);
%     set(get(legHandle,'title'),'string','Field Delay (us)')
%     ylabel('Field Delay (us)') 
%     Colorbar = colorbar('Position', [.875 .27 .05 .65]);
%     ylabel(Colorbar ,'Fractional Population')
%% signal vs delay time for low field only
    figure();

    AvgSpectra = permute(analyVar.AvgSpectra{2},[2 1 3]);

    hold on

%     LowFieldAvgSpectra  = AvgSpectra(:,1:analyVar.PeakBin-1,:);
%     LowFieldAvgSpectra  = sum(LowFieldAvgSpectra,2);
    
    LowFieldAvgSpectra  = AvgSpectra(:,analyVar.PeakBin-1,:);

    LowFieldAvgSpectra  = permute(LowFieldAvgSpectra, [1 3 2]);
    for index = 1:size(LowFieldAvgSpectra,2)
        plot(yticks',LowFieldAvgSpectra(:,index),...
            '-o',...
            'MarkerSize',analyVar.markerSize/4,...
            'color',[1,0,0]);
    end

       
    hold off
    
    %% traces    
% figure()
%     % stackedplot(fliplr(analyVar.NonPeak_AvgSpectra{3}(:,:,1)),1,4,3);
%     stackedplot(analyVar.NonPeak_AvgSpectra{3}(:,:,1),1,4,3);
%     grid on
end

