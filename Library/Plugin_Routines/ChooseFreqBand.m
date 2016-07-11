function [ featurePos2 ] = ChooseFreqBand(analyVar, unique_Freq, caseNum )
% choose band of frequency to look at, in units of UV MHz
QuantNumN = analyVar.PrincQN;

if caseNum(1) == 0
    featurePos2 = nan;
elseif caseNum(1) ~= 0
    switch QuantNumN
        case 38
            switch caseNum
                case 5
                     % Ground State Levels
                    featurePos{1} = [-9.90 -9.60]; % D0
                    featurePos{2} = [-19.72 -19.42]; % Tr00
                    featurePos{3} = [-29.41 -29.11]; % Te000  
            end
        case 49
            switch caseNum
                case 1
                     % Tight pack frequency
                    featurePos{1} = [1 0.5]; %
                    featurePos{2} = [0.5 0]; %
                    featurePos{3} = [0 -.5]; %
                    featurePos{4} = [-.5 -1]; % 
                    featurePos{5} = [-1 -1.5]; %                
                    featurePos{6} = [-1.5 -2]; %
                case 2
                    % wider tight pack frequency
                    featurePos{1} = [0.5 -0.5]; %
                    featurePos{2} = [-0.5 -1.5]; %
                    featurePos{3} = [-1.5 -2.5]; %
                    featurePos{4} = [-2.5 -3.5]; % 
                    featurePos{5} = [-3.5 -4.5]; %                
                    featurePos{6} = [-4.5 -5.5]; % 
                case 3
                    % wider tight spaced frequency
                    featurePos{1} = [0.5 -0.5]; %
                    featurePos{2} = [-2.5 -3.5]; %
                    featurePos{3} = [-5.5 -6.5]; %
                    featurePos{4} = [-8.5 -9.5]; % 
                    featurePos{5} = [-11.5 -12.5]; %                
                    featurePos{6} = [-14.5 -15.5]; %  
                case 4
                    % wider tight spaced frequency
                    featurePos{1} = [0.5 -0.5]; %
                    featurePos{2} = [-4.5 -5.5]; %
                    featurePos{3} = [-9.5 -10.5]; %
                    featurePos{4} = [-14.5 -15.5]; % 
                    featurePos{5} = [-19.5 -20.5]; %                
                    featurePos{6} = [-24.5 -25.5]; %                
                case 5
                     % Ground State Levels
                    featurePos{1} = [-2.01 -1.71]; % D0
                    featurePos{2} = [-3.89 -3.59]; % Tr00
                    featurePos{3} = [-5.74 -5.44]; % Te000 
                case 6 
                     % Ground State Levels
                    featurePos{1} = [0.15 -0.15]; % Atomic
                    featurePos{2} = [-2.01 -1.71]; % D0
                    featurePos{3} = [-3.89 -3.59]; % Tr00
                    featurePos{4} = [-5.74 -5.44]; % Te000                    
            end
        case 60
            switch caseNum
                case 1
                     % Tight pack frequency
                    featurePos{1} = [1 0.5]; %
                    featurePos{2} = [0.5 0]; %
                    featurePos{3} = [0 -.5]; %
                    featurePos{4} = [-.5 -1]; % 
                    featurePos{5} = [-1 -1.5]; %                
                    featurePos{6} = [-1.5 -2]; %             
                case 2
                    % wider tight pack frequency
                    featurePos{1} = [0.5 -0.5]; %
                    featurePos{2} = [-0.5 -1.5]; %
                    featurePos{3} = [-1.5 -2.5]; %
                    featurePos{4} = [-2.5 -3.5]; % 
                    featurePos{5} = [-3.5 -4.5]; %                
                    featurePos{6} = [-4.5 -5.5]; % 
                case 3
                    % wider tight spaced frequency
                    featurePos{1} = [0.5 -0.5]; %
                    featurePos{2} = [-2.5 -3.5]; %
                    featurePos{3} = [-5.5 -6.5]; %
                    featurePos{4} = [-8.5 -9.5]; % 
                    featurePos{5} = [-11.5 -12.5]; %                
                    featurePos{6} = [-14.5 -15.5]; %  
                case 4
                    % wider tight spaced frequency
                    featurePos{1} = [0.5 -0.5]; %
                    featurePos{2} = [-4.5 -5.5]; %
                    featurePos{3} = [-9.5 -10.5]; %
                    featurePos{4} = [-14.5 -15.5]; % 
                    featurePos{5} = [-19.5 -20.5]; %                
                    featurePos{6} = [-24.5 -25.5]; %    
                case 5
                     % Ground State Levels
                    featurePos{1} = [-0.66 -0.36]; % D0
                    featurePos{2} = [-1.17 -0.87]; % Tr00
                    featurePos{3} = [-1.68 -1.38]; % Te000    
                case 6 
                    width = 0.15;
                     % Ground State Levels
                    featurePos{1} = FreqWindow(0.5, width); % blue detuned 
                    featurePos{2} = FreqWindow(0, width); % Atomic
                    featurePos{3} = FreqWindow(-0.5, width); % D0
                    featurePos{4} = FreqWindow(-1.0, width); % Tr00
                    featurePos{5} = FreqWindow(-1.5, width); % Te000 
                    featurePos{6} = FreqWindow(-1.92, width); % 
%                     featurePos{7} = FreqWindow(-2.4, width); %
%                     featurePos{8} = FreqWindow(-2.88, width); %
%                     featurePos{9} = FreqWindow(-3.36, width); %
%                     featurePos{10} = FreqWindow(-3.84, width); %
%                     featurePos{11} = FreqWindow(-4.32, width); %
%                     featurePos{12} = FreqWindow(-4.80, width); %
%                     featurePos{13} = FreqWindow(-5.28, width); %
                case 7
                    width = 0.15;
                     % Bound ground state atoms, atomic, blue detuned
                    featurePos{1} = [+2.55-width +2.55+width]; % 0 bound ground state atoms 
                    featurePos{2} = [+0.00-width +0.00+width]; % 0 bound ground state atoms 
                    featurePos{3} = [-2.55-width -2.55+width]; % 5 bound ground state atoms
                    featurePos{4} = [-5.10-width -5.10+width] ; % 10 bound ground state atoms
                    featurePos{5} = [-7.65-width -7.65+width]; % 15 bound ground state atoms 
                    featurePos{6} = [-10.2-width -10.2+width]; % 20
                    featurePos{7} = [-10.2-width -10.2+width]-2.55; %25
                case 8
                     % Bound ground state atoms 
                     width = 0.15;
                    featurePos{1} = [+0.00-width +0.00+width]; % 0 bound ground state atoms                      
                    featurePos{2} = [-05.1-width -05.1+width]; % 10 
                    featurePos{3} = [-10.2-width -10.2+width]; % 20
                    featurePos{4} = [-15.3-width -15.3+width]; % 30
                    featurePos{5} = [-20.4-width -20.4+width+0.15]; % 40
                    featurePos{6} = [-25.5-width -25.5+width]; % 50                    
            end        
    end

    featurePos2 = cell(1, length(featurePos));
    for fIndex = 1:length(featurePos)
        featurePos2{fIndex}(1) = knnsearch(unique_Freq, featurePos{fIndex}(1));
        featurePos2{fIndex}(2) = knnsearch(unique_Freq, featurePos{fIndex}(end));
        featurePos2{fIndex}     = sort(featurePos2{fIndex});
    end

end

end

