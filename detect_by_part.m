function [bboxes, scores, labels] = detect_by_part(detector, I,dotest)

IMG=I;
bboxes=[];
scores=[];
labels=[];

         size1=size(IMG,1);
            size2=size(IMG,2);

            size1lim=800;
            size2lim=800;

            spatchd=80;

            shift1=size1lim-spatchd;
            shift2=size2lim-spatchd;

            cut1=ceil((size1-spatchd)/shift1);
            cut2=ceil((size2-spatchd)/shift2);

            part=1;

            disp('cutting the image ..');
        
        
       for cutid1=1:cut1
           for cutid2=1:cut2

                psb1=min([(cutid1-1)*shift1+size1lim size(IMG,1)]); 
                psb2=min([(cutid2-1)*shift2+size2lim size(IMG,2)]); 

                range1=(cutid1-1)*shift1+1:psb1; 
                range2=(cutid2-1)*shift1+1:psb2;
                
             
                
                if cutid1==cut1
                    if size(IMG,1)>size1lim
%                     lim1=min([length(range1) size(IMG,1)]);
                    range1=[size(IMG,1)-size1lim+1:size(IMG,1)];
                    end
                end
                
                if cutid2==cut2
                    if size(IMG,2)>size2lim
%                     lim2=min([length(range2) size(IMG,2)]);
                    range2=[size(IMG,2)-size2lim+1:size(IMG,2)];
                    end
                end
                
%                 if length(range1)<=size(IMG,1) && length(range2)<=size(IMG,2)
                IMGC=IMG(range1,range2,:);
%                 else
%                 IMGC=IMG;   
%                 end

                [bboxest, scorest, labelst] = detect(detector, IMGC);
                
                
                
                
                
                if size(bboxest,1>0)
                    
                    if dotest>0
                        bboxest(bboxest(:,1)<1,1)=1;
                        bboxest(bboxest(:,2)<1,2)=1;
                        td=(bboxest(:,1)+bboxest(:,3))>size(IMGC,2);
                        bboxest(td,3)=bboxest(td,3)-((bboxest(td,1)+bboxest(td,3))-size(IMGC,2));
                        fd=(bboxest(:,2)+bboxest(:,4))>size(IMGC,1);
                        bboxest(fd,4)=bboxest(fd,4)-((bboxest(fd,2)+bboxest(fd,4))-size(IMGC,1));

                        [labelst, scorest, all_scores2] = classifyRegions(detector, IMGC, bboxest);
                        [~,pos]=max(all_scores2,[],2);
%                         MS=max(scores);

                        ns=find(pos==5);
                        bboxest(ns,:)=[];
                        labelst(ns,:)=[];
                        scorest(ns,:)=[];
%                         all_scores2(ns,:)=[];    
                    
                    end
                    
                    if size(bboxest,1>0)    

                    bboxest(:,1)=bboxest(:,1)+range2(1)-1;
                    bboxest(:,2)=bboxest(:,2)+range1(1)-1;
                    end
                end
                
                bboxes=[bboxes;bboxest];
                scores=[scores;scorest];
                labels=[labels;labelst];
                
                
           end
       end
       
        [bboxes, scores, index] = selectStrongestBbox(bboxes, scores, ...
                    'RatioType', 'Min', 'OverlapThreshold', 0.5);
                
                labels = labels(index,:);
                
                