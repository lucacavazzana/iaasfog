/*
 * Matlabfunctions.h
 *
 *  Created on: Dec 17, 2010
 *      Author: Stefano Cadario, Luca Cavazzana
 */

#ifndef MATLABFUNCTIONS_H_
#define MATLABFUNCTIONS_H_

#include <iostream>
#include <vector>
#include <string>
//#include <sstream>
//#include <math.h>
#include "opencv/cv.h"
#include "opencv/highgui.h"

// Canny parameters
#define CANNY_LOW_T 0.89
#define CANNY_HIGH_T 0.9
#define CANNY_SIGMA 0.3
// Window edge size
#define WINDOW 20

/*Return the level of gray associated to the fog. The level is calculated if at least one of the input images
 *is considered homogeneus, otherwise the output is set to -1.
 *Parameters:
 *		van_p:		vanishing point;
 *		im1:		path of the first image considered;
 *		im2:		path of the second image considered;
 *		showPlot:	if true matlab plots are shown.
 */
double fogLevel(std::vector<double> *van_p, std::string *im1, std::string *im2, bool showPlot);


/*If the nXn square centered in 'van_p' is homogeneus return the level associated to it, otherwise return -1.
 *The zone is considered homogeneus if don't have edges. The edges are found using Canny.
 *Parameters:
 *		van_p:		vanishing point of the direction of translation;
 *		im:			path of the image;
 *		n:			side of the square;
 *		low_t:		lower threshold;
 *		high_t:		higher threshold;
 *		sigma:		standard deviation;
 *		showPlot:	if true matlab plots are shown.
 */
double zoneHom(std::vector<double> *van_p, std::string *im, bool showPlot);

void removeIsolate(IplImage *img);

#endif /* _MATLABFUNCTIONS_H_ */
