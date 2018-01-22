clear all
close all
clc

RAWDATA='C:\MATLAB\Detection\DATA\DATA_WIND_FULL';
% NEWDATA='C:\Users\shiha\Documents\MATLAB\Detection\DATA_WIND_FULL2';
% mkdir(NEWDATA);

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

    fname = [RAWDATA filesep Typesj{fid}]; 
    iname = [RAWDATA filesep Types{fid}]; 
%     iname_new=[NEWDATA filesep Types{fid}];   
    val =xml2struct(fname);
    
    NA=length(val.annotation.object);
%     bbox=[];
    bpoint=[];
    dt=0;

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
            
                    bpoint=[bpoint;min_row,min_col,max_row,max_col];
              
                     if NA<2
                     anno_name=val.annotation.object.name.Text;
                     else
                     anno_name=val.annotation.object{1,aid}.name.Text;
                     end

                    cellpos=find(strcmp(nameAt,anno_name)==1);
%                     cellposA=[cellposA;cellpos];
                                            box{idk,1}=iname;
                    box{idk,cellpos}=[box{idk,cellpos};double([min_col,min_row,max_col-min_col,max_row-min_row])];
                    dt=dt+1;
%             end
        end
        idk=idk+1;
end


TRAIN=cell2table(box);
TRAIN.Properties.VariableNames = nameA;

save TRAIN_full_olddata.mat TRAIN SC