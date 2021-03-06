/*
 * Find_features.cpp
 *
 *  Created on: Dec 15, 2010
 *      Author: Stefano Cadario, Luca Cavazzana
 *
 */

//#define _DEBUG 1

#include <iostream>
#include <cstdlib>
#include <string>
#include <cctype>
#include <sstream>

#include "getopt.h"
#include "stdio.h"

#include "IAS_features.h"
#include "matlabfunctions.h"


using namespace cv;
using namespace std;


// convert into real the number. Returns 0 if not a number.
double checkTime(char *timeCh) {
	return atof(timeCh);
}

int checkNum(char *in){
	return atoi(in);
}


// return the position of the mark. -1 if filename is not in the form name####.ext
int checkFile(string str) {
	int pos_mark;

	// Check for mark position
	if((pos_mark = str.rfind('.',string::npos))<4)
		return -1;

	if(!isdigit(str.at(pos_mark-1))||!isdigit(str[pos_mark-2])||!isdigit(str[pos_mark-3])||!isdigit(str[pos_mark-4]))
		return -1;

	return pos_mark;
}

int main (int argc, char **argv) {

	bool verbose = false;
	string folder, firstImage, outFile;
	char *inTime = NULL;
	char *inNum;
	double time=0;
	vector<string> vectPathImages;


	// handle parameters --------------------
	if (argc == 2 && (
			!strcmp(argv[1],"help") ||
			!strcmp(argv[1],"-h") ||
			!strcmp(argv[1],"--help"))) {

		std::cout << "usage "<< argv[0] <<": -f <folder_pat> -i <first_image_name> -n <number_images> [-t <time_period>] [-o <output>]" << std::endl << std::endl;
		std::cout << "-f          : image folder path" << endl;
		std::cout << "-h | --help : print help" << endl;
		std::cout << "-i          : first image name" << endl;
		std::cout << "-n          : number of images" << endl;
		std::cout << "-o          : optional, number of image to analyze" << endl;
		std::cout << "-t          : optional, time between images" << endl;
		std::cout << "-v          : verbose mode, shows infos and images" << endl;
		return 0;
	}



	if (argc < 7) {
		std::cout << "usage "<< argv[0] <<": -f <folder_pat> -i <first_image_name> -n <number_images> [-t <time_period>] [-o <output>]" << std::endl;
		std::cout << "write iaasfog help for more info" << std::endl;
		exit(1);
	} else {
		int c;
		bool err = false;

		while ((c = getopt (argc, argv, "f:i:n:o:t:v")) != -1) {
			switch(c) {
			case 'f':
				folder = string(optarg);
				break;
			case 'i':
				firstImage = string(optarg);
				break;
			case 'n':
				inNum = optarg;
				break;
			case 'o':
				outFile = string(optarg);
				break;
			case 't':
				inTime = optarg;
				break;
			case 'v':
				verbose = true;
				break;
			case '?':
				if (optopt=='f'||optopt=='i'||optopt=='n'||optopt=='o'||optopt=='t')
					printf("- ERROR: parameter %c requires an argument\n",optopt);
				else
					printf("- ERROR: unknown parameter %c\n",optopt);
				err = true;
				break;
			default:
				std::cout << "- ERROR: cannot handle arguments" << std::endl;
				exit(1);
			}
		}
		if (err)
			exit(1);
	}
	//-------------------------------------

	// Check mandatory parameters
	// Check folder path parameter
	if (!folder.size()){
		std::cout << "- ERROR: missing folder path parameter (-f)" << std::endl;
		exit(-1);
	} // TODO: check folder existence too

	// Check image name paramater
	if (!firstImage.size()){
		std::cout << "- ERROR: missing first image name parameter (-i)" << std::endl;
		exit(-1);
	}
	// Check filename format (and get mark position the meantime...)
	int mark_pos;
	if((mark_pos = checkFile(firstImage))==-1) {
		std::cout << "- Error: filename must be in the form <name>####.ext" << std::endl;
		exit(1);
	}

	// Check time. Must be positive real. =0 if not a number.
	if(inTime) {
		if((time=checkTime(inTime))<=0) {
			std::cout << "- Error: time parameter (-t) needed to be positive real" << std::endl;
			exit(1);
		}
	}

	// Check and parse img number
	int n;
	if ((n=checkNum(inNum))<2) {
		std::cout << "- ERROR: image number parameter (-n) needed to be an integer greater than 2" << std::endl;
		exit(-1);
	}


	// Check the output file. Use default name if not inserted
	if (!outFile.size()){
		outFile = "fileFeatures.txt";
	} // TODO: check folder existence too

	int start = atoi(firstImage.substr(mark_pos-4,4).c_str()); // in case the series doesn't start at img 0000
	vectPathImages.push_back(folder + "/" + firstImage);
	// TODO: check image exists

#ifdef _DEBUG
	std::cout << vectPathImages.back() << std::endl;
#endif //_DEBUG

	// recreate the path every image (supposing a sequential numbering)
	for(int i=1; i<n;i++){
		stringstream ss;
		ss <<  start+i;
		vectPathImages.push_back(folder + "/" + firstImage.substr(0,mark_pos-ss.str().size()) + ss.str() +  firstImage.substr(mark_pos,firstImage.length()));
#ifdef _DEBUG
		std::cout << vectPathImages.back() << std::endl;
#endif
		// TODO: check image exists
	}

	try {
		FindFeatures(vectPathImages, outFile, verbose);
	} catch (cv::Exception e){
		if (e.code == -5) {
			std::cout << "- ERROR: no features was present all images, try with a smaller set" << std::endl;
			exit(-5);
		}
	}

#ifdef _ALG

/*	TODO: maybe in the future is better to write a version of find_features
 * 	that that returns directly the features vector without using the file
 */
	vector<vector<vector<double> > > feat_coord;
	vector<double> vp;
	Extract_features_file(outFile,&feat_coord,&vp);

	switch (_ALG){
	case 1:
		std::cout << fogLevel(&vp, &vectPathImages[0], &vectPathImages[1],true) << std::endl;
		break;
	}

#endif // _ALG

	return 0;
}
