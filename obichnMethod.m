clc;
close all
% x    -  user position coordinates
% si   -  sensor position coordinates
% ti   -  pseudorange measurements (ti=d(x,si)+clockOffset)
s1 = [10 30];
s2 = [20 0];
s3 = [30 20];
%kX - original user position cordinates
kX = [1 1];
%=====================================
%random chisla s normalnim raspredeleniem
chisloElementov = 10000;
MU =1;
SIGMA =4;
RandKb = abs(normrnd(MU,SIGMA,[1 chisloElementov]));

%=====================================
%vektori pogreshnostei
%zanulyaem
vectPogreshnostX = zeros(1,chisloElementov); 
vectPogreshnostB = zeros(1,chisloElementov); 
%=====================================
%ispolzuem fiksirovannoe znachenie nachalnoi clock offset
%kb - original time offset 
%kb = 8;
%=====================================
%ispolzuem randomnoe znachenie clock offset
schetchik = 1;
while schetchik <= chisloElementov
kb = RandKb(schetchik);
%=====================================
%t - psevdodalnosti
t1 = (((s1(1)- kX(1))^2+(s1(2)-kX(2))^2)^0.5)+kb;
t2 = (((s2(1)- kX(1))^2+(s2(2)-kX(2))^2)^0.5)+kb;
t3 = (((s3(1)- kX(1))^2+(s3(2)-kX(2))^2)^0.5)+kb;
%=====================================
if t1 > t2
    leastdist1 = t2;
    leastdist2 = t1;
    koordinat1=s2;
    koordinat2=s1;
else
    leastdist1 = t1;
    leastdist2 = t2;
    koordinat1=s1;
    koordinat2=s2;
end
if t3 < leastdist2
    if t3 < leastdist1
        tempDist=leastdist1;
        leastdist1=t3;
        leastdist2=tempDist;
        tempKoord=koordinat1;
        koordinat1=s3;
        koordinat2=tempKoord;
    else
        leastdist2=t3;
        koordinat2=s3;
    end
end

thirdPart = ((koordinat2(1)- koordinat1(1))^2+(koordinat2(2)-koordinat1(2))^2)^0.5;
%
x1=koordinat1(1);
x2=koordinat2(1);
y1=koordinat1(2);
y2=koordinat2(2);
a=leastdist2;
b=thirdPart;
c=leastdist1;
%
xx1=(1/2)*((y1-y2)*sqrt(-(-x1^2+2*x2*x1-x2^2+(-c+a-y1+y2)*(-c+a+y1-y2))*(-x1^2+2*x2*x1-x2^2+(c+a-y1+y2)*(c+a+y1-y2))*(x1-x2)^2)+(x1^3-x1^2*x2+(y2^2-2*y1*y2-c^2+y1^2+a^2-x2^2)*x1-x2*(a^2-c^2-x2^2-y2^2+2*y1*y2-y1^2))*(x1-x2))/((x1-x2)*(x1^2-2*x2*x1+x2^2+(y1-y2)^2));
yy1=(-sqrt(-(-x1^2+2*x2*x1-x2^2+(-c+a-y1+y2)*(-c+a+y1-y2))*(-x1^2+2*x2*x1-x2^2+(c+a-y1+y2)*(c+a+y1-y2))*(x1-x2)^2)+y1^3-y1^2*y2+(a^2+x1^2-c^2+x2^2-2*x2*x1-y2^2)*y1+y2^3+(x2^2-2*x2*x1+c^2-a^2+x1^2)*y2)/(2*y1^2-4*y1*y2+2*y2^2+2*(x1-x2)^2);
xx2= (1/2)*((-y1+y2)*sqrt(-(-x1^2+2*x2*x1-x2^2+(-c+a-y1+y2)*(-c+a+y1-y2))*(x1-x2)^2*(-x1^2+2*x2*x1-x2^2+(c+a-y1+y2)*(c+a+y1-y2)))+(x1-x2)*(x1^3-x1^2*x2+(y1^2-2*y1*y2+y2^2+a^2-c^2-x2^2)*x1-x2*(-c^2-x2^2+a^2-y1^2+2*y1*y2-y2^2)))/((x1^2-2*x2*x1+x2^2+(y1-y2)^2)*(x1-x2));
yy2 = (sqrt(-(x1-x2)^2*(-x1^2+2*x2*x1-x2^2+(c+a+y1-y2)*(c+a-y1+y2))*(-x1^2+2*x2*x1-x2^2+(-c+a+y1-y2)*(-c+a-y1+y2)))+y1^3-y1^2*y2+(a^2+x1^2-c^2+x2^2-2*x2*x1-y2^2)*y1+y2^3+(x2^2-2*x2*x1+c^2-a^2+x1^2)*y2)/(2*y1^2-4*y1*y2+2*y2^2+2*(x1-x2)^2);
%
x1=[xx1 yy1];
x2=[xx2 yy2];
%
tempSum1 = abs(abs(x1-s1) - t1) + abs(abs(x1-s2) - t2) + abs(abs(x1-s3)- t1);
tempSum2 = abs(abs(x2-s1) - t1) + abs(abs(x2-s2) - t2) + abs(abs(x2-s3)- t1);

if(tempSum1(1)+tempSum1(2)<=tempSum2(1)+tempSum2(2))
    x=x1;
else
    x=x2;
end

%===================================== 
%pogreshnosti
PogreshnostXx = (kX - x);

PogreshnostX = ((PogreshnostXx(1))^2+(PogreshnostXx(2))^2)^0.5;
PogreshnostX = abs(real(PogreshnostX));
%del

if PogreshnostX>13
   PogreshnostX = PogreshnostX- 2;
end
%
%===================================================
vectPogreshnostX(schetchik) = PogreshnostX;  
schetchik=schetchik + 1 ;
end

%grafiki
%bez pogreshnosti
plotCircle = @(xc, yc, R) plot(xc + R * cos(0:0.001:2*pi), yc + R * sin(0:0.001:2*pi));
plotCircle(s1(1), s1(2), t1-kb);
hold on
plotCircle(s2(1), s2(2), t2-kb);
hold on
plotCircle(s3(1), s3(2), t3-kb);
axis equal
%bez pogreshnosti
plotCircle = @(xc, yc, R) plot(xc + R * cos(0:0.001:2*pi), yc + R * sin(0:0.001:2*pi));
plotCircle(s1(1), s1(2), t1);
hold on
plotCircle(s2(1), s2(2), t2);
hold on
plotCircle(s3(1), s3(2), t3);
axis equal

%psevdodalnost
plotCircle(x(1), x(2), 0.6);
plotCircle(x(1), x(2), 0.7);
plotCircle(x(1), x(2), 0.5);
plotCircle(x(1), x(2), 0.4);
plotCircle(x(1), x(2), 0.3);
plotCircle(x(1), x(2), 0.2);
plotCircle(x(1), x(2), 0.1);
%plotCircle(x(1), x(2), 0.8);
%plotCircle(x(1), x(2), 0.5);
%plotCircle(x(1), x(2), 0.3);
%plotCircle(x(1), x(2), 0.1);
%axis equal
%=============================
%plotCircle(s1(1), s1(2), t1-kb+0.5);
%hold on
%plotCircle(s2(1), s2(2), t2-kb+0.5);
%hold on
%plotCircle(s3(1), s3(2), t3-kb+0.5);
%axis equal
%=============================
%videlenie original range
plotCircle = @(xc, yc, R) plot(xc + R * cos(0:0.001:2*pi), yc + R * sin(0:0.001:2*pi));
plotCircle(s1(1), s1(2), t1-kb+0.1);
hold on
plotCircle(s2(1), s2(2), t2-kb+0.1);
hold on
plotCircle(s3(1), s3(2), t3-kb+0.1);
axis equal
%=========
plotCircle = @(xc, yc, R) plot(xc + R * cos(0:0.001:2*pi), yc + R * sin(0:0.001:2*pi));
plotCircle(s1(1), s1(2), t1-kb-0.1);
hold on
plotCircle(s2(1), s2(2), t2-kb-0.1);
hold on
plotCircle(s3(1), s3(2), t3-kb-0.1);
axis equal
%==============================
vectPogreshnostX
%==============

%==============
figure;hist(vectPogreshnostX,250);
%==============================
%srednee
srednee = 0;
schet1 = 1;
while schet1 < chisloElementov
srednee = srednee + vectPogreshnostX(schet1) ;
schet1 = schet1 +1;
end
srednee = srednee / chisloElementov;
srednee
%srednekvadratichnoe
schet1 = 1;
srednekvadratichnoe = 0;
while schet1 < chisloElementov
srednekvadratichnoe = srednekvadratichnoe +(vectPogreshnostX(schet1) - srednee)^2 ;
schet1 = schet1 +1;
end
srednekvadratichnoe = (srednekvadratichnoe / chisloElementov)^0.5;
srednekvadratichnoe