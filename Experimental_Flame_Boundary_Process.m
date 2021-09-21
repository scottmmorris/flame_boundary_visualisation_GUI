clear all; clc;

% Initialise constants
ImgRes=768;
CrankAngle=linspace(-11.6,156.4,501);
CrankAngleT=CrankAngle(13:35);
InitialFlameFrame=10;
MorpSize=3;
Center=[380 367];
R_Thres=[736-367];

% Variables
ImadjustRange=[0.01 0.2;...
    0.01 0.2;...
    0.01 0.2;...
    0.01 0.2];
OtsuPara=[0.01;
    0.10;
    0.20;
    0.40];

% Mask Generation =================================
 Mask=ones(ImgRes,ImgRes);
for i_x=1:ImgRes
    for i_y=1:ImgRes
        Dist=sqrt((i_x-Center(1)).^2+(i_y-Center(2)).^2);
        if Dist > R_Thres+10
            Mask(i_y,i_x)=0;
        end
    end
end

for i=15:35
%     I_org=imread(['C:\Users\scott\OneDrive\Documents\University\2021 S1\Research Thesis\MATLABImageProcessing\f1_240_210_S0001\f1_240_210_S00010000', num2str(i), '.jpg']);
    I_org=imread(['D:\scott\Documents\University\Research Thesis\InjectionPressureVariation_202106\ProcessedMovie\50bar\f1_240_210_6_S0001\f1_240_210_6_S00010000', num2str(i), '.jpg']);

    
    I=rgb2gray(I_org);
    I(Mask==0)=0;
    ImgIntensity(1)=sum(sum(I))/(ImgRes*ImgRes);

    IA = ImAdj(I,ImadjustRange(3, :));
    IB = ImAdj(I,ImadjustRange(3, :));
    IC = ImAdj(I,ImadjustRange(3, :));
    ID = ImAdj(I,ImadjustRange(3, :));

    IA1 = ImBin(IA, OtsuPara(1), MorpSize);
    IB1 = ImBin(IB, OtsuPara(2), MorpSize);
    IC1 = ImBin(IC, OtsuPara(3), MorpSize);
    ID1 = ImBin(ID, OtsuPara(4), MorpSize);

    [BoundaryA, CircleA, CentA] = ImBound(IA1, Center);
    [BoundaryB, CircleB, CentB] = ImBound(IB1, Center);
    [BoundaryC, CircleC, CentC] = ImBound(IC1, Center);
    [BoundaryD, CircleD, CentD] = ImBound(ID1, Center);

    if(i < 25)
        figure(i+100);
        imshow(I_org);
        figure(i-10);
%         subplot(2, 4, 1); imshow(IA); title(['Image Intensity Threshold ', num2str(ImadjustRange(1, 1)), ' & ', num2str(ImadjustRange(1, 2))]); hold on; plot(CircleA(1, :), CircleA(2, :), 'color', [0 1 0]); plot(CentA(1), CentA(2), '*', 'color', [0 1 0]);
%         subplot(2, 4, 2); imshow(IB); title(['Image Intensity Threshold ', num2str(ImadjustRange(2, 1)), ' & ', num2str(ImadjustRange(2, 2))]); hold on; plot(CircleB(1, :), CircleB(2, :), 'color', [0 1 0]); plot(CentB(1), CentB(2), '*', 'color', [0 1 0]);
%         subplot(2, 4, 3); imshow(IC); title(['Image Intensity Threshold ', num2str(ImadjustRange(3, 1)), ' & ', num2str(ImadjustRange(3, 2))]); hold on; plot(CircleC(1, :), CircleC(2, :), 'color', [0 1 0]); plot(CentC(1), CentC(2), '*', 'color', [0 1 0]);
%         subplot(2, 4, 4); imshow(ID); title(['Image Intensity Threshold ', num2str(ImadjustRange(4, 1)), ' & ', num2str(ImadjustRange(4, 2))]); hold on; plot(CircleD(1, :), CircleD(2, :), 'color', [0 1 0]); plot(CentD(1), CentD(2), '*', 'color', [0 1 0]);
        subplot(2, 4, 1); imshow(IA); title(['Image Binarisation ', num2str(OtsuPara(1))]); hold on; plot(CircleA(1, :), CircleA(2, :), 'color', [0 1 0]); plot(CentA(1), CentA(2), '*', 'color', [0 1 0]);
        subplot(2, 4, 2); imshow(IB); title(['Image Binarisation ', num2str(OtsuPara(2))]); hold on; plot(CircleB(1, :), CircleB(2, :), 'color', [0 1 0]); plot(CentB(1), CentB(2), '*', 'color', [0 1 0]);
        subplot(2, 4, 3); imshow(IC); title(['Image Binarisation ', num2str(OtsuPara(3))]); hold on; plot(CircleC(1, :), CircleC(2, :), 'color', [0 1 0]); plot(CentC(1), CentC(2), '*', 'color', [0 1 0]);
        subplot(2, 4, 4); imshow(ID); title(['Image Binarisation ', num2str(OtsuPara(4))]); hold on; plot(CircleD(1, :), CircleD(2, :), 'color', [0 1 0]); plot(CentD(1), CentD(2), '*', 'color', [0 1 0]);
        subplot(2, 4, 5); imshow(IA1); hold on; plot(BoundaryA(:,2), BoundaryA(:,1),'r');
        subplot(2, 4, 6); imshow(IB1); hold on; plot(BoundaryB(:,2), BoundaryB(:,1),'r');
        subplot(2, 4, 7); imshow(IC1); hold on; plot(BoundaryC(:,2), BoundaryC(:,1),'r');
        subplot(2, 4, 8); imshow(ID1); hold on; plot(BoundaryD(:,2), BoundaryD(:,1),'r');
    end

    areaA(i-12) = pi * ((CircleA(1, 1) - CentA(1)) * 0.071)^2;
    areaB(i-12) = pi * ((CircleB(1, 1) - CentB(1)) * 0.071)^2;
    areaC(i-12) = pi * ((CircleC(1, 1) - CentC(1)) * 0.071)^2;
    areaD(i-12) = pi * ((CircleD(1, 1) - CentD(1)) * 0.071)^2;
    
    minimumVal(i-12) = min([areaA(i-12), areaB(i-12), areaC(i-12), areaD(i-12)]);
    maximumVal(i-12) = max([areaA(i-12), areaB(i-12), areaC(i-12), areaD(i-12)]);
    averageVal(i-12) = mean([areaA(i-12), areaB(i-12), areaC(i-12), areaD(i-12)]);
end

figure(1);
hold on;
title('Temporal comparison of equivalent flame boundary for different binarisation thresholds');
xlabel('Crank Angle (degrees bTDC)');
ylabel('Equivalent flame boundary area (mm^2)');
plot(CrankAngleT, areaA, 'g');
plot(CrankAngleT, areaB, 'b');
plot(CrankAngleT, areaC, 'y');
plot(CrankAngleT, areaD, 'r');
leg = legend(num2str(OtsuPara(1)), num2str(OtsuPara(2)), num2str(OtsuPara(3)), num2str(OtsuPara(4)), 'Location', 'northwest');
title(leg, 'Binarisation Threshold');

crankDiff = CrankAngleT(23) - CrankAngleT(1);
meanGrowthA = (areaA(23) - areaA(1))/(crankDiff);
meanGrowthB = (areaB(23) - areaB(1))/(crankDiff);
meanGrowthC = (areaC(23) - areaC(1))/(crankDiff);
meanGrowthD = (areaD(23) - areaD(1))/(crankDiff);
figure(2);
hold on;
title('Average flame growth comparison for different binarisation thresholds');
xlabel('Binarization Threshold');
ylabel('Average Flame Growth (mm^2/degree CA)');
Labels = categorical({'0.01','0.10','0.20','0.40'});

b = bar(Labels, [meanGrowthA; meanGrowthB; meanGrowthC; meanGrowthD]);
b.FaceColor = 'flat';
b.CData(1,:) = [0 1 0];
b.CData(2,:) = [0 0 1];
b.CData(3,:) = [1 1 0];
b.CData(4,:) = [1 0 0];

% Function for contrast enhancement.
function ImRet = ImAdj(Image, Adjustment)
    ImRet = imadjust(Image, Adjustment);
end

% Function for image binarisation.
function ImRet = ImBin(Image, Binarisation, MorpSize)
    level = graythresh(Image);
    I = im2bw(Image, level * Binarisation);
    SE = strel('disk',MorpSize);
    I = imclose(I, SE);
    I = imopen(I, SE);
    ImRet = imfill(I, 'holes');
end

% Function for boundary detection.
function [Boundary, Circle, Cent] = ImBound(Image, Center)
    Temp_B=bwboundaries(Image);
    if ~isempty(Temp_B)
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
 
        [~,G_sel]=max(GEOM(:,1));
        SelectedArea=GEOM(G_sel,1);
        SelectedBoundary=B{G_sel};
        Selected_X=GEOM(G_sel,2);
        Selected_Y=GEOM(G_sel,3);
        R=sqrt((SelectedBoundary(:,2)-Center(1)).^2+(SelectedBoundary(:,1)-Center(2)).^2);

        r=sqrt(sum(SelectedArea)/pi);
        cent_x=mean(Selected_X);
        cent_y=mean(Selected_Y);
        theta=[0:0.01:2*pi];
        xp=r*cos(theta)+cent_x;
        yp=r*sin(theta)+cent_y;

        % Overlay 1: Boundaries
        % plot(SelectedBoundary(:,2),SelectedBoundary(:,1),'r')
        Boundary = SelectedBoundary;
        
        % Overlay 2: Equavalent circle
        % plot(xp,yp,'color',[0 1 0])
        % plot(cent_x,cent_y,'*','color',[0 1 0])
        % hold off;
        Circle = [xp; yp];
        Cent = [cent_x, cent_y];
    else
        Boundary = 0;
        Circle = 0;
        Cent = 0;
    end
end