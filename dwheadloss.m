#!/usr/bin/env octave -q
##Darcy-Weisbach Curve

# NOTE: Values had been initiated with working example.
#		Update those with your values!

# INPUT BLOCK

LineTag="FiFi200"
PipeIDmm=200          ##Units: mm - must be greater than '0'
Roughness_mm=0.04572  #Units:mm - must be greater than '0'
Viscosity_cSt=1.3     #Units:cSt - must be greater than '0'
Flow_cumph=400        #Units:cum/h - must be greater than '0'
OtherIDmm=250         #ID of reducer/enlarger in mm - must be greater than '0'
##-------------------------------------------------
## Head Losses
pipeLen_m=80         #pipelength in meters - must be greater than '0'
statHead_m=26         #Height difference between entrance and exit unit:m
num_90deg_el=5       #number of 90 deg standard elbows
numLR_el=0           #number of Long Radius elbows
numSR_el=0           #number of Short Radius elbows
numRetBnd=0          #number of return bends
num_45deg_el=2       #number of 45 deg standard elbows
numBtfVlv=3          #number of butterfly valves
numGtVlv=0           #number of gate valves
numAngVlv=0			 #number of angle valves
numGlVlv=0           #number of globe valves
numDuoChkVlv=0       #number of duo check valves
numSwgChkVlv=1       #number of swing check valves
numFootStdVlv=0      #number of standard footvalves
numFootPopVlv=0      #number of poppet footvalves
numTFlowHead=1		 #number of tee flow through
numTFlowBran=1       #number of tee flow branch
numPipExit=0         #number of pipe exits
numPipEntr=0         #number of pipe entances
numContraction=0     #number of flow contractions
numEnlarg=0          #number of flow enlrgements
numStrainer=0       #number of strainers
User=0                   #user defined - input as total local loss
# END OF INPUT BLOCK
# DO NOT CHANGE ANYTHING BELOW THIS LINE,if your intention is just to use script
#--------------------------------------------------


IDFact=PipeIDmm/OtherIDmm
Kcon=(1-(IDFact.**2)).**2;
Kenl=(1-(1/(IDFact.**2))).**2;
#---------------------------------------------------
#local loss computation Klocal
Klocal=num_90deg_el*0.54+numLR_el*0.6+numSR_el*0.9+numRetBnd*2.2+num_45deg_el*0.29+numBtfVlv*0.8+numGtVlv*0.15+numAngVlv*5+numGlVlv*6.5+numDuoChkVlv*0.8+numSwgChkVlv*1+numFootStdVlv*1.4+numFootPopVlv*8+numTFlowHead*0.4+numTFlowBran*1.1+numPipExit*1+numPipEntr*0.8+numContraction*Kcon+numEnlarg*Kenl+numStrainer*8.43+User;
#---------------------------------------------------
for Flow=0.001:Flow_cumph
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
   end
  end
 #Flow=0:Flow_cumph;
 Flow=0.001:Flow_cumph;
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
 #creating filenames based on tags
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
 #writing all results to one file
fileResults=strcat(LineTag, "-Results", ".txt");
fid=fopen(fileResults, "w");
fprintf(fid, "Line tag: %s", LineTag);
fclose(fid);
#input block printing
#**************************
fid=fopen(fileResults, "a");
fprintf(fid, "\nPipe ID [mm]=%f \tReduced/enlarged ID[mm]=%f \tRoughness [mm]=%f \tViscosity [cSt]=%f \tHeigh difference between entrance and exit [m]=%f",  PipeIDmm, OtherIDmm,Roughness_mm, Viscosity_cSt, statHead_m );

fprintf(fid, "\nNumber of Std 90deg Elbows =%f \nNumber of LR Elbows =%f \nNumber of SR Elbows  =%f \nNumber of Return Bends =%f \nNumber of Std 45deg Elbows =%f", num_90deg_el,numLR_el,numSR_el, numRetBnd, num_45deg_el);
fprintf(fid,"\nNumber of Butterfly Valves=%f \nNumber of Gate Valves=%f \nNumber of Angle Valves=%f \nNumber of Globe Valves=%f \nNumber of Duo Check Valves=%f, \nNumber of Swing Check Valves=%f \nNumber of Std Footvalves=%f \nNumber of Footvalves Poppet Type=%f", numBtfVlv, numGtVlv,numAngVlv, numGlVlv, numDuoChkVlv, numSwgChkVlv, numFootStdVlv, numFootPopVlv);
fprintf(fid, "\nNumber of Tees - flow through=%f \nNumber of Tees - change Flow direction=%f \nPipe exits=%f \nPipe entrances=%f, \nPipe Contractions=%f \nPipe Enlargements=%f \nStrainers=%f \nUser Defined Losses=%f", numTFlowHead, numTFlowBran, numPipExit, numPipEntr, numContraction, numEnlarg, numStrainer, User);

#results printing
fprintf(fid, "\n \n******* \nCalculation Results \n \nTotal Local Losses=%f", Klocal);
fprintf(fid, "\nReynolds: %f;%f \nVelocity: %f;%f,%f \nHeadloss: %f;%f;%f", p1(1),p1(2),p2(1),p2(2),p2(3),p3(1),p3(2),p3(3));
fprintf(fid, "\nReynolds=%f *Q + %f \nVelocity= %f *Q**2 +%f *Q+ %f \nHeadloss= %f *Q**2+ %f *Q +%f", p1(1), p1(2),p2(1),p2(2),p2(3), p3(1),p3(2),p3(3));
fclose(fid)