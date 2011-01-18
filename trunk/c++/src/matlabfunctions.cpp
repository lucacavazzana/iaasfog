/*
 * Matlabfunctions.cpp
 *
 *  Created on: Dec 17, 2010
 *      Author: Stedano Cadario, Luca Cavazzana
 */

#include "matlabfunctions.h"

double fogLevel(std::vector<double> *van_p, std::string *im1, std::string *im2, bool showPlot){

	double fogLevel;

	int lev1 = zoneHom(van_p, im1, showPlot);
	int lev2 = zoneHom(van_p, im2, showPlot);

/*	returns the average if both homogeneous, if only is homogeneous returns it,
 * 	-1 if neither of them is homogeneous
 */
	if (lev1!=-1 && lev2!=-1)
		return (lev1+lev2)/2;
	else if (lev1==-1)
		return lev2;
	else
		return lev1;
}


double zoneHom(std::vector<double> *van_p, std::string *im, bool showPlot){

	// Normalizing
	van_p->at(0) = van_p->at(0)/van_p->at(2); van_p->at(1) = van_p->at(1)/van_p->at(2);

	IplImage *img = 	cvLoadImage(im->c_str(), CV_LOAD_IMAGE_GRAYSCALE);
	int img_h = img->height, img_w = img->width;

	int x = round(van_p->at(0)), y = round(van_p->at(1));
	// TODO: remember to check if the parameters h/w are in the right place
	cvSetImageROI(img, cvRect(max(0,x-WINDOW/2),max(0,y-WINDOW/2),min(WINDOW,img_w-x),min(WINDOW/2,img_h-y)));

	// having set ROI, only the sub-image will be considered (that's how opencv works)
	IplImage *vp_img = cvCreateImage(cvGetSize(img), img->depth, img->nChannels);
	cvCanny(img, vp_img, CANNY_LOW_T, CANNY_HIGH_T, 3);
	cvResetImageROI(img);

	removeIsolate(vp_img);

//	cvNamedWindow("lol", CV_WINDOW_AUTOSIZE);
//	cvShowImage("lol", vp_img);
//	cvWaitKey(0);


	return -1;
}

void removeIsolate(IplImage *img){
	std::vector<vector <int> > isolated;

	cout << img->width << " " << img->height << endl;

	for (int i=0; i<img->height; i++){
		for (int j=0; j<img->width; j++)
			cout << cvGet2D(img,j,i).val[0] << " ";
		cout << endl;
	}

	return;
}
