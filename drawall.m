I = imread("Chineseflag.png");
figure
imshow(I);
% axises of the big
bigX = [143,131,96,155,190,125,162,143,114,173];
bigY = [60,95,95,95,95,118,118,132,153,153];
% axises of the small 
smallX1 = [198,203,208,200,207,196,201,205,210,203];
smallY1 = [58,62,58,64,64,69,69,69,69,75];
smallX2 = [235,228,233,237,244,232,240,232,236,241];
smallY2 = [91,98,97,97,97,102,102,107,104,107];
smallX3 = [233,227,233,237,242,233,239,234,237,243];
smallY3 = [126,135,132,130,128,137,134,143,138,139];
smallX4 = [205,196,202,206,211,199,207,196,202,207];
smallY4 = [161,164,165,166,168,170,171,175,173,177];
% merge all 
X = [bigX,smallX1,smallX2,smallX3,smallX4];
Y = [bigY,smallY1,smallY2,smallY3,smallY4];
XY = [X',Y'];
k = convhull(XY);
% plot the lines
hold on
plot(XY(k,1),XY(k,2))
hold off