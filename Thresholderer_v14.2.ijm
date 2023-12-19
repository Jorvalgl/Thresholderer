/* 
    Thresholderer is an ImageJ macro developed to analyze different parameters
    at consecutive threshold levels,
    Copyright (C) 2015  Jorge Valero Gómez-Lobo.

   Thresholderer is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Thresholderer is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

//This macro has been developed by Dr Jorge Valero (jorge.valero@achucarro.org). 
//If you have any doubt about how to use it, please contact me.

//License
Dialog.create("GNU GPL License");
Dialog.addMessage(" Thresholderer  Copyright (C) 2015 Jorge Valero Gomez-Lobo.");
Dialog.setInsets(10, 20, 0);
Dialog.addMessage(" Thresholderer comes with ABSOLUTELY NO WARRANTY; click on help button for details.");
Dialog.setInsets(0, 20, 0);
Dialog.addMessage("This is free software, and you are welcome to redistribute it under certain conditions; click on help button for details.");
Dialog.addHelp("http://www.gnu.org/licenses/gpl.html");
Dialog.show();



//These are global variables;
var infovar=0;
var max=0;
var grouposition=newArray();

tresreal=false;
cincoreal=false;

roiManager("reset");
closeTodo();

setBatchMode(false);
//array containig plots colours;
colores=newArray("blue", "red", "green", "orange", "pink", "magenta", "black", "gray", "darkGray", "lightGray", "cyan", "yellow");

dir=getDirectory("Please, select the folder containing group, n and image folders");

//Get info to open first image;
print("\\Update:Getting info from images allocated at: "+dir);
grouplist=getFileList(dir);
ngroups=grouplist.length;
print(ngroups);
if (File.exists(dir+"General_Results")) ngroups--;
groupositiontemp=newArray(ngroups);
grouposition=Array.concat(grouposition, groupositiontemp);
groupdirs=newArray(ngroups);
count=0;
for (i=0; i<grouplist.length; i++){
	if (grouplist[i]!="General_Results/"){
		groupdirs[count]=grouplist[i];
		count++;
	}
}
if (grouplist[0]!="General_Results/") dirgroup=dir+grouplist[0];
else dirgroup=dir+grouplist[1];
nlist=getFileList(dirgroup);
dirn=dirgroup+nlist[0];
dirImage1=File.openDialog("Please, select an image as a reference to check dimensions and channel");
if (endsWith(dirImage1, ".tiff") || endsWith(dirImage1, ".tif")) open(dirImage1);
else run("Bio-Formats Importer", "open=["+dirImage1"] color_mode=Grayscale open_files view=Hyperstack stack_order=XYCZT");
inimiage=getTitle();
profundidad=pow(2,bitDepth());
getDimensions(width, height, channels, slices, frames);
getStatistics(area, mean, min, max, std, histogram);
chanArr=newArray(channels);
for (i=0; i<channels; i++) chanArr[i]=""+i+1+"";

waitForUser("Please, check the number of the channel you want to analyze");


//Arrays for Dialog
choice=newArray("Yes", "No");
measurements=newArray("Area fraction", "Mean Intensity", "Integrated Density", "Integrated Density/total Area", "RawIntDensity", "RawIntDensity/total pixels");
measdef=newArray(true, false, false, false, false, false);

//Dialog
Dialog.create("MULTI THRESHOLD DIALOG");
Dialog.addCheckbox("See images while running", false);
Dialog.addString("Images folder name", "Images");
Dialog.addCheckbox("Convert to 8 bits", false);
Dialog.addCheckbox("All slices", false);
Dialog.addSlider("Initial slice", 1, slices, 1);
Dialog.addSlider("Final slice", 1, slices, slices);
Dialog.addRadioButtonGroup("Channel", chanArr, 1, chanArr.length, "1");
Dialog.addCheckbox("Subtract background", true);
Dialog.addNumber("Rolling ball radius (pixels)", 50);
Dialog.addCheckbox("Dif. of Gaussians", true);
Dialog.addNumber("Min Sigma ", 0);
Dialog.addNumber("Max Sigma ", 50);
Dialog.addCheckbox("Dif. of Gaussians first?", true);
Dialog.addCheckbox("Use ROIs", false);
Dialog.addString("Name of ROIs folder", "ROIs");
Dialog.addCheckbox("Info of each single ROI", false);
Dialog.addCheckbox("Preserve ROIs stack positions",false);
Dialog.addCheckbox("Invert ROIs", false);
Dialog.addNumber("Initial threshold", 0);
Dialog.addNumber("Last threshold (must be greater than the initial one)", profundidad-1);
Dialog.addNumber("Threshold step", 1);
Dialog.setInsets(10, 10, 0);
Dialog.addMessage("Measurements");
Dialog.setInsets(-5, 10, 0);
Dialog.addMessage("(If no one is selected, area fraction will be analyzed by default)");
Dialog.setInsets(0, 10, 0);
Dialog.addCheckboxGroup(2, 3, measurements, measdef);
Dialog.addCheckbox("Invert image",true);
Dialog.show();

if (isOpen("Log")) {
	selectWindow("Log");
	run("Close");
}
//Taking options form the dialog
see=Dialog.getCheckbox();
print ("See images while running: "+see);

folderImages2=Dialog.getString();
folderImages=folderImages2+"/";
print("Images folder: "+folderImages);
convert=Dialog.getCheckbox();
print("Convert to 8 bits: "+convert);
allslice=Dialog.getCheckbox();
print("All slices: "+allslice);
initialslice=Dialog.getNumber();
print("Initial slice: "+initialslice);
finalslice=Dialog.getNumber();
print("Final slice: "+finalslice);
canal=parseFloat(Dialog.getRadioButton());
print("Channel: "+canal);
bacsub=Dialog.getCheckbox();
print ("Subtract background: "+bacsub);
rolling=Dialog.getNumber();
print("Rolling ball radius (pixels): "+rolling);
difgauss=Dialog.getCheckbox();
print("Dif. of Gaussians: "+difgauss);
minsigma=Dialog.getNumber();
print("Min Sigma: "+minsigma);
maxsigma=Dialog.getNumber();
print("Max Sigma: "+maxsigma);  
firstgaus=Dialog.getCheckbox();
print("Dif. of Gaussinas first? "+firstgaus);
roiuse=Dialog.getCheckbox();
print("Use ROIs: "+roiuse);
folderRois2=Dialog.getString();
if (roiuse==false) folderRois2="";
folderRois=folderRois2+"/";
print("Name of ROIs folder: "+folderRois);
eachRoi=Dialog.getCheckbox();
print("Info of each ROI: "+eachRoi);
stackPosition=Dialog.getCheckbox();
print("Preserve ROIs stack positions: "+stackPosition);
invertroi=Dialog.getCheckbox();
print("Invert ROIs: "+invertroi);
INIthres=Dialog.getNumber();
print("Initial threshold: "+INIthres);
LASTthres=Dialog.getNumber();
if (convert==true && LASTthres>255) LASTthres=255;
print("Last threshold: "+LASTthres);
if (LASTthres<=INIthres) exit("Last threshold must be greater than the initial one");
step=Dialog.getNumber();
if (step<=0) step=1;
print("Threshold step: "+step);


if (Dialog.getCheckbox()==true) uno="area_fraction "; 
else uno=""; 
if (Dialog.getCheckbox()==true){
	dos="mean ";
}
else dos=""; 
if (Dialog.getCheckbox()==true){
	tres="integrated ";
	tresreal=true;
}
else tres="";
if (Dialog.getCheckbox()==true){
	tres="integrated ";
	cuatro="area divided";
}
else cuatro="";
if (Dialog.getCheckbox()==true){
	tres="integrated ";
	cinco="raw";
	cincoreal=true;
}
else cinco="";
if (Dialog.getCheckbox()==true){
	tres="integrated ";
	cinco="raw";
	seis="pixel divided";
}
else seis="";
if (uno=="" && dos=="" && tres=="") uno="area_fraction ";
inversion=Dialog.getCheckbox();
print("Invert image: "+inversion);
selectWindow(inimiage);
close();

if (see!=true) setBatchMode(true);

dirRes=dir+"General_Results/";
if (File.exists(dirRes)==false) File.makeDirectory(dirRes);
selectWindow("Log");
saveAs("Text", dir+"General_Results/"+folderImages2+"_"+folderRois2+"_ThresholdererParam.txt");
selectWindow("Log");
run("Close");

run("Set Measurements...", "area integrated limit redirect=None decimal=3");

Dialog.create("Group identification");
for (i=0; i<ngroups; i++) Dialog.addString("Folder name: "+ groupdirs[i]+". Group name: ", substring(groupdirs[i], 0, lengthOf(groupdirs[i])-1) , 20);
Dialog.show();

groupnames=newArray(ngroups);
for (i=0; i<ngroups; i++) groupnames[i]=Dialog.getString();


//Secuential analysis of images of each n and each group

for (i=0; i<ngroups; i++){
	dirgroup=dir+groupdirs[i];
	groupname=groupnames[i];
	nlist=getFileList(dirgroup);
	nns=nlist.length;
	for (ii=0; ii<nns; ii++){
		dirn=dirgroup+nlist[ii];
		nname=substring(nlist[ii], 0, lengthOf(nlist[ii])-1);
		dirImage=dirn+folderImages;
		dirRois=dirn+folderRois;
		imageList=getFileList(dirImage);
			for (iii=0; iii<imageList.length; iii++){
			name=imageList[iii];
			analyze();
			run("Close All");
			}
		if (eachRoi==true && roiuse==true){
			dirRes=dirn+"Results/";
			if (File.exists(dirRes)==false) File.makeDirectory(dirRes);
			if (uno=="area_fraction ") organizeEach("ROI_Area_fraction");
			if (dos=="mean ") organizeEach("ROI_Mean_intensity");
			if (tres=="integrated "){
				if (tresreal==true) organizeEach("ROI_Integrated_density");
				if (cuatro=="area divided") organizeEach("ROI_Integrated_density_per_Area");
				if (cincoreal==true) organizeEach("ROI_RawIntegrated_density");
				if (seis=="pixel divided") organizeEach("ROI_RawIntegrated_density_per_Pix");
			}
		}
		if (imageList.length>0){
			dirRes=dirn+"Results/";
			if (File.exists(dirRes)==false) File.makeDirectory(dirRes);
			if (uno=="area_fraction ") organize("Area_fraction");
			if (dos=="mean ") organize("Mean_intensity");
			if (tres=="integrated "){
				if (tresreal==true) organize("Integrated_density");
				if (cuatro=="area divided") organize("Integrated_density_per_Area");
				if (cincoreal==true) organize("RawIntegrated_density");
				if (seis=="pixel divided") organize("RawIntegrated_density_per_Pix");
			}
		}
	}
}
dirRes=dir+"General_Results/";
groupselector();
setBatchMode(false);
if (File.exists(dirRes)==false) File.makeDirectory(dirRes);
if (uno=="area_fraction ") fin("Summary_Area_fraction");
if (dos=="mean ") fin("Summary_Mean_intensity");
if (tresreal==true) fin("Summary_Integrated_density");
if (cuatro=="area divided") fin("Summary_Integrated_density_per_Area");
if (cincoreal==true) fin("Summary_RawIntegrated_density");
if (seis=="pixel divided") fin("Summary_RawIntegrated_density_per_Pix");
if (isOpen("Results")) selectWindow("Results");
run("Close");
print("\\Update: JOB DONE");



// Function that analyze summary table to define the lines limits for each group
function groupselector(){
	print("\\Update:Analyzing groups in summary tables");
	tables=getList("window.titles");
	go=-1;
	i=0;
	while (go<0){
		if (startsWith(tables[i], "Summary")) go=i;
		i++;
	}
	selectWindow(tables[go]);
	infoSum=getInfo();
	lineSum=split(infoSum, "\n");
	count=1;
	grouposition[0]=1;
	for (i=1; i<lineSum.length; i++){
		infoTab(tables[go], i, 0);
		grouptemp=infovar;
		if (i>1){
			if (grouptemp!=groupfin) {
				grouposition[count]=i;
				count++;
			}
		}
		 groupfin=grouptemp;
	}
}

//function that saves summary tables and indicates to create plots and finally save them
function fin(tabname){
	savetab(tabname);
	plot(tabname);
	selectWindow("Plot_"+tabname);
	saveAs("Tiff", dirRes+folderImages2+"_"+folderRois2+"_"+tabname);
}

//function that creates plots
function plot(tabname){
	print("\\Update:Creating plots from "+tabname+" table");
	coltype=0;
	counter=0;
	for (i=INIthres; i<=LASTthres; i=i+step) counter++;
	X=newArray(counter);
	counter=0;
	for (i=INIthres; i<=LASTthres; i=i+step){
		X[counter]=i;
		counter++;
	}
	selectWindow(tabname);
	infotab=getInfo();
	linetab=split(infotab, "\n");
	ymax=0;
	
		
	//get maximum Y value
	for (i=1; i<linetab.length; i++){
		columntab=split(linetab[i], "\t");
		Y=Array.slice(columntab, 3, counter+3);		
		Array.getStatistics(Y, min, ymaxtemp, mean, stdDev);
		//ymaxtemp=ymaxtemp+stdDev;
		if (ymaxtemp>ymax) ymax=ymaxtemp;
	}
	
	Plot.create("Plot_"+tabname, "Threshold", ""+tabname+"");
	//Plot.setFrameSize(1024, 1024);
	Plot.setLimits(0, max, 0, ymax);
	textY=0.95;
	for (g=0; g<grouposition.length; g++){
		Y=newArray(columntab.length-3);
		Yeb=newArray(columntab.length-3);
		start=grouposition[g];
		if (g==grouposition.length-1) end=linetab.length;
		else end=grouposition[g+1];
		count=0;
		infoTab(tabname, start, 0);
		grupillo=infovar;
		for (z=3; z<Y.length+3; z++){
			countemp=0;
			Ytemp=newArray(end-start);
			for (i=start; i<end; i++){
					infoTab(tabname, i, z);
					Ytemp[countemp]=infovar;
					countemp++;
			}
			Array.getStatistics(Ytemp, Ymin, Ymax, Ymean, YstdDev);
			Y[count]=Ymean;
			Yeb[count]=YstdDev;
			count++;
		}
		Plot.setColor(colores[coltype]);
		Plot.add("line", X, Y);
		for (r=0; r<X.length; r++){
			Plot.drawLine(X[r], Y[r]-Yeb[r], X[r], Y[r]+Yeb[r]);
			Plot.drawLine(X[r]-2, Y[r]+Yeb[r], X[r]+2, Y[r]+Yeb[r]);
			Plot.drawLine(X[r]-2, Y[r]-Yeb[r], X[r]+2, Y[r]-Yeb[r]);
		}
		Plot.addText(grupillo, 0.02, textY);
		textY=textY-0.05;
		if (coltype<12) coltype++;
		else coltype=0;
	}
	Plot.show();
	
}

//function that saves n tables, indicates to create summary tables and close n tables
function organize(tablename){
	savetab(tablename);
	sumtable(tablename);
	selectWindow(tablename);
	run("Close");
}
function organizeEach(tablename){
	savetab(tablename);
	selectWindow(tablename);
	run("Close");
}

function analyze(){
	print("\\Update:Analyzing image "+name);
	if (endsWith(name, ".tiff") || endsWith(name, ".tif")) open(dirImage+name);
	else run("Bio-Formats Importer", "open=["+dirImage+name+"] color_mode=Grayscale open_files view=Hyperstack stack_order=XYCZT");
	if (convert==true) run("8-bit");
	if (inversion==true) run("Invert", "stack");
	noext=File.nameWithoutExtension;
	rename(name);
	if (channels>1){
		run("Make Composite", "display=Grayscale");
	run("Split Channels");
	for (i=1; i<=channels; i++){
		if (i!=canal){
			selectWindow("C"+i+"-"+name);
			close();
		}
	}
	selectWindow("C"+canal+"-"+name);
	rename(name);
	}
	
	if (roiuse==true){
		if (File.exists(dirRois)==false) exit("NO ROIs folder for group "+groupname+" n "+nname);
		if (File.exists(dirRois+noext+".zip")==false) print("NO detected ROI "+dirRois+noext+".zip for image "+name+" of group "+groupname+" n "+nname);
		else{
			roiManager("Open", dirRois+noext+".zip");
			roisss=roiManager("count");
			
			if (roisss>1){
				if (stackPosition==false && eachRoi==false){
					roiManager("Combine");
					roiManager("Add");
					for(z=0; z<roisss; z++){
						roiManager("Select", 0);
						roiManager("Delete");
					}
					roiManager("Select", 0);
					if (invertroi==true){
						run("Make Inverse");
						roiManager("Add");
						roiManager("Select", 0);
						roiManager("Delete");
						roiManager("Select", 0);
					}
				}
			}
			else roiManager("Select", 0);
			Thresholder();
			roiManager("Deselect");
			roiManager("Delete");
		}
	}
	else{
		run("Select All");
		Thresholder();
	}
	run("Select None");
}

//function that obtains data from different thresholds
function Thresholder(){
	run("Select None");
	selectWindow(name);
	//getStatistics(area, mean, min, max, std, histogram);
	getDimensions(width, height, channels, slices, frames);
	if (difgauss==true && bacsub==true){
		if (firstgaus==true) {
			difgaussian(minsigma, maxsigma);
			run("Subtract Background...", "rolling="+rolling+" stack");
		}
		else {
			run("Subtract Background...", "rolling="+rolling+" stack");
			difgaussian(minsigma, maxsigma);
		}
	}
	else{
		if (bacsub==true) run("Subtract Background...", "rolling="+rolling+" stack");
		if (difgauss==true) difgaussian(minsigma,maxsigma);
	}
	if (roiuse==true && stackPosition==false && eachRoi==false) roiManager("Select", 0);
	max=pow(2,bitDepth());
	counter=0;
	for (i=INIthres; i<=LASTthres; i=i+step) counter++;
	perAreaArr=newArray(counter);
	perMeanArr=newArray(counter);
	perIntArr=newArray(counter);
	perIntArrdiv=newArray(counter);
	perRawArr=newArray(counter);
	perRawArrdiv=newArray(counter);
	levelsArr=newArray(counter);
	counter=0;
	//Obtain threshold levels array
	for (i=INIthres; i<=LASTthres; i=i+step){
		levelsArr[counter]=i;
		counter++;
	}
	//Obtains sum of slice data
	if (allslice==true){
		intitialslice=1; 
		finalslice=slices;
	}
	sliceused=0;
	
	
	//Analyzing each ROI individually
	if (roiuse==true && eachRoi==true){
		//create tables
		headings=Array.concat(newArray("Image"), newArray ("ROI"), newArray("Area"), levelsArr);
		nombre=newArray(3);
		nombre[0]=name;
		numberRo=roiManager("count");
		roiManager("list");
		selectWindow("Overlay Elements of "+name);
		tableinfo=getInfo();
		Ltab=split(tableinfo, "\n");
		Ctab=split(Ltab[0], "\t");
		for (cvb=0; cvb<Ctab.length; cvb++){
			if (Ctab[cvb]=="Name") pOsName=cvb;
			if (Ctab[cvb]=="Z") pOsZ=cvb;
		}
		for(ro=0; ro<numberRo; ro++){
			RRarea=0;
			RRPixels=0;
			perAreaArr=newArray(levelsArr.length);
			perMeanArr=newArray(levelsArr.length);
			perIntArr=newArray(levelsArr.length);
			perIntArrdiv=newArray(levelsArr.length);
			perRawArr=newArray(levelsArr.length);
			perRawArrdiv=newArray(levelsArr.length);
			infoTab("Overlay Elements of "+name, ro+1, pOsName);
			nombre[1]=infovar;
			roiManager("Select", ro);
			for (st=initialslice; st<=finalslice; st++){
				counter=0; 
				if (slices>1) Stack.setSlice(st);
				if (stackPosition==true){
					infoTab("Overlay Elements of "+name, ro+1, pOsZ);
					if (infovar==st) doit=true;
					else doit=false;
				}
				else doit=true;
				if (invertroi==true) run("Make Inverse");
				if (doit==true){
					getStatistics(RRRarea, RRmean, RRmin, RRmax, RRstd, RRhistogram);
					getRawStatistics(RRRPixels, NCRRmean, NCRRmin, NCRRmax, NCRRstd, NCRRhistogram);
					RRarea=RRarea+RRRarea;
					RRPixels=RRPixels+RRRPixels;
					
					//From version 14.1 Thresholderer uses the histomgram to obtain results instead of measuring thresholds in the image
					getPixelSize(unit, pixelWidth, pixelHeight);
					setOption("BlackBackground", true);
					maxIntensity=pow(2,bitDepth());
					if (maxIntensity>256){
						getHistogram(valores, counts, maxIntensity, 0, maxIntensity-1);
						values=Array.getSequence(maxIntensity);
					}
					else getHistogram(values, counts, maxIntensity);
					AreasCounts=newArray(counts.length);
					PixelCounts=newArray(counts.length);
					MeanIntensitiesValues=newArray(counts.length);
					RawIntDenValues=newArray(counts.length);
					AreasCounts[counts.length-1]=counts[counts.length-1]*pixelWidth*pixelHeight;
					PixelCounts[counts.length-1]=counts[counts.length-1];
					MeanIntensitiesValues[counts.length-1]=values[counts.length-1];
					RawIntDenValues[counts.length-1]=counts[counts.length-1]*values[counts.length-1];
					for (i=counts.length-2; i>=0; i--){
						PixelCounts[i]=PixelCounts[i+1]+(counts[i]);
						AreasCounts[i]=PixelCounts[i]*pixelWidth*pixelHeight;
						RawIntDenValues[i]=RawIntDenValues[i+1]+(counts[i]*values[i]);
						MeanIntensitiesValues[i]=RawIntDenValues[i]/PixelCounts[i];
					}
					for (i=INIthres; i<=LASTthres; i=i+step){
						print("\\Update:Analyzing image "+name+" at threshold "+i);
						//setThreshold(i, max);
						//run("Measure");
						if (uno=="area_fraction " || dos=="mean ") perAreaArr[counter]=perAreaArr[counter]+AreasCounts[i];
						if (tres=="integrated " || dos=="mean "){
							resultado=AreasCounts[i]*MeanIntensitiesValues[i];
							if (isNaN(resultado)) resultado=0;
							perIntArr[counter]=perIntArr[counter]+resultado;
						}
						if (cinco=="raw"){
							resultado=RawIntDenValues[i];
							if (isNaN(resultado)) resultado=0;
							perRawArr[counter]=perRawArr[counter]+resultado;
						}
						//print("[Results]", "\\Clear");
						counter++;
					}
					
				}
			}
			//Obtains mean data per slice
			counter=0;
			for (i=INIthres; i<=LASTthres; i=i+step){
				if (dos=="mean "){
					if (perAreaArr[counter]==0) perMeanArr[counter]=0;
					else perMeanArr[counter]=perIntArr[counter]/perAreaArr[counter];
				}
				if (uno=="area_fraction ") perAreaArr[counter]=(perAreaArr[counter]/RRarea)*100;
				if (cuatro=="area divided") perIntArrdiv[counter]=perIntArr[counter]/RRarea;
				if (seis=="pixel divided") perRawArrdiv[counter]= perRawArr[counter]/RRPixels;
				counter++;	
			}
			nombre[2]=RRarea;
			//print tables
			if (uno=="area_fraction "){
				tablecreator("ROI_Area_fraction", headings);
				tablearray=Array.concat(nombre, perAreaArr);
				tableprinter("ROI_Area_fraction", tablearray);	
			}
			if (dos=="mean "){
				tablecreator("ROI_Mean_intensity", headings);
				tablearray=Array.concat(nombre, perMeanArr);
				tableprinter("ROI_Mean_intensity", tablearray);
			}
			if (tres=="integrated " && tresreal==true){
				tablecreator("ROI_Integrated_density", headings);
				tablearray=Array.concat(nombre, perIntArr);
				tableprinter("ROI_Integrated_density", tablearray);
			}
		
			if (cuatro=="area divided"){
				tablecreator("ROI_Integrated_density_per_Area", headings);
				tablearray=Array.concat(nombre, perIntArrdiv);
				tableprinter("ROI_Integrated_density_per_Area", tablearray);
			}
			if (cinco=="raw" && cincoreal==true){
				tablecreator("ROI_RawIntegrated_density", headings);
				tablearray=Array.concat(nombre, perRawArr);
				tableprinter("ROI_RawIntegrated_density", tablearray);
			}
			if (seis=="pixel divided"){
				tablecreator("ROI_RawIntegrated_density_per_Pix", headings);
				tablearray=Array.concat(nombre, perRawArrdiv);
				tableprinter("ROI_RawIntegrated_density_per_Pix", tablearray);
			}
		}
		if (isOpen("Overlay Elements of "+name)){
				selectWindow("Overlay Elements of "+name);
				run("Close");
		}
	}
	
	//Analysis per image
	sliceused=0;
	RRarea=0;
	RRPixels=0;
	perAreaArr=newArray(levelsArr.length);
	perMeanArr=newArray(levelsArr.length);
	perIntArr=newArray(levelsArr.length);
	perIntArrdiv=newArray(levelsArr.length);
	perRawArr=newArray(levelsArr.length);
	perRawArrdiv=newArray(levelsArr.length);
	if (roiuse==true && stackPosition==true){
		roiManager("list");
		selectWindow("Overlay Elements of "+name);
		tableinfo=getInfo();
		Ltab=split(tableinfo, "\n");
		Ctab=split(Ltab[0], "\t");
		for (cvb=0; cvb<Ctab.length; cvb++){
			if (Ctab[cvb]=="Name") pOsName=cvb;
			if (Ctab[cvb]=="Z") pOsZ=cvb;
		}
	}
	for (st=initialslice; st<=finalslice; st++){
		counter=0;
		if (slices>1) Stack.setSlice(st);
		if (roiuse==true && stackPosition==true){
			SelectR=newArray();
			SelectRtemp=newArray(1);
			for (zz=1; zz<=roisss; zz++){
				infoTab("Overlay Elements of "+name, zz, pOsZ);
				if (infovar==st){
					SelectRtemp[0]=zz-1;
					SelectR=Array.concat(SelectR, SelectRtemp);
				}
			}
			if (SelectR.length>0){
				if (SelectR.length>1){
					roiManager("Select", SelectR);
					roiManager("Combine");
					roiManager("Add");
					roiManager("Select", roisss);
				}
				if (SelectR.length==1) roiManager("Select", SelectR[0]);
				if (invertroi==true) run("Make Inverse");
			}
		}	
		
		if (roiuse==true && stackPosition==false && eachRoi==true){
			roisss2=roiManager("count");
			if (roisss2>1){
				roiManager("Deselect");
				roiManager("Combine");
				roiManager("Add");
				for(z=0; z<roisss2; z++){
					roiManager("Select", 0);
					roiManager("Delete");
				}
			}
			roiManager("Select", 0);
			if (invertroi==true){
				run("Make Inverse");
				roiManager("Add");
				roiManager("Select", 0);
				roiManager("Delete");
				roiManager("Select", 0);
			}
			getDimensions(width33, height33, channels33, slices33, frames33);
			if (slices33>1) Stack.setSlice(st);
		}
		doit=true;
		if (roiuse==true && stackPosition==true) if (SelectR.length==0) doit=false;
		if (doit==true){
			sliceused++;
			getStatistics(RRRarea, RRmean, RRmin, RRmax, RRstd, RRhistogram);
			getRawStatistics(RRRPixels, NCRRmean, NCRRmin, NCRRmax, NCRRstd, NCRRhistogram);
			RRarea=RRarea+RRRarea;
			RRPixels=RRPixels+RRRPixels;
		//From version 14.1 Thresholderer uses the histomgram to obtain results instead of measuring thresholds in the image
			getPixelSize(unit, pixelWidth, pixelHeight);
			setOption("BlackBackground", true);
			maxIntensity=pow(2,bitDepth());
			if (maxIntensity>256){
				getHistogram(valores, counts, maxIntensity, 0, maxIntensity-1);
				values=Array.getSequence(maxIntensity);
			}
			else getHistogram(values, counts, maxIntensity);
			AreasCounts=newArray(counts.length);
			PixelCounts=newArray(counts.length);
			MeanIntensitiesValues=newArray(counts.length);
			RawIntDenValues=newArray(counts.length);
			AreasCounts[counts.length-1]=counts[counts.length-1]*pixelWidth*pixelHeight;
			PixelCounts[counts.length-1]=counts[counts.length-1];
			MeanIntensitiesValues[counts.length-1]=values[counts.length-1];
			RawIntDenValues[counts.length-1]=counts[counts.length-1]*values[counts.length-1];
			for (i=counts.length-2; i>=0; i--){
				PixelCounts[i]=PixelCounts[i+1]+(counts[i]);
				AreasCounts[i]=PixelCounts[i]*pixelWidth*pixelHeight;
				RawIntDenValues[i]=RawIntDenValues[i+1]+(counts[i]*values[i]);
				MeanIntensitiesValues[i]=RawIntDenValues[i]/PixelCounts[i];
			}
			for (i=INIthres; i<=LASTthres; i=i+step){
				print("\\Update:Analyzing image "+name+" at threshold "+i);
				//setThreshold(i, max);
				//run("Measure");
				if (uno=="area_fraction " || dos=="mean ") perAreaArr[counter]=perAreaArr[counter]+AreasCounts[i];
				if (tres=="integrated " || dos=="mean "){
					resultado=AreasCounts[i]*MeanIntensitiesValues[i];
					if (isNaN(resultado)) resultado=0;
					perIntArr[counter]=perIntArr[counter]+resultado;
				}
				if (cinco=="raw"){
					resultado=RawIntDenValues[i];
					if (isNaN(resultado)) resultado=0;
					perRawArr[counter]=perRawArr[counter]+resultado;
				}
				//print("[Results]", "\\Clear");
				counter++;
			}
			
			
			/*for (i=INIthres; i<=LASTthres; i=i+step){
				print("\\Update:Analyzing image "+name+" at threshold "+i);
				setOption("BlackBackground", true);
				setThreshold(i, max);
				run("Measure");
				if (uno=="area_fraction " || dos=="mean ") perAreaArr[counter]=perAreaArr[counter]+getResult("Area", 0);
				if (tres=="integrated " || dos=="mean "){
					resultado=getResult("IntDen", 0);
					if (isNaN(resultado)) resultado=0;
					perIntArr[counter]=perIntArr[counter]+resultado;
				}
				if (cinco=="raw"){
					resultado=getResult("RawIntDen", 0);
					if (isNaN(resultado)) resultado=0;
					perRawArr[counter]=perRawArr[counter]+resultado;
				}
				print("[Results]", "\\Clear");
				counter++;
			}*/
		}
		if (roiuse==true && stackPosition==true){
			if (SelectR.length>1){
				roiManager("Select", roisss);
				roiManager("Delete");
			}
		}
	}
	if (isOpen("Overlay Elements of "+name)){
			selectWindow("Overlay Elements of "+name);
			run("Close");
	}
	//Obtains mean data per slice
	counter=0;
	for (i=INIthres; i<=LASTthres; i=i+step){
		if (dos=="mean "){
			if (perAreaArr[counter]==0) perMeanArr[counter]=0;
			else perMeanArr[counter]=perIntArr[counter]/perAreaArr[counter];
		}
		if (uno=="area_fraction ") perAreaArr[counter]=(perAreaArr[counter]/RRarea)*100;
		if (cuatro=="area divided") perIntArrdiv[counter]=perIntArr[counter]/RRarea;
		if (seis=="pixel divided") perRawArrdiv[counter]= perRawArr[counter]/RRPixels;
		counter++;	
	}

	//create tables
	headings=Array.concat(newArray("Image"), newArray("Area"), levelsArr);
	nombre=newArray(2);
	nombre[0]=name;
	nombre[1]=RRarea;
	if (uno=="area_fraction "){
		tablecreator("Area_fraction", headings);
		tablearray=Array.concat(nombre, perAreaArr);
		tableprinter("Area_fraction", tablearray);
		
	}
	if (dos=="mean "){
		tablecreator("Mean_intensity", headings);
		tablearray=Array.concat(nombre, perMeanArr);
		tableprinter("Mean_intensity", tablearray);
	}
	if (tres=="integrated " && tresreal==true){
		tablecreator("Integrated_density", headings);
		tablearray=Array.concat(nombre, perIntArr);
		tableprinter("Integrated_density", tablearray);
	}

	if (cuatro=="area divided"){
		tablecreator("Integrated_density_per_Area", headings);
		tablearray=Array.concat(nombre, perIntArrdiv);
		tableprinter("Integrated_density_per_Area", tablearray);
	}
	if (cinco=="raw" && cincoreal==true){
		tablecreator("RawIntegrated_density", headings);
		tablearray=Array.concat(nombre, perRawArr);
		tableprinter("RawIntegrated_density", tablearray);
	}
	if (seis=="pixel divided"){
		tablecreator("RawIntegrated_density_per_Pix", headings);
		tablearray=Array.concat(nombre, perRawArrdiv);
		tableprinter("RawIntegrated_density_per_Pix", tablearray);
	}			
}

function tablecreator(tabname, tablearray){
	if (isOpen(tabname)==false){
		run("New... ", "name=["+tabname+"] type=Table");
		headings=tablearray[0];
		for (i=1; i<tablearray.length; i++) headings=headings+"\t"+tablearray[i];
		print ("["+tabname+"]", "\\Headings:"+ headings);
	}
}

function tableprinter(tabname, tablearray){
	line=tablearray[0];
	for (i=1; i<tablearray.length; i++) line=line+"\t"+tablearray[i];
	print ("["+tabname+"]", line);
}

function  savetab(tablename){
		selectWindow(tablename);
		 saveAs("Text", dirRes+folderImages2+"_"+folderRois2+"_"+tablename+".xls");
	}

//function that creates summary tables
function sumtable(tablename){
	print("\\Update:Generating summary table for: "+tablename);
	selectWindow(tablename);
	tableinfo=getInfo();
	linetable=split(tableinfo, "\n");
	columntable=split(linetable[0], "\t");
	meanArray=newArray(columntable.length-1);
	if (isOpen("Summary_"+tablename)==false) {
			for (i=1; i<columntable.length; i++) meanArray[i-1]=columntable[i];
			tablearray=Array.concat(newArray("Group", "N"), meanArray);
			tablecreator("Summary_"+tablename, tablearray);	
	}
	meanArray=newArray(columntable.length-1);
	for (i=1; i<linetable.length; i++){
		columntable=split(linetable[i], "\t");
		for (ii=1; ii<columntable.length; ii++) meanArray[ii-1]=meanArray[ii-1]+columntable[ii];
	}
	for (i=0; i<meanArray.length; i++) meanArray[i]=meanArray[i]/(linetable.length-1);
	tablearray=Array.concat(newArray(groupname, nname), meanArray);
	tableprinter("Summary_"+tablename, tablearray);
}


//This function obtains info from Threshold table channel "chann" and column "column", values should be numeric

function infoTab(tablename, line, column){
	selectWindow(tablename);
	tableinfo=getInfo();
	Ltab=split(tableinfo, "\n");
	Ctab=split(Ltab[line], "\t");
	infovar=Ctab[column];
}

//This function does the difference of gaussinas filter

function difgaussian(min, max){
	run("Duplicate...", "title=mini duplicate");
	run("Gaussian Blur...", "sigma="+min+" stack");
	run("Duplicate...", "title=maxi duplicate");
	run("Gaussian Blur...", "sigma="+max+" stack");

	imageCalculator("Subtract stack", "mini","maxi");
	selectWindow("maxi");
	close();
	selectWindow(name);
	close();
	selectWindow("mini");
	rename(name);
}

function closeTodo(){
	list = getList("window.titles");
     for (i=0; i<list.length; i++){
	     winame = list[i]; 
	     selectWindow(winame);
	     run("Close");
     }
    run("Close All");
}