function Chineseflag()
flag = zeros(299,399);
show = flag;
show(end+1,1) = 0;  
show(end,end+1) = 1;
pcolor(1:400,1:300,show);
colormap hsv
shading flat
axis off
hold on
Chinesestar(45,65,230,0)
Chinesestar(7.5,120,270,pi/5)
Chinesestar(7.5,150,240,pi/30)
Chinesestar(7.5,150,210.5,pi/8)
Chinesestar(7.5,120,180,-pi/15)
hold off

function Chinesestar(r,x,y,z)
A = r*[-cos(pi*1/10),-sin(pi*1/10)*tan(pi*2/10),0,sin(pi*1/10)*tan(pi*2/10),cos(pi*1/10),sin(pi*1/10)/cos(pi*2/10)*cos(pi*1/10),cos(pi*3/10),0,-cos(pi*3/10),-sin(pi*1/10)/cos(pi*2/10)*cos(pi*1/10),-cos(pi*1/10)];
B = r*[sin(pi*1/10),sin(pi*1/10),1,sin(pi*1/10),sin(pi*1/10),-sin(pi*1/10)/cos(pi*2/10)*sin(pi*1/10),-sin(pi*3/10),-sin(pi*1/10)/cos(pi*2/10),-sin(pi*3/10),-sin(pi*1/10)/cos(pi*2/10)*sin(pi*1/10),sin(pi*1/10)];
[C,D] = cart2pol(A,B);
C = C + z;
[A,B] = pol2cart(C,D);
A = A+x;
B = B+y;
fill(A,B,[1,1,0])
hold on
plot(A,B,'y-')