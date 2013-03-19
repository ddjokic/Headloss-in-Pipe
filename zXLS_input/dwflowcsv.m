#!/usr/bin/env octave -q

## Headloss Curve, calculated by Darcy-Weisbach  - csv input
## for input use xls/ods file given as template

filename=input("Input file name:  ", 's');
LineTag=filename;

#reading input file
viscosity=dlmread(filename, ',', 'C1:D1');
kfact=dlmread(filename, ',', 'C10:C27');
numLL=dlmread(filename, ',', 'D10:M27');
pipID=dlmread(filename, ',', 'D5:M5');
rough=dlmread(filename, ',', 'D6:M6');
othID=dlmread(filename, ',', 'D7:M7');
pipLen=dlmread(filename, ',', 'D8:M8');
stahead=dlmread(filename, ',', 'D9:M9');
numContr=dlmread(filename, ',', 'D28:M28');
numEnl=dlmread(filename, ',', 'D29:M29');
kuser=dlmread(filename, ',', 'D30:M30');

#Enlargment/Contraction losses
IDFact=pipID/othID;
Kcon=(1-(IDFact.**2)).**2;
Kenl=(1-(1/(IDFact.**2))).**2;
lossEnlrg=Kenl*numEnl;
lossContr=Kcon*numContr;

#local loss calculation
lloss=kfact.*numLL;
#adding user and enlargement/contraction losses
lloss1=[lloss;lossEnlrg];
llos2=[lloss1;lossContr];
localloss=[llos2;kuser];
# total local loss
totlloss=sum(localloss);
Klocal=totlloss(1);

PipeIDmm=pipID(1);
Viscosity_cSt=viscosity(1);
Roughness_mm=rough(1);
pipeLen_m=pipLen(1);         
statHead_m=stahead(1);

for Flow=0.00001:600;
  velocity_mps=(4*Flow/3600)/(3.14*(PipeIDmm/1000).**2); #units m/s;
  reynolds=velocity_mps*(PipeIDmm/1000)/(Viscosity_cSt/1000000); #no units
  if reynolds<=4000
    fcoef=64/reynolds;
    
  ##colebrook
   else coleFun=@(fcoef)1.14-2*log10(Roughness_mm/PipeIDmm+9.35/(reynolds*fcoef**0.5))-1/(fcoef**.5);
   ##initial guess - colebrook
   fi=1/(1.8*log10(6.9/reynolds + ((Roughness_mm/PipeIDmm)/3.7)^1.11)).**2;
   #dfTol=5e-6
   fcoef=fzero(coleFun, fi);
   end  #if
end #for

Flow=0.00001:600;
velocity_mps=(4*Flow/3600)/(3.14*(PipeIDmm/1000).**2); #units m/s;
reynolds=velocity_mps*(PipeIDmm/1000)/(Viscosity_cSt/1000000);
#Head loss as funct. of flow 
HeadLoss=(fcoef*(pipeLen_m*1000/PipeIDmm)+Klocal)*velocity_mps.**2/(2*9.81)+statHead_m;
p1=polyfit(Flow,reynolds,1);
Re=polyval(p1,Flow);
p2=polyfit(Flow, velocity_mps, 2);
veloc=polyval(p2,Flow);
p3=polyfit(Flow,HeadLoss, 2);
Headl=polyval(p3,Flow);
#Q=linespace(0:Flow_cumph);
#creating filenames based on input file

fileReynoldsdxf=strcat("rey-", LineTag, ".dxf");
fileReynoldspng=strcat("rey-", LineTag, ".png");
fileVelocitydxf=strcat("velocity-", LineTag, ".dxf");
fileVelocitypng=strcat("velocity-", LineTag, ".png");
fileHeadlossdxf=strcat("headloss-",LineTag, ".dxf");
fileHeadlosspng=strcat("headloss-",LineTag, ".png");

#ploting graphs
plot(Flow,HeadLoss, 'm-')
xlabel ('Flow [cum/h]')
ylabel ('Headloss [m]')
titleH=strcat(LineTag, " Headloss as f(Q)");
title(titleH)
print(fileHeadlossdxf, '-ddxf')
print(fileHeadlosspng, '-dpng')
plot (Flow, reynolds,'g-')
xlabel ('Flow [cum/h]')
ylabel ('Reynolds [-]')
titleRe=strcat(LineTag, " Reynold Number=f(Flow)");
title(titleRe)
print(fileReynoldsdxf, '-ddxf')
print(fileReynoldspng,'-dpng')
plot (Flow, velocity_mps,'r-.')
xlabel ('Flow [cum/h]')
ylabel ('Velocity [m/s]')
titleV=strcat(LineTag, " Velocity[m/s]=f(Flow)");
title(titleV)
print(fileVelocitydxf,'-ddxf')
print(fileVelocitypng,'-dpng')

#printing results to input file
fid=fopen(filename, "a");
fprintf(fid, "\n \n******* \nCalculation Results \n \nTotal Local Losses=%f", Klocal);
fprintf(fid, "\nReynolds=%f *Q + %f \nVelocity= %f *Q**2 +%f *Q+ %f \nHeadloss= %f *Q**2+ %f *Q +%f", p1(1), p1(2),p2(1),p2(2),p2(3), p3(1),p3(2),p3(3));
fclose(fid)