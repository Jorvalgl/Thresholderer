/* 
    ThresholdererFilters is an ImageJ macro developed to check the filters applied by the imageJ macro Thresholderer,
    Copyright (C) 2026  Jorge Valero Gómez-Lobo.

  ThresholdererFilters is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    ThresholdererFilters is distributed in the hope that it will be useful,
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
Dialog.addMessage("ThresholdererFilters  Copyright (C) 2015 Jorge Valero Gomez-Lobo.");
Dialog.setInsets(10, 20, 0);
Dialog.addMessage("ThresholdererFilters comes with ABSOLUTELY NO WARRANTY; click on help button for details.");
Dialog.setInsets(0, 20, 0);
Dialog.addMessage("This is free software, and you are welcome to redistribute it under certain conditions; click on help button for details.");
Dialog.addHelp("http://www.gnu.org/licenses/gpl.html");
Dialog.show();	


//Folder selection

Dialog.create("General Menu");
Dialog.addCheckbox("Select a folder with the images to test", false);
Dialog.addString("Images folder name", "Images");
Dialog.addNumber("Number of random images analyzed per folder (if no test folder selected)", 1);
Dialog.addNumber("Channel to analyze", 1);
Dialog.show();

testFold=Dialog.getCheckbox();
foldName=Dialog.getString();
imPerfolder=Dialog.getNumber();
Chann=Dialog.getNumber();

dir=getDirectory("Select the General directory or the folder containing the images directory");
if (testFold==true) Arrparam=openFromFolder();
else {
	Arrparam=openFromGeneral();
}


function openFromGeneral(){
	//folders and images data collection
	grouplist=getFileList(dir);
	ngroups=grouplist.length;
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

	//Secuential analysis of images of each n and each group
	
	for (i=0; i<ngroups; i++){
		dirgroup=dir+groupdirs[i];
		nlist=getFileList(dirgroup);
		nns=nlist.length;
		ArrRNDnList=ArRandomizer(nns);
		Arrparam=newArray(false, true, 1, 10, false, 50, true, 1, 50, false, true);
		for (ii=0; ii<nns; ii++){
			dirn=dirgroup+nlist[ArrRNDnList[ii]];
			nname=substring(nlist[ArrRNDnList[ii]], 0, lengthOf(nlist[ArrRNDnList[ii]])-1);
			dirImage=dirn+foldName+"/";
			imageList=getFileList(dirImage);
			
			ArrRND=ArRandomizer(imageList.length);
			for (iii=0; iii<imPerfolder; iii++){
			name=imageList[ArrRND[iii]];
			
			//Open image
			if (endsWith(name, ".tiff") || endsWith(name, ".tif")) open(dirImage+name);
			else run("Bio-Formats Importer", "open=["+dirImage+name+"] color_mode=Grayscale open_files view=Hyperstack stack_order=XYCZT");
			winName2=getTitle();
			Arrparam=work(Arrparam);
			}
		}
	}
}

function openFromFolder(){
	arrImages=getFileList(dir+foldName+"/");
	Arrparam=newArray(false, true, 1, 10, false, 50, true, 1, 50, false, true);
	for (i=0; i<arrImages.length; i++){
		name=arrImages[i];
		if (endsWith(name, ".tiff") || endsWith(name, ".tif")) open(dir+foldName+"/"+name);
		else run("Bio-Formats Importer", "open=["+dir+foldName+"/"+name+"] color_mode=Grayscale open_files view=Hyperstack stack_order=XYCZT");
		winName2=getTitle();
		Arrparam=work(Arrparam);
	}
	
	
}

function work(Arrparam){
	cont=false;
	counter=0;
	
	do{
		counter++;
		print("Test "+counter);
		print("");
		
		//Dialog
		Dialog.create("MULTI THRESHOLD DIALOG");
		Dialog.addCheckbox("Convert to 8 bits", Arrparam[0]);
		Dialog.addCheckbox("Remove outliers", Arrparam[1]);
		Dialog.addNumber("Radius", Arrparam[2]);
		Dialog.addNumber("Threshold", Arrparam[3]);
		Dialog.addCheckbox("Subtract background", Arrparam[4]);
		Dialog.addNumber("Rolling ball radius (pixels)", Arrparam[5]);
		Dialog.addCheckbox("Dif. of Gaussians", Arrparam[6]);
		Dialog.addNumber("Min Sigma ", Arrparam[7]);
		Dialog.addNumber("Max Sigma ", Arrparam[8]);
		Dialog.addCheckbox("Dif. of Gaussians first?", Arrparam[9]);
		Dialog.addMessage("");
		Dialog.addCheckbox("Show Max. projection?", Arrparam[10]);
		Dialog.show();
			
		convert=Dialog.getCheckbox();
		Arrparam[0]=convert;
		print("Convert to 8 bits: "+convert);
		
		Oul=Dialog.getCheckbox();
		Arrparam[1]=Oul;
		print("Remove outlier: "+Oul);
		
		radOuL=Dialog.getNumber();
		Arrparam[2]=radOuL;
		print("Remove outlier radius: "+radOuL);
		
		ThOuL=Dialog.getNumber();
		Arrparam[3]=ThOuL;
		print("Remove outlier threshold: "+ThOuL);
		
		bacsub=Dialog.getCheckbox();
		Arrparam[4]=bacsub;
		print ("Subtract background: "+bacsub);
		
		rolling=Dialog.getNumber();
		Arrparam[5]=rolling;
		print("Rolling ball radius (pixels): "+rolling);
		
		difgauss=Dialog.getCheckbox();
		Arrparam[6]=difgauss;
		print("Dif. of Gaussians: "+difgauss);
		
		minsigma=Dialog.getNumber();
		Arrparam[7]=minsigma;
		print("Min Sigma: "+minsigma);
		
		maxsigma=Dialog.getNumber();
		Arrparam[8]=maxsigma;
		print("Max Sigma: "+maxsigma);  
		
		firstgaus=Dialog.getCheckbox();
		Arrparam[9]=firstgaus;
		print("Dif. of Gaussinas first? "+firstgaus);
		
		maxProj=Dialog.getCheckbox();
		Arrparam[10]=maxProj;
		
		//Channel duplication
		
		selectWindow(winName2);
		run("Duplicate...", "title=ChannelDup_"+counter+" duplicate channels="+Chann);
		
		//Filters application
		selectWindow("ChannelDup_"+counter);
		
		//Remove outlier filter
		if (Oul==true) run("Remove Outliers...", "radius="+radOuL+" threshold="+ThOuL+" which=Bright stack");
		
		//8 bits conversion
		if (convert==true) {
			run("Conversions...", "scale");
			run("8-bit");
		}
		
		//DoG and Subtract background filters
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
		
		//Maximum projection
		if (maxProj==true) run("Z Project...", "projection=[Max Intensity]");
		
		run("Tile");
		//Image checking
		waitForUser("Check whatever you want to check");
		
		//Finish or continue
		cont=getBoolean("Do you want to check this image with other parameters?");
		
	}while (cont==true);
	
	selectWindow("Log");
	waitForUser("Click OK to go to next image");
	closeTodo();
	arrFin=Array.copy(Arrparam);
	return arrFin;
}





//This function does the difference of gaussinas filter (DoG)

function difgaussian(min, max){
	run("Duplicate...", "title=mini duplicate");
	run("Gaussian Blur...", "sigma="+min+" stack");
	run("Duplicate...", "title=maxi duplicate");
	run("Gaussian Blur...", "sigma="+max+" stack");

	imageCalculator("Subtract stack", "mini","maxi");
	selectWindow("maxi");
	close();
	selectWindow("ChannelDup_"+counter);
	close();
	selectWindow("mini");
	rename("ChannelDup_"+counter);
}

//Function that closes all windows
function closeTodo(){
	list = getList("window.titles");
     for (i=0; i<list.length; i++){
	     winame = list[i]; 
	     selectWindow(winame);
	     run("Close");
     }
    run("Close All");
}



//Random numbers array generator

function ArRandomizer(elements){
	arr=Array.getSequence(elements);
	arr2=newArray(elements);
	for(i=0; i<elements; i++){
		rndNumber=(round(random*(arr.length-1)));
		arr2[i]=arr[rndNumber];
		arr=Array.deleteValue(arr, arr[rndNumber]);
	}
	return arr2;
}