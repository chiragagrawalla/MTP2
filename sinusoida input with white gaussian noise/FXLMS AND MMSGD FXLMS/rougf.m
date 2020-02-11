clear;
%close all;
clc;
Pwp=[1.000000,-2.616971,5.868128,-10.254027,16.472815,-23.574261,31.578068,-39.180908,46.125938,-51.048965,53.950325,-54.055084,51.845238,-47.205044,41.234455,-34.143761,27.083752,-20.176018,14.395070,-9.473912,5.902801,-3.258903,1.655440,-0.656055,0.208196];
Pwz=[-0.237467,0.806502,-1.882598,3.601750,-5.938800,8.734397,-11.601771,13.989734,15.218549,14.661575,-11.943175,7.090693,-0.801205,-5.311028,11.085567,-15.154731,16.927727,-17.206356,15.141826,-12.420147,8.971280,-5.755672,3.278546,-1.155305,0.303144];
Swp=[ 1.000000,-2.126286,4.237403,-6.964616,10.683328,-14.553812,18.877407,-22.745882,26.226549,-28.574720,29.879738,-29.674311,28.296484,-25.745836,22.470392,-18.625055,14.694556,-10.964108,7.748295,-4.980707,2.969857,-1.507602,0.719325,-0.266916,0.055631];
Swz=[-0.073844,0.280609,-0.778907,-0.321869,2.563927,-5.876712,11.504314,-18.114344,25.967108,-33.871861,41.345085,-47.070049,50.785450,-51.863720,50.043129,-45.990845,39.786583,-33.078777,25.692730,-18.861567,12.781915,-8.174841,4.567914,-2.076808,0.728670];
for itr=1:10
Pw=impz(Pwz,Pwp);
Sw=impz(Swz,Swp);
S_P=Sw(1:128);
Fs=9000; 
f1=250;
f2=500;
t=0:(1/Fs):1;
pd1=makedist('Stable','alpha',2,'beta',0,'gam',1,'delta',0);
%t=-5000:1:5000;
N=10000;
x3=pdf(pd1,t);
%x3=0.5.*(x1+x2);
% white noise signal,

s=filter(Pwz,Pwp,x3);
Yd=awgn(s,30);
% primary path design
ctrl_len=30;
Cx=zeros(1,ctrl_len);       
Cw=zeros(1,ctrl_len);     
Sx=zeros(size(S_P));
e_cont=zeros(1,length(t)); 
Shx=zeros(1,length(S_P));   
Xhx=zeros(1,ctrl_len);   
% and apply the FxLMS algorithm
mu=0.001;         
for k=1:length(t)                       
    Cx=[x3(k) Cx(1:end-1)];               
    Cy=Cx*Cw';                	
    Sx=[Cy; Sx(1:end-1)];   
    e_cont(k)=Yd(k)-Sx'*S_P; %filetring the secondary path 
    Shx=[x3(k) Shx(1:end-1)]; 
    S_temp=Shx*S_P;
    Xhx=[S_temp Xhx(1:end-1)];
   Cw=Cw+mu*e_cont(k)*Xhx; 
end
   err(itr,:)=e_cont.^2;
end
m=mean(err);

figure
plot(10*log10(m));
ylabel('MSE');
xlabel('iteration');
title('comparision MSE for the FXLMS and FXLMS-MMSGD algorithm');
legend('FXLMS');
grid on
figure
plot(Yd) 
hold on 
plot(e_cont, 'r:')
ylabel('Amplitude');
xlabel('Discrete time k');
legend('Noise signal', 'Control signal')
%%
%%fxlms with mmsgd
clear;
%close all;
clc;
Pwp=[1.000000,-2.616971,5.868128,-10.254027,16.472815,-23.574261,31.578068,-39.180908,46.125938,-51.048965,53.950325,-54.055084,51.845238,-47.205044,41.234455,-34.143761,27.083752,-20.176018,14.395070,-9.473912,5.902801,-3.258903,1.655440,-0.656055,0.208196];
Pwz=[-0.237467,0.806502,-1.882598,3.601750,-5.938800,8.734397,-11.601771,13.989734,15.218549,14.661575,-11.943175,7.090693,-0.801205,-5.311028,11.085567,-15.154731,16.927727,-17.206356,15.141826,-12.420147,8.971280,-5.755672,3.278546,-1.155305,0.303144];
Swp=[ 1.000000,-2.126286,4.237403,-6.964616,10.683328,-14.553812,18.877407,-22.745882,26.226549,-28.574720,29.879738,-29.674311,28.296484,-25.745836,22.470392,-18.625055,14.694556,-10.964108,7.748295,-4.980707,2.969857,-1.507602,0.719325,-0.266916,0.055631];
Swz=[-0.073844,0.280609,-0.778907,-0.321869,2.563927,-5.876712,11.504314,-18.114344,25.967108,-33.871861,41.345085,-47.070049,50.785450,-51.863720,50.043129,-45.990845,39.786583,-33.078777,25.692730,-18.861567,12.781915,-8.174841,4.567914,-2.076808,0.728670];
for itr=1:10
Pw=impz(Pwz,Pwp);
Sw=impz(Swz,Swp);
S_P=Sw(1:128);
Fs=9000; 
f1=250;
f2=500;
t=0:(1/Fs):1;
pd1=makedist('Stable','alpha',2,'beta',0,'gam',1,'delta',0);
%t=-5000:1:5000;
N=10000;
x3=pdf(pd1,t);
%x3=0.5.*(x1+x2);
% white noise signal,

s=filter(Pwz,Pwp,x3);
Yd=awgn(s,30);
% primary path design
ctrl_len=30;
Cx=zeros(1,ctrl_len);       
Cw=zeros(1,ctrl_len);     
Sx=zeros(size(S_P));
e_cont=zeros(1,length(t)); 
Shx=zeros(1,length(S_P));   
Xhx=zeros(1,ctrl_len);   
% and apply the FxLMS algorithm
mu=0.001;         
vw=zeros(1,ctrl_len);
g=0.9;
c=0.999;
for k=1:length(t)                       
    Cx=[x3(k) Cx(1:end-1)];               
    Cy=Cx*Cw';                	
    Sx=[Cy; Sx(1:end-1)];   
    e_cont(k)=Yd(k)-Sx'*S_P; %filetring the secondary path 
    Shx=[x3(k) Shx(1:end-1)]; 
    S_temp=Shx*S_P;
    Xhx=[S_temp Xhx(1:end-1)];
   g=g*c;
    if dot(vw,-1*e_cont(k)*Xhx)<0
        vw= -1*mu*e_cont(k)*Xhx;
    else 
       vw= (-1*mu*e_cont(k)*Xhx)+ (g*vw);
   end
    Cw=Cw-vw;
   % Cw=Cw+mu*e_cont(k)*Xhx; 
end
   err(itr,:)=e_cont.^2;
end
m=mean(err);

figure
plot(10*log10(smooth(m,100)),'r');
ylabel('MSE');
xlabel('iteration');
legend('FXLMS MMSGD');
grid on
figure
plot(Yd) 
hold on 
plot(e_cont, 'r:')
ylabel('Amplitude');
xlabel('Discrete time k');

legend('Noise signal', 'Control signal')

