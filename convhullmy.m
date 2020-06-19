function  convhullmy()
% this is a function to compute Convex Hull
s = [];
n = 100;
x = rand(n,2);

s = go(x);
disp(s);


end
function k =  go(x)
plot(x(:,1),x(:,2),"*")
k =[]; % 设置返回数组索引
[m,~] = size(x);
for i = 1: m
  b = x(i,:);
  A =x;
  A(i,:) = [];
 [t,~,flag]=linprog(ones(m-1,1),[],[],[ones(1,m-1);A'],[1;b'],zeros(m-1,1),ones(m-1,1));
  %求线性规划的解，无解就是顶点，有解非顶点
    if flag<0
        k=[i,k]; %记录顶点的编号  
    end
end
hold on
%标出顶点     
% text(x(k,1)+0.02,x(k,2),num2str(k'));
t = x(k,1);s = x(k,2);
x0 = max(x(k,1)); x1 = min(x(k,1)); x2 =(x0+x1)/2;
y0 = max(x(k,2)); y1 = min(x(k,2)); y2 =(y0+y1)/2;
theta = atan2((t-x2),(s-y2));
[B,index] = sort(theta);
% text(t(index)+0.02,s(index),num2str(k'));
n = index(end);
plot(t(index),s(index))
plot([t(index(1)),t(n)], [s(index(1)),s(n)],"r")
k = index;
end