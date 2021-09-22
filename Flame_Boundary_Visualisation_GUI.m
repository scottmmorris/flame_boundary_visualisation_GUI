%% Declare global variables for callbacks

global CrankAngle ImadjustRange MorpSize DataDirectory ImageBag ContRangeC...
    ThreshC MorpC Cycles FiringCycle InjPressure f;

%% Set up the Image Data Access

DataDirectory =...
    'D:\scott\Documents\University\Research Thesis\InjectionPressureVariation_202106\ProcessedMovie\50bar\f1_240_210_tSpk_6_S0001\f1_240_210_tSpk_6_S00010000';

ImageBag =  10;
CrankAngle = -9.6 + ImageBag * 0.36;

%% Define the fixed parameters

ImgRes=768;        
Center=[383 368];
R_Thres=[713-368];

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
morpSizeControl.Callback = @(ui,~) processUIEdit(ui.String,-1,-1,-1,-1);

uppAdjControl = uicontrol('Parent',f,'Style','edit','Position',[170,5,30,20],...
              'value',ImadjustRange(2));
uppAdjControl.Callback = @(ui,~) processUIEdit(-1,ui.String,-1,-1,-1); 

lowAdjControl = uicontrol('Parent',f,'Style','edit','Position',[270,5,30,20],...
              'value',ImadjustRange(1));
lowAdjControl.Callback = @(ui,~) processUIEdit(-1,-1,ui.String,-1,-1);

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
end

function processUIEdit(morp, upA, loA, frames,cycles)
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
    if(frames ~= -1)
        Frames = str2double(frames);
    end
    if(cycles ~= -1)
        Cycles = str2double(cycles);
    end
    visualiseImage();
end

function processUIInjPressure(injPressure)
    global InjPressure FiringCycle ImageBag;
    testDir = dataDirProcessing(str2double(injPressure), FiringCycle, ImageBag);
    if ~isfile(testDir)
        return
    end
    InjPressure = str2double(injPressure);
    visualiseImage();
end

%% Declare visualisation image function

function visualiseImage()
    global f Mask ImadjustRange MorpSize ImageBag ContRangeC ThreshC MorpC...
        CrankAngle FiringCycle InjPressure Cycles;
        FrameImage = dataDirProcessing(InjPressure, FiringCycle, ImageBag);
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
        cols = 2 + ContRangeC + ThreshC + MorpC;
        counter = 1;
        subplot(length(ImageBag), cols, counter);
        imshow(I);
        title('Original');
        counter = counter + 1;
        if(ContRangeC)
            subplot(length(ImageBag), cols, counter);
            imshow(I1);
            title('Adjusted Range');
            counter = counter + 1;
        end
        if(ThreshC)
            subplot(length(ImageBag), cols, counter);
            imshow(I2);
            title('Thresholded');
            counter = counter + 1;
        end
        if(MorpC)
            subplot(length(ImageBag), cols, counter);
            imshow(I3);
            title('Closed');
            counter = counter + 1;
        end
        subplot(length(ImageBag), cols, counter);
        imshow(I4);
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