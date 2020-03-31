function bloch = findLatHam(qReduced,latDepth,numPlaneWaves,varargin)
% Constructs the ideal lattice Hamiltonian (flat lattice with no external
% confinement)
% INPUTS:
%   qReduced      - quasimomentum in units of k = 2pi\lambda
%   latDepth      - Potential depth of the lattice sites
%   numPlaneWaves - number of plane waves to decompose the lattice into
%   varargin      - special arguments that create plots
%                   As of 02.27.2014 valid inputs are
%                     comps  - shows contributions of each plane wave to the
%                              first 4 energy bands
%                     bands  - Draw the energy bands (dispersion relation) 
%                     proAmp - Project the first few plane waves onto
%                              specified energy bands. 
%                              (Sign errors may occur)
%
% OUTPUTS:
%   bloch - Structure containing the following fields (Remember q is set by
%           the input to findLatHam)
%             latHam - Numerical hamiltonian from inputs
%             EigVec - Eigenvectors of the Hamiltonian
%             EigVal - Eigenvalues of the Hamiltonian
%             C_nl   - Coefficients of plane wave state (l) projected onto
%                      the nth energy band (<p=2*l*hk | n, q>)
%             BandEn - Energy of the nth band

%Save inputs into output structure
bloch.qReduced = qReduced;
bloch.latDepth = latDepth;
bloch.numPlaneWaves = numPlaneWaves;

% Number of bands on either side of diagonal to fill
band_width = 1;
% Creates hamiltonian matrix with bands filled by latDepth/4
latHam  = spdiags(ones(2*numPlaneWaves+1,2*band_width+1)*latDepth/4,[-band_width band_width],2*numPlaneWaves+1,2*numPlaneWaves+1);
% Place (2j+qReduced)^2+latDepth/2 along diagonal
latDiag = (2.*(-numPlaneWaves:numPlaneWaves)'+ qReduced).^2 + latDepth/2;
bloch.latHam  = full(spdiags(latDiag,0,latHam));
% Matrix converted to full so that we can access all the eigenvectors

% Find eigenvectors and eigenvalues of the hamiltonian. This provides the
% projections of Bloch wave states onto the plane wave basis.
[bloch.EigVec bloch.EigVal] = eig(bloch.latHam);

% Save function handle for accessing the state coefficients by n,l (q
% determined by input) <p=2*l*hk | n, q>
bloch.C_nl = @(n,l) bloch.EigVec((numPlaneWaves+1)+l,n+1);

% Save function handle for accessing the energy of each band at this q
bloch.BandEn = @(n) nonzeros(bloch.EigVal(n+1,:));


%% Additional information available is asked for
% Use the property name below in the varargin argument to access these
% parts


% Visualize the contributions of each plane wave to
% the first 4 energy bands (bloch states)
if sum(strcmpi('comps',varargin))
    for i = 0:2;
        subplot(1,3,i+1);
        plnContr = -numPlaneWaves:numPlaneWaves;
        bar(2*plnContr,bloch.C_nl(i,plnContr).^2);
        %xlim([plnContr(1)-1 plnContr(end)+1]); 
        ylim([0 1]);
        xlim([-6 6])
        title(sprintf('Band %g',i),'FontSize',30,'FontWeight','Bold')
        set(gca,'FontSize',24,'FontWeight','bold' ); grid on
    end
end

% This can be used to draw the energy bands
if sum(strcmpi('bands',varargin))
    qm = -2:.002:2; % Need to evaluate the hamiltonian across quasimomentum
    maxBand = 2;
    bandEn = zeros(maxBand+1,length(qm));
    for i = 1:length(qm)
        bandEnBloch = findLatHam(qm(i),latDepth,numPlaneWaves);
        bandEn(:,i) = bandEnBloch.BandEn(0:maxBand);
    end
    %figure; 
    hold on;
    dataH = plot(qm,bandEn');
    defyLim = ylim; 
    lineH = line([-1 1; -1 1],[0 0; 100 100]); 
    ylim(defyLim);
    set(dataH,'LineWidth',2)
    set(lineH,'LineWidth',2,'LineStyle','--','Color','k')
    title(sprintf('Band Structure for %g E_r lattice',latDepth),'FontSize',20);
    set(gca,'FontSize',20,'FontWeight','Bold'); grid on;
    xlabel('\boldmath{\textbf{Quasimomentum [$\hbar k$]}}','Interpreter','latex','FontSize',25)
    ylabel('\boldmath{\textbf{Energy [$E_r$]}}','Interpreter','latex','FontSize',25)
end

% This can be used to plot the amplitude of the projection of the first few
% plane wave onto certain energy bands
% Not complete
if sum(strcmpi('projAmp',varargin))
    latDepthIter = 0:.5:20; % Need to evaluate the hamiltonian across lattice depths
    plotBands = [0 2 4];
    plotPlns  = [0];
    ampVec = zeros(length(plotPlns),length(plotBands),length(latDepthIter));
    for i = 1:length(latDepthIter)
        ampVecBloch   = findLatHam(qReduced,latDepthIter(i),numPlaneWaves);
        ampVec(:,:,i) = ampVecBloch.C_nl(plotBands,plotPlns).^2;
    end
    % Be careful using this as the abs enforces positvity which is not always true. Matlab does not maintain the
    % sign when finding the eigenvectors. Check solutions here with mathematica.
    figure; hold on
    set(gca,'FontSize',20,'FontWeight','Bold'); grid on;
    xlabel('\boldmath{\textbf{Lattice Depth [$E_r$]}}','Interpreter','latex','FontSize',25)
    ylabel('\boldmath{\textbf{Probability}}','Interpreter','latex','FontSize',25)
    cLine = {'b','k','r'};
    for j = 1:length(plotPlns)
        for i = 1:length(plotBands)
            tmp = zeros(size(latDepthIter));
            tmp(:) = abs(ampVec(j,i,:));
            plot(latDepthIter,tmp,'LineWidth',4,'Color',cLine{i})
        end
    end
end

