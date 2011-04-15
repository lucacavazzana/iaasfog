#ifndef _IAS_FEATURES_H_
#define _IAS_FEATURES_H_

#include <iostream>
#include <vector>

#include "iaas_functions/iaas.h"


/* New function
 *
 */
void nuFindFeatures(std::vector<std::string> pathImages, std::string pathOutFile, bool verb);

void printFeatures(std::string filePath, list<featureMovement> listFeatures);


/*Use the functions that are in the folder 'iaas_functions' to find features.
 *The vanishing point calculated and the features found are written in the file 'pathOutFile'.
 *To write the date the function 'Print_vp_and_features' is used.
 *	pathImages:		paths of the images to analyze;
 *	pathOutFile:	name/path of the file where to write the data found.
 */
void Find_features(std::vector<std::string> pathImages, std::string pathOutFile, bool verb);

/*Print in the file defined by the input path 'filePath' the vanishin point 'vp' and the feature detected, 
 *that are in 'a_records' in the 'num_records' images.
 */
void Print_vp_and_features(std::string filePath, int num_records, CvPoint2D32f vp, TrackRecord *a_records);

/*Extract the coordinates of features and of the vanishing point from the file 'filePath'.
 *The results are stored in 'feat_coord' and 'vp'.
 */
void Extract_features_file(std::string filePath, std::vector<std::vector<std::vector<double> > > *feat_coord, std::vector<double> *vp);


#endif //_IAS_FEATURES_H_
