clear all
close all
clc

%% make test
doTrainingAndEval = 1;

load TRAIN_full_olddata.mat TRAIN
TEST=TRAIN;
% Load vehicle data set
load TRAIN_part_olddata.mat TRAIN SC
WINDdataset = TRAIN;

nid=13;
I = imread(WINDdataset.imageFilename{nid});
bpoint=WINDdataset.VG_panel{nid};
I = insertShape(I, 'Rectangle', bpoint,'LineWidth',uint8(5*SC));

figure
imshow(I)

trainingData = WINDdataset;
testData = TEST;

%% network
net=alexnet;
Epoch=200;
%%

%% detector [rcnn = 1 ; fastrcnn = 2; fasterrcnn = 3 ]
dectype =1;
decA={'RCNN','FRCNN','FTRCNN'};
%%

%% Result dir
RESULT=['C:\MATLAB\Detection\RESULT\OLD_' 'detector_' decA{dectype} '_epoch' num2str(Epoch)];



layersTransfer = net.Layers(1:end-3);
numClasses = size(WINDdataset,2);
layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ...
  'MiniBatchSize', 64, ...
  'InitialLearnRate', 1e-6, ...
  'MaxEpochs', Epoch);

if doTrainingAndEval
    % Set random seed to ensure example training reproducibility.
    rng(0);

    % Train Faster R-CNN detector. Select a BoxPyramidScale of 1.2 to allow
    % for finer resolution for multiscale object detection.
    
    if dectype==1
    
    detector = trainRCNNObjectDetector(trainingData, layers, options, ...
        'NegativeOverlapRange', [0 0.5],...
        'PositiveOverlapRange', [0.6 1]);
    
    elseif dectype==2
        
          detector = trainFastRCNNObjectDetector(trainingData, layers, options, ...
        'NegativeOverlapRange', [0 0.5],...
        'PositiveOverlapRange', [0.6 1]);
    
    elseif dectype==3
        
          detector = trainFasterRCNNObjectDetector(trainingData, layers, options, ...
        'NegativeOverlapRange', [0 0.5],...
        'PositiveOverlapRange', [0.6 1]);
    
    end
else
    % Load pretrained detector for the example.
    load([RESULT filesep 'detector_' decA{dectype} '_epoch' num2str(Epoch) '.mat'],'detector');
end

mkdir(RESULT);
save([RESULT filesep 'detector_' decA{dectype} '_epoch' num2str(Epoch) '.mat'],'detector');

flag=[];
LIST=1:height(testData);

    % Run detector on each image in the test set and collect results.
    resultsStruct = [];
    for i = LIST

        % Read the image.
        I = imread(testData.imageFilename{i});
        [filepath,name,ext] = fileparts(testData.imageFilename{i});
%         I = insertShape(I, 'Rectangle', bpoint,'LineWidth',uint8(25*SC));
        % Run the detector.
        if dectype==1
        [bboxes, scores, labels] = detect_by_part(detector, I,0);
        elseif dectype==2
        [bboxes, scores, labels] = detect_by_part(detector, I,0);
        elseif dectype==3
        [bboxes, scores, labels] = detect_by_part(detector, I,0);
        end
        
%         MS=max(scores);

%         ns=find(scores < 0.5 |  scores <(MS*0.85));
%         ns=find(scores < 0.75);
%         bboxes(ns,:)=[];
%         labels(ns,:)=[];
%         scores(ns,:)=[];

            I = insertShape(I, 'Rectangle', testData.Lightning_receptor{i},'Color',255*[.8 .5 .5],'LineWidth',16);
            I = insertShape(I, 'Rectangle', testData.VG_panel{i},'Color',255*[.5 .8 .5],'LineWidth',16);
            I = insertShape(I, 'Rectangle', testData.VG_with_missing_tooth{i},'Color',255*[.5 .5 .5],'LineWidth',16);
            I = insertShape(I, 'Rectangle', testData.Erosion{i},'Color',255*[.5 .5 .8],'LineWidth',16);
        
                I2=I;
                if size(bboxes,1)>0
                    annotation=[];
                    for idxn=1:size(bboxes,1)
                    annotation = sprintf('%s: %f', labels(idxn), scores(idxn));
                        if labels(idxn)=='Lightning_receptor'
                        I2 = insertObjectAnnotation(I2, 'Rectangle', bboxes(idxn,:),annotation,'LineWidth',12,'Color','red','TextColor','white','FontSize',60);
                        elseif labels(idxn)=='VG_panel'
                        I2 = insertObjectAnnotation(I2, 'Rectangle', bboxes(idxn,:),annotation,'LineWidth',12,'Color','green','TextColor','white','FontSize',60);
                        elseif labels(idxn)=='VG_with_missing_tooth'
                        I2 = insertObjectAnnotation(I2, 'Rectangle', bboxes(idxn,:),annotation,'LineWidth',12,'Color','black','TextColor','white','FontSize',60);
                        elseif labels(idxn)=='Erosion'
                        I2 = insertObjectAnnotation(I2, 'Rectangle', bboxes(idxn,:),annotation,'LineWidth',12,'Color','blue','TextColor','white','FontSize',60);
                        end
                    end

                
                imwrite(I2,[RESULT filesep name ext]);
                flag(i)=1;
                else
                imwrite(I,[RESULT filesep name ext]); 
                flag(i)=0;
                end
                % Collect the results.
                
                classNames = detector.ClassNames;
                
                post=[];
                
                for kin=1:size(labels,1)
                    post(kin,1)=find(labels(kin)==classNames(1:4)) ;                   
                end
                
%         [scoret,post]=max(all_scores2,[],2);
        
        for sn=1:size(classNames,1)-1
        resultsStruct{i,sn,1} = bboxes(post==sn,:);
        resultsStruct{i,sn,2} = scores(post==sn,:);
%         resultsStruct{i,sn,3} = labels(post==sn,:);
        flag(i,sn)=sum(post==sn)>0;
        end
        i
    end


for cls=[1 2 3 4]
    expectedResults = testData(LIST(1:size(resultsStruct,1)), cls+1);
    cresultsStruct=struct([]);
    for L=1:size(resultsStruct,1)
        cresultsStruct(L).Boxes = resultsStruct{L,cls,1};
        cresultsStruct(L).Scores = resultsStruct{L,cls,2};
%         cresultsStruct(L).Labels = resultsStruct{L,cls,3};
    end
    cresults = struct2table(cresultsStruct);
%     expectedResults(flag(:,cls)==0,:)=[];
%     cresults(flag(:,cls)==0,:)=[];
    [ap(cls), recall, precision] = evaluateDetectionPrecision(cresults, expectedResults,.5);
    ap
end
mean(ap)