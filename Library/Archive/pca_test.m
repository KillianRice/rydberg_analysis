%% Initialize variables
analyVar = AnalysisVariables;
indivDataset = get_indiv_batch_data(analyVar);

basenamenumber = 1;
k = 1;
q = 1;
InitialCondition = ones(1,10)./10;
%optimOptions = optimset('Display','notify-detailed','PlotFcns',@optimplotx,'UseParallel','always');
optimOptions = optimset('UseParallel','always');
%% Using OD image - results were not as good as using the background images to make the pc basis
% % Trying to use OD image to eliminate high frequency noise
% OD_back = log(abs(indivDataset{k}.BackgroundNotCloud)) - log(abs(indivDataset{k}.AtomsNotCloud));
% 
% % Compute principal components from OD images
% [pcCoeffs, pcBasis, pcEigenVals] = princomp(OD_back);
% 
% % take the inital conditions of the nth image as the projection onto the pcBasis
% InitialCondition = pcCoeffs(k,:);
% 
% % Minimize the nth state in the original basis to the new pcBasis
% % (probably not needed since all states are used to determine pcBasis)
% tic; [A vals exitflag output grad hessian]  = fminunc(@(A) WeightedBackgroundFunction(A,...
%     OD_back(:,k)-mean(OD_back(:,k)),pcBasis),InitialCondition,optimOptions); toc
% % Coefficients define how to transform original basis into pcBasis
% % Need BackCloud in PCA basis to construct the nth image background in
% % terms of the PCA basis of the cloud background
% pcBGCloud = (pcCoeffs'*indivDataset{basenamenumber}.BackgroundCloud')';
% BackCloudApproxState = sum(bsxfun(@times,pcBGCloud,A),2);

%% Using background images to find orthogonal basis to approximate cloud background
% Compute principal components from background images
[pcCoeffs, pcBasis, pcEigenVals] = princomp(indivDataset{basenamenumber}.BackgroundNotCloud);
% take the inital conditions of the nth image as the projection onto the pcBasis
InitialCondition = pcCoeffs(k,:);

% Minimize the nth state in the original basis to the new pcBasis
% (probably not needed since all states are used to determine pcBasis)
tic; [A vals exitflag output]  = fminunc(@(A) WeightedBackgroundFunction(A,...
    indivDataset{basenamenumber}.AtomsNotCloud(:,k) - mean(indivDataset{basenamenumber}.AtomsNotCloud(:,k)),...
    pcBasis),InitialCondition,optimOptions); toc
% Coefficients define how to transform original basis into pcBasis
% Need BackCloud in PCA basis to construct the nth image background in
% terms of the PCA basis of the cloud background
pcBGCloud = (pcCoeffs'*indivDataset{basenamenumber}.BackgroundCloud')';
% Construct linear approximation of cloud background using PCA basis of not
% cloud backgrounds
BackCloudApproxState = sum(bsxfun(@times,pcBGCloud,A),2);

%% Print data
cumsum(pcEigenVals./sum(pcEigenVals))
output
output.message

%% Generate Cloud OD image and plot
roiImageAtom = reshape(indivDataset{basenamenumber}.AtomsCloud(:,k),[2*analyVar.cloudWindowRadius + 1,2*analyVar.cloudWindowRadius + 1])';
roiImageBack = reshape(BackCloudApproxState, size(roiImageAtom))';

OD_Image_Single = log(abs(roiImageBack)) - log(abs(roiImageAtom));
figure; hp = pcolor(OD_Image_Single); set(hp,'Edgecolor','none')