        y1=get(gca,'ylim');
        for LState = 1:3
            for nLevel = 1:length(tickNums{LState})
            x1 = tickNums{LState}(nLevel); 
            switch LState
                case 1
                    ColorChoice = [0,.25,0];
                case 2
                    ColorChoice = [0,.5,0];
                case 3
                    ColorChoice = [0,.75,0];
            end
            plot([x1 x1],y1,'-', 'Color', ColorChoice)
            end
        end