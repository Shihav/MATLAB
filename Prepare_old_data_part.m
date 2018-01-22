clear all
close all
clc

% addpath('C:\Users\shiha\Documents\MATLAB\SelectiveSearchCodeIJCV\')
% addpath('C:\Users\shiha\Documents\MATLAB\SelectiveSearchCodeIJCV\Dependencies\')

RAWDATA='C:\MATLAB\Detection\DATA\DATA_WIND_FULL';
NEWDATA='C:\MATLAB\Detection\DATA\DATA_WIND_PATCH';
mkdir(NEWDATA);

mkfig=1;
mkdata=1;

%nameA={'imageFilename','LightningDamage','PaintDamage','Errosion','CracksAlongLine','BladeWallCracks','MissingVortex','Breaks','Joints'};
nameAt={'imageFilename','Lightning receptor','VG panel','VG_with_missing_tooth','Erosion'};
nameA={'imageFilename','Lightning_receptor','VG_panel','VG_with_missing_tooth','Erosion'};
box=cell(0,5);
idk=1;
SC=1;
       
d=dir(fullfile(RAWDATA,'*.jpg*'));
Types={d.name};

dj=dir(fullfile(RAWDATA,'*.xml*'));
Typesj={dj.name};

for fid=1:numel(Types)
    fid
    fname = [RAWDATA filesep Typesj{fid}]; 
    iname = [RAWDATA filesep Types{fid}]; 
    iname_new=[NEWDATA filesep Types{fid}];   
    val =xml2struct(fname);
    IMG=imread(iname);
        
    if (str2double(val.annotation.size.height.Text)*SC)>300 && (str2double(val.annotation.size.width.Text)*SC)>300  
        
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
        
        
        
        
        
            NA=length(val.annotation.object);
        %     bbox=[];
            bpoint=[];
            dt=0;
        %     cellposA=[];
                for aid=1:NA

                    if NA<2
                        min_col=uint16(SC*str2double(val.annotation.object.bndbox.xmin.Text))+1;
                        max_col=uint16(SC*str2double(val.annotation.object.bndbox.xmax.Text))-1;
                        min_row=uint16(SC*str2double(val.annotation.object.bndbox.ymin.Text))+1;
                        max_row=uint16(SC*str2double(val.annotation.object.bndbox.ymax.Text))-1;
                    else
                        min_col=uint16(SC*str2double(val.annotation.object{1,aid}.bndbox.xmin.Text))+1;
                        max_col=uint16(SC*str2double(val.annotation.object{1,aid}.bndbox.xmax.Text))-1;
                        min_row=uint16(SC*str2double(val.annotation.object{1,aid}.bndbox.ymin.Text))+1;
                        max_row=uint16(SC*str2double(val.annotation.object{1,aid}.bndbox.ymax.Text))-1;
                    end
                    
                        if min_row<1
                            min_row=1;
                        end

                        if min_col<1
                            min_col=1;
                        end

                        if max_col>floor(str2double(val.annotation.size.width.Text)*SC)
                            max_col=floor(str2double(val.annotation.size.width.Text)*SC);
                        end

                        if max_row>floor(str2double(val.annotation.size.height.Text)*SC)
                            min_row=floor(str2double(val.annotation.size.height.Text)*SC);
                        end


                    if min_row>1 && min_col>1 && max_row<(str2double(val.annotation.size.height.Text)*SC) && max_col<(str2double(val.annotation.size.width.Text)*SC)% && (max_row-min_row)>(50*SC) && (max_col-min_col)>(50*SC)
        %               bbox= [bbox;min_row,min_col,max_row-min_row,max_col-min_col];  
        
                            min_col=min_col-range2(1)+1;
                            min_row=min_row-range1(1)+1;
                            max_col=max_col-range2(1)+1;
                            max_row=max_row-range1(1)+1;
                            box{idk,1}=[iname_new(1:end-4) '_' num2str(part) '.jpg'];
                            if min_row>1 && min_col>1 && max_row<size1lim && max_col<size1lim
        
        
                            bpoint=[bpoint;min_row,min_col,max_row,max_col];

                             if NA<2
                             anno_name=val.annotation.object.name.Text;
                             else
                             anno_name=val.annotation.object{1,aid}.name.Text;
                             end

                            cellpos=find(strcmp(nameAt,anno_name)==1);
        %                     cellposA=[cellposA;cellpos];
                                                    
                            box{idk,cellpos}=[box{idk,cellpos};double([min_col,min_row,max_col-min_col,max_row-min_row])];
                            dt=dt+1;
                            end
                    end
                end
%                 if dt>0
                idk=idk+1;
                imwrite(imresize(IMGC,SC),[iname_new(1:end-4) '_' num2str(part) '.jpg']);
                part=part+1;
                
           end                     
       end
   end
end


TRAIN=cell2table(box);
TRAIN.Properties.VariableNames = nameA;

save TRAIN_part_olddata.mat TRAIN SC