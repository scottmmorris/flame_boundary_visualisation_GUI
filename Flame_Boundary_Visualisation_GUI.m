%% Declare global variables for callbacks
clear;
clc;
global CrankAngle ImadjustRange MorpSize DataDirectory ImageBag ContRangeC...
    ThreshC MorpC Cycles FiringCycle InjPressure f R_Thres Center CaseMeanR StartFrame CA;

%% Set up the Image Data Access

DataDirectory =...
    'D:\scott\Documents\University\Research Thesis\InjectionPressureVariation_202106\ProcessedMovie\50bar\f1_240_210_tSpk_6_S0001\f1_240_210_tSpk_6_S00010000';

ImageBag =  10;
CrankAngle = -9.6 + ImageBag * 0.36;

%% Define the fixed parameters

ImgRes=768;        
Center=[383 368];
R_Thres=[713-368];
CA = linspace(-9.24,170.76,501);
StartFrame = 9;

Mask=ones(ImgRes,ImgRes);
for i_x=1:ImgRes
    for i_y=1:ImgRes
        Dist=sqrt((i_x-Center(1)).^2+(i_y-Center(2)).^2);
        if Dist > R_Thres + 10
            Mask(i_y,i_x)=0; 
        end
    end
end

%% Define the default variable parameters

ImadjustRange=[0.01 0.1];
MorpSize=10;
ContRangeC=0;
ThreshC=0;
MorpC=0;
FiringCycle=1;
InjPressure=50;
Cycles=1;

%% Setup the visualisation GUI

f = figure;
visualiseImage();

morpSizeControl = uicontrol('Parent',f,'Style','edit','Position',[70,5,30,20],...
              'value',MorpSize);
morpSizeControl.Callback = @(ui,~) processUIEdit(ui.String,-1,-1);

uppAdjControl = uicontrol('Parent',f,'Style','edit','Position',[170,5,30,20],...
              'value',ImadjustRange(2));
uppAdjControl.Callback = @(ui,~) processUIEdit(-1,ui.String,-1); 

lowAdjControl = uicontrol('Parent',f,'Style','edit','Position',[270,5,30,20],...
              'value',ImadjustRange(1));
lowAdjControl.Callback = @(ui,~) processUIEdit(-1,-1,ui.String);

contrastRangeControl = uicontrol('Parent',f,'Style','checkbox','Position',[355,10,15,15],...
              'value',ContRangeC);
contrastRangeControlText = uicontrol('Parent',f,'Style','text','Position',[300,0,55,30],...
                'String',"Contrast Range ",'BackgroundColor',f.Color);
contrastRangeControl.Callback = @(ui,~) processUICheckbox(ui.Value,-1,-1);

thresholdControl = uicontrol('Parent',f,'Style','checkbox','Position',[425,10,15,15],...
              'value',ThreshC);
thresholdControlText = uicontrol('Parent',f,'Style','text','Position',[370,0,55,30],...
                'String','Threshold:','BackgroundColor',f.Color);
thresholdControl.Callback = @(ui,~) processUICheckbox(-1,ui.Value,-1);

morpControl = uicontrol('Parent',f,'Style','checkbox','Position',[495,10,15,15],...
              'value',MorpC);
morpControlText = uicontrol('Parent',f,'Style','text','Position',[440,0,55,30],...
                'String','Morphology:','BackgroundColor',f.Color);
morpControl.Callback = @(ui,~) processUICheckbox(-1,-1,ui.Value);

cycleForwControl = uicontrol('Parent',f,'Style','pushbutton','String','Next Cycle','Position',[610,5,70,20]);
cycleForwControl.Callback = @(ui,~) processUICycleChange(1, 0);

cycleBackControl = uicontrol('Parent',f,'Style','pushbutton','String','Prev Cycle','Position',[610,25,70,20]);
cycleBackControl.Callback = @(~,~) processUICycleChange(-1, 0);

frameForwControl = uicontrol('Parent',f,'Style','pushbutton','String','Next CA','Position',[685,5,70,20]);
frameForwControl.Callback = @(~,~) processUIFrameChange(1);

frameBackControl = uicontrol('Parent',f,'Style','pushbutton','String','Prev CA','Position',[685,25,70,20]);
frameBackControl.Callback = @(~,~) processUIFrameChange(-1);

firingCycleForwControl = uicontrol('Parent',f,'Style','pushbutton','String','Next FCycle','Position',[760,5,70,20]);
firingCycleForwControl.Callback = @(ui,~) processUICycleChange(0, 1);

firingCycleBackControl = uicontrol('Parent',f,'Style','pushbutton','String','Prev FCycle','Position',[760,25,70,20]);
firingCycleBackControl.Callback = @(~,~) processUICycleChange(0, -1);

injPressureControl = uicontrol('Parent',f,'Style','edit','Position',[575,5,30,20],...
              'value',InjPressure);
injPressureControl.Callback = @(ui,~) processUIInjPressure(ui.String);

flameGrowthParameters();

%% Declare the UI processing functions

function processUICheckbox(contRange, thresh, morp)
    global ContRangeC ThreshC MorpC
    if(contRange ~= -1)
        ContRangeC = contRange;
    end
    if(thresh ~= -1)
        ThreshC = thresh;
    end
    if(morp ~= -1)
        MorpC = morp;
    end
    visualiseImage();
end

function processUIFrameChange(changeF)
    global InjPressure FiringCycle ImageBag CrankAngle
    ImageBag = ImageBag + changeF;
    testDir = dataDirProcessing(InjPressure, FiringCycle, ImageBag);
    if ~isfile(testDir)
        ImageBag = ImageBag - changeF;
        return
    end
    CrankAngle = -9.6 + ImageBag * 0.36;
    visualiseImage();
end

function processUICycleChange(changeC, changeFC)
    global Cycles InjPressure FiringCycle ImageBag
    Cycles = Cycles + changeC;
    FiringCycle = FiringCycle + changeFC;
    testDir = dataDirProcessing(InjPressure, FiringCycle, ImageBag);
    if ~isfile(testDir)
        FiringCycle = FiringCycle - changeFC;
        Cycles = Cycles - changeC;
        return
    end
    visualiseImage();
    flameGrowthParameters();
end

function processUIEdit(morp, upA, loA)
    global ImadjustRange MorpSize Frames Cycles;
    if (morp == -1)
        if (upA == -1)
            loA = str2double(loA);
            if(loA < ImadjustRange(2))
                ImadjustRange(1) = loA;
            end
        else
            upA = str2double(upA);
            if(upA > ImadjustRange(1))
                ImadjustRange(2) = upA;
            end
        end
    else
        MorpSize = round(str2double(morp));
    end
    visualiseImage();
    flameGrowthParameters();
end

function processUIInjPressure(injPressure)
    global InjPressure FiringCycle ImageBag;
    testDir = dataDirProcessing(str2double(injPressure), FiringCycle, ImageBag);
    if ~isfile(testDir)
        return
    end
    InjPressure = str2double(injPressure);
    visualiseImage();
    flameGrowthParameters();
end

%% Declare visualisation image function

function visualiseImage()
    global f Mask ImadjustRange MorpSize ImageBag ContRangeC ThreshC MorpC...
        CrankAngle FiringCycle InjPressure Cycles;
    f;
    FrameImage = dataDirProcessing(InjPressure, FiringCycle, ImageBag);
    P_org=imread(FrameImage);
    P=rgb2gray(P_org);
    P(Mask==0)=0;
    % Step 1. Contrast enhancement.
    P1=imadjust(P, ImadjustRange);
    % Step 2. Image binarisation.
    level = graythresh(P1);
    P2=im2bw(P1, level);
    % Can we use imbinarize? Better performance?
    % Step 4. Close the image
    SE = strel('disk',MorpSize);
    P3=imclose(P2,SE);
    % Step 5. Open the image
    P4=imopen(P3,SE);
    cols = 2 + ContRangeC + ThreshC + MorpC;
    counter = 1;
    subplot(length(ImageBag), cols, counter);
    imshow(P);
    title('Original');
    counter = counter + 1;
    if(ContRangeC)
        subplot(length(ImageBag), cols, counter);
        imshow(P1);
        title('Adjusted Range');
        counter = counter + 1;
    end
    if(ThreshC)
        subplot(length(ImageBag), cols, counter);
        imshow(P2);
        title('Thresholded');
        counter = counter + 1;
    end
    if(MorpC)
        subplot(length(ImageBag), cols, counter);
        imshow(P3);
        title('Closed');
        counter = counter + 1;
    end
    subplot(length(ImageBag), cols, counter);
    imshow(P4);
    title('Opened');
    uicontrol('Parent',f,'Style','text','fontweight','bold','Position',[0,30,550,20],...
                'String',"Flame Propagation Visualisation GUI (Inj Pressure: " + num2str(InjPressure) + "bar, Firing Cycle: " + num2str(FiringCycle) + ", Cycle: " + num2str(Cycles) + ", CA: " + num2str(CrankAngle) + " bTDC)",'BackgroundColor',f.Color);
    uicontrol('Parent',f,'Style','text','Position',[0,0,70,30],...
                'String',"Kernel Size [" + num2str(MorpSize) + "]",'BackgroundColor',f.Color);
    uicontrol('Parent',f,'Style','text','Position',[100,0,70,30],...
                'String',"Upper Adjust [" + num2str(ImadjustRange(2))+ "]",'BackgroundColor',f.Color);
    uicontrol('Parent',f,'Style','text','Position',[200,0,70,30],...
                'String',"Lower Adjust [" + num2str(ImadjustRange(1)) + "]",'BackgroundColor',f.Color);
    uicontrol('Parent',f,'Style','text','Position',[510,0,70,30],...
                'String',"Inj Pressure [" + num2str(InjPressure) + "]",'BackgroundColor',f.Color);
end

%% Declare Data Directory processing

function FrameImage = dataDirProcessing(injPressure, fCycle, imageRef)
    global DataDirectory Cycles
    if(imageRef < 10)
        if(Cycles ~= 10)
            DataDirectory = "D:\scott\Documents\University\Research Thesis\InjectionPressureVariation_202106\ProcessedMovie\" + num2str(injPressure) + "bar\f" + num2str(fCycle) + "_240_210_tSpk_6_S000" + num2str(Cycles) + "\f" + num2str(fCycle) + "_240_210_tSpk_6_S000" + num2str(Cycles) + "00000";
        else
            DataDirectory = "D:\scott\Documents\University\Research Thesis\InjectionPressureVariation_202106\ProcessedMovie\" + num2str(injPressure) + "bar\f" + num2str(fCycle) + "_240_210_tSpk_6_S00" + num2str(Cycles) + "\f" + num2str(fCycle) + "_240_210_tSpk_6_S00" + num2str(Cycles) + "00000";
        end
    else
        if(Cycles ~= 10)
            DataDirectory = "D:\scott\Documents\University\Research Thesis\InjectionPressureVariation_202106\ProcessedMovie\" + num2str(injPressure) + "bar\f" + num2str(fCycle) + "_240_210_tSpk_6_S000" + num2str(Cycles) + "\f" + num2str(fCycle) + "_240_210_tSpk_6_S000" + num2str(Cycles) + "0000";
        else
            DataDirectory = "D:\scott\Documents\University\Research Thesis\InjectionPressureVariation_202106\ProcessedMovie\" + num2str(injPressure) + "bar\f" + num2str(fCycle) + "_240_210_tSpk_6_S00" + num2str(Cycles) + "\f" + num2str(fCycle) + "_240_210_tSpk_6_S00" + num2str(Cycles) + "0000";
        end
    end
    FrameImage = strcat(DataDirectory, num2str(imageRef), '.jpg');
end

%% Declare flame growth production function

function flameGrowthParameters()
    global Mask ImadjustRange MorpSize FiringCycle InjPressure R_Thres...
        Cycles Center CaseMeanR CA StartFrame;
    DirHeader = "D:\scott\Documents\University\Research Thesis\InjectionPressureVariation_202106\ProcessedMovie\" + num2str(InjPressure) + "bar";
    FCycleHeader = "f" + num2str(FiringCycle) + "_240_210_tSpk_6_S";
    InitialFlameFrame=3;
    BoundaryLayerThickness=[12];
    K=0;
    MaxR=0;
    i_frame=StartFrame;
    while MaxR<R_Thres
        K=K+1;
        i_frame=i_frame+1;
        CycleFolder=fullfile(DirHeader, FCycleHeader + sprintf('%04d',Cycles));
        FrameImage=fullfile(CycleFolder, FCycleHeader + sprintf('%04d',Cycles) + sprintf('%06d',i_frame) + '.jpg');
        % Image load and binarization ============================
        I_org=imread(FrameImage);
        I=rgb2gray(I_org);
        I(Mask==0)=0;
        % Step 1. Contrast enhancement.
        I1=imadjust(I, ImadjustRange);
        % Step 2. Image binarisation.
        level = graythresh(I1);
        I2=im2bw(I1, level);
        % Can we use imbinarize? Better performance?
        % Step 4. Close the image
        SE = strel('disk',MorpSize);
        I3=imclose(I2,SE);
        % Step 5. Open the image
        I4=imopen(I3,SE);
        % Step 5. Fill in the holes of the boundary
        I5 = imfill(I4,'holes');
        % Step 6. Boundary detection.
        Temp_B=bwboundaries(I5);
        if ~isempty(Temp_B)
            % ========================================================
            % Ignoring too small area detected =======================
            G=0;
            for i_B=1:length(Temp_B)
                MaxX=max(Temp_B{i_B}(:,2));
                MaxY=max(Temp_B{i_B}(:,1));
                MinX=min(Temp_B{i_B}(:,2));
                MinY=min(Temp_B{i_B}(:,1));
                if MaxX-MinX > 3 && MaxY-MinY > 3
                    G=G+1;
                    GEOM(G,1:4)=polygeom(Temp_B{i_B}(:,2),Temp_B{i_B}(:,1));
                    B{G}=Temp_B{i_B};
                elseif MaxX-MinX < 3 && MaxY-MinY < 3
                    G=G+1;
                    GEOM(G,1:4)=zeros(1,4);
                    B{G}=[0 0];
                end
            end
            [G_N, ~]=size(GEOM);
            Temp_GEOM=GEOM;
            % ==========================================================
            % Multiple flame area detection during the initial flame propagation.
            % Selected top 3 maximum boundary area will be considered.
            if K < InitialFlameFrame
                if G_N > 3
                    for i_MAX=1:3
                        [~, G_sel(i_MAX)]=max(Temp_GEOM(:,1));
                        Temp_GEOM(G_sel(i_MAX),1)=0;
                    end
                else
                    for i_MAX=1:G_N
                        [~, G_sel(i_MAX)]=max(Temp_GEOM(:,1));
                        Temp_GEOM(G_sel(i_MAX),1)=0;
                    end
                end
                MaxR=0;
                clearvars Temp_GEOM
                for i_sel=1:length(G_sel)
                    Temp_SelectedArea(i_sel)=GEOM(G_sel(i_sel),1);
                    Temp_SelectedBoundary{i_sel}=B{G_sel(i_sel)};
                    Temp_Selected_X(i_sel)=GEOM(G_sel(i_sel),2);
                    Temp_Selected_Y(i_sel)=GEOM(G_sel(i_sel),3);
                end
                SelectedArea{K}=Temp_SelectedArea;
                SelectedBoundary{K}=Temp_SelectedBoundary;
                Selected_X{K}=Temp_Selected_X;
                Selected_Y{K}=Temp_Selected_Y;
            end
            % ===============================================================
            % After initial flame propagation, the one largest flame considered only.
            if K >= InitialFlameFrame
                [~, G_sel]=max(GEOM(:,1));
                SelectedArea{K}=GEOM(G_sel,1);
                SelectedBoundary{K}=B{G_sel};
                Selected_X{K}=GEOM(G_sel,2);
                Selected_Y{K}=GEOM(G_sel,3);
                R=sqrt((SelectedBoundary{K}(:,2)-Center(1)).^2+(SelectedBoundary{K}(:,1)-Center(2)).^2);
                MaxR=max(R);
                %======================================================
                % extract boundary layer
                Temp_I5=~I5;
                SE = strel('disk',BoundaryLayerThickness,8);
                I5_D=imdilate(Temp_I5,SE);
                BoundayLayer{K}=~I5_D+~I5;
                %======================================================
            end
            r=sqrt(sum(SelectedArea{K})/pi);
            cent_x(K)=mean(Selected_X{K});
            cent_y(K)=mean(Selected_Y{K});
            theta=[0:0.01:2*pi];
            xp=r*cos(theta)+cent_x(K);
            yp=r*sin(theta)+cent_y(K);
            MeanR(K)=r;
            CAD(K)=CA(i_frame);
            else
                disp('COULDNT FIND BOUND')
                MeanR(K)=0;
                CAD(K)=CA(i_frame);
                SelectedBoundary{K}=0;
                Selected_X{K}=0;
                Selected_Y{K}=0;
        end
    end
    % Calculating Mean R growth
    for i_meanR=1:length(MeanR)-1
        deltaMeanR(i_meanR)=MeanR(i_meanR+1)-MeanR(i_meanR);
    end
    CaseBoundary=SelectedBoundary;
    CaseMeanR=MeanR;
    CasedeltaMeanR=deltaMeanR;
    CaseCrankAngle=CAD;
    CaseCent_X=Selected_X;
    CaseCent_Y=Selected_Y;
    CaseCent_BoundaryLayer=BoundayLayer;
    CAT = CA(StartFrame + 1:length(CaseMeanR) + StartFrame);
    figure(2);
    clf;
    hold on;
    title("Flame Propagation Visualisation GUI (Inj Pressure: " + num2str(InjPressure) + "bar, Firing Cycle: " + num2str(FiringCycle) + ", Cycle: " + num2str(Cycles));
    xlabel('Crank Angle (degrees bTDC)');
    ylabel('Flame boundary area (mm^2)');
    plot(CAT, CaseMeanR);
%     clearvars -except DataDirectory CaseDirectory DirHeader FCycleHeader ImgRes CrankAngle i_frame CenterBAG R_ThresBAG ...
%         CalibrationBAG CaseBoundary CaseMeanR CA CasedeltaMeanR CaseCrankAngle MaxR K i_cycle Mask ImadjustRangeBAG OtsuParaBAG InitialFlameFrame ...
%         StartFrameBAG MorpSize CaseCent_Y InjPressure FiringCycle CaseCent_X ...
%         Accu_CaseBoundary Accu_CasedeltaMeanR Accu_CaseMeanR Accu_CaseCrankAngle Accu_CaseCent_X Accu_CaseCent_Y Case ...
%         StartFrame R_Thres ImadjustRange OtsuPara Center i_f i_day Data FiringNumber FiringNumberBAG DateBAG ...
%         InitialFlameFrameBAG CaseCent_BoundaryLayer Accu_CaseCent_BoundaryLayer Adjust_Low  Adjust_High ProcessedImgSaveFolder BoundaryLayerThickness tSpk InjectionPressure % focus here image adjust variable
end