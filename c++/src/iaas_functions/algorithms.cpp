/**
 * @file algorithms.h
 * @author Alessandro Stranieri && Stefano Cadario, Luca Cavazzana
 * @date Feb 04, 2009
 */
#include "iaas.h"
#include <iostream>
#include <vector>

CvRect getContrFrame (CvPoint2D32f *point, IplImage *img) {
	//rounding
	int x = int(point->x+.5);
	int y = int(point->y+.5);

	return cvRect(
			max(0,x-FRAME_RADIUS),
			max(0,y-FRAME_RADIUS),
			min(FRAME_SIZE, min(img->width-x, x+1)+FRAME_RADIUS), // radius+1 + (width-1 - x) if on the right,  x + radius+1 if on the left
			min(FRAME_SIZE, min(img->height-y, y+1)+FRAME_RADIUS)
			);
}

double getRMSContrast(const IplImage *img, CvPoint2D32f *point) {

	// element out of the image
	if (point->x < 0 || point->x > img->width-1 || point->y < 0 || point->y > img->height-1) {
		//std::cout << "- invalid feat" << std::endl;
		return -1;
	}

	CvScalar avg, sdv;

	cvSetImageROI((IplImage *)img, getContrFrame(point, (IplImage*)img));
	cvAvgSdv(img, &avg, &sdv);

#ifdef _TESTING
	std::cout << "(" << point->x << "," << point->y << ") " <<
				"frame: " << img->roi->height << "x" << img->roi->width << " " <<
				"std: " << sdv.val[0] << std::endl;
	for(int yy = 0; yy < img->roi->height; yy++){
		uchar* ptr = (uchar*) img->imageData + img->widthStep*(img->roi->yOffset+yy);
		for(int xx = 0; xx < img->roi->width; xx++) {
			std::cout << (int)ptr[img->roi->xOffset + xx]  << " ";
		}
		std::cout << std::endl;
	}
	std::cout << std::endl;
#endif

	cvResetImageROI((IplImage *)img);

#ifdef _TESTING
	cvCircle((CvArr*)img, cvPoint((int)point->x,(int)point->y), 3, CV_RGB(255,0,0));
	cvNamedWindow("asd",CV_WINDOW_AUTOSIZE);
	cvShowImage("asd",img);
	cvWaitKey(0);
	cvDestroyWindow("asd");
#endif

	return sdv.val[0];
}

double getWeberContrast(const IplImage *img, CvPoint2D32f *point, CvPoint2D32f *vp) {

	// element out of the image
	if (point->x < 0 || point->x > img->width-1 || point->y < 0 || point->y > img->height-1) {
		//std::cout << "- invalid feat" << std::endl;
		return -1;
	}

	CvScalar avg;
	//CvRect rect = cvRect(max(0.0f,point->x-RECTANGLE_SIZE/2), max(0.0f,point->y-RECTANGLE_SIZE/2), min((float)RECTANGLE_SIZE, img->width-point->x+RECTANGLE_SIZE/2), min((float)RECTANGLE_SIZE, img->height-point->y+RECTANGLE_SIZE/2));

	if (vp==NULL)
		cvSetImageROI((IplImage *)img, getContrFrame(point, (IplImage*)img));
	else
		cvSetImageROI((IplImage *)img, getContrFrame(vp, (IplImage*)img));

	//TODO: test
	avg = cvAvg(img);
	cvResetImageROI((IplImage *)img);

	return abs((double)*((uchar*)img->imageData + (int)point->y*img->widthStep + (int)point->x)-avg.val[0])/avg.val[0];
}

double getMichelsonContrast(const IplImage *img, CvPoint2D32f *point) {

	// element out of the image
	if (point->x < 0 || point->x > img->width-1 || point->y < 0 || point->y > img->height-1) {
		//std::cout << "- invalid feat" << std::endl;
		return -1;
	}

	double maxV, minV;
	cvSetImageROI((IplImage *)img, getContrFrame(point, (IplImage*)img));

	cvMinMaxLoc(img, &minV, &maxV);
	cvResetImageROI((IplImage *)img);

	return (maxV-minV)/(maxV+minV);
}

bool verifyFeatureConsistency(featureMovement &feat) {
	if(feat.positions.size() > MINIMUM_LIFE) {
		// Set as undead
		feat.status = UNDEAD;

		// Correct points positions (move points in order to lie
		// on the best line fitting all points)

		CvMat line;

		iaasBestJoiningLine(&feat.positions[0], feat.positions.size(), &line);

		for(int i=1; i < feat.positions.size()-1; i++) {
			feat.positions[i] = iaasProjectPointToLine(feat.positions[i], &line);
			//cout << " " << iaasPointLineDistance(&line, feat.positions[i]) << endl;
		}

		double ratio = 0;
		double mean = 0;
		double variance = 0;

		for(int i=0; i<feat.positions.size()-4; i++) {
			ratio = getCrossRatio(&feat.positions[i]);
			//cout << ratio << " ";
			mean += ratio;
			variance += ratio*ratio;
		}
		ratio = mean/(feat.positions.size()-4);
		variance = variance/(feat.positions.size()-4);
		variance = sqrt(variance - ratio*ratio);
		// TODO: generate virtual features (computed not founded because inside fog)

		feat.ratio = ratio;
		//cout << endl;
		//cout << "Ratios: " << ratio << " " << variance << endl;
		if(ratio < CRtolleranceMin || ratio > CRtolleranceMax || variance > 0.05) {
			feat.status = DELETE;
			cout << "Delete because mean " << ratio << " or variance " << variance << endl;
			return false;
		}
		else {
			// TODO: Prolong line
			int maxAdd = feat.startFrame - feat.positions.size() + 1;
			cout << "Distance: ";
			for(int i=0; i<maxAdd; i++) {
				int lastIndex = feat.positions.size() -1;
				float newDistance;
				newDistance = getCrossRatioDistance(feat.positions[lastIndex-2],feat.positions[lastIndex-1],feat.positions[lastIndex], (4.0f/3.0f));
				cout << newDistance << " ";
				// If next point distance is below 0.5 pixel stop
				if(newDistance<0.5f)
					break;
				feat.positions.push_back(iaasPointAlongLine(&line, feat.positions[feat.positions.size()-2],feat.positions[feat.positions.size()-1], newDistance));
			}
			cout << endl;
		}
		return true;
	}
	else {
		// Too short life, drop feature
		feat.status = DELETE;
		return false;
	}
}

// Verify that the last point found is coherent with others
bool verifyNewFeatureIsOk(list<featureMovement>::iterator feat, const CvPoint2D32f newPoint, const int trackStatus) {

	bool pointOk = true;
	int nPoints = feat->positions.size();
	double distance = 0, angle = 0;

	// Check if new point is tracked correctly
	if(!trackStatus) {
		pointOk = false;
		goto endCheck;
	}

	// Check if new point is negative
	if(newPoint.x < 0 || newPoint.y < 0 || newPoint.x > FRAME_WIDTH || newPoint.y > FRAME_HEIGHT) {
		pointOk = false;
		goto endCheck;
	}

	// Get distance of two points before
	distance = iaasTwoPointsDistance(feat->positions[nPoints-2], feat->positions[nPoints-1]);

	// Check if distance from last two points is less than previous points
#ifdef REVERSE_IMAGE
	if(distance < iaasTwoPointsDistance(feat->positions[nPoints-1], newPoint)) {
#else
	if(distance > iaasTwoPointsDistance(feat->positions[nPoints-1], newPoint)) {
#endif
		pointOk = false;
		goto endCheck;
	}

	// Check angle
	CvMat line1, line2;
	iaasJoiningLine(feat->positions[nPoints-2], feat->positions[nPoints-1], &line1);
	iaasJoiningLine(feat->positions[nPoints-1], newPoint, &line2);
	angle = iaasTwoLinesAngle(&line1, &line2);
	if(angle < 0.95) {
		//cout << "angle: " << angle << endl;
		pointOk = false;
		goto endCheck;
	}

	if(nPoints > 3) {
		// Check collinearity (crossRatio)
		float crossRatio = getCrossRatio(&feat->positions[nPoints-4]);
		if(crossRatio < CRtolleranceMin || crossRatio > CRtolleranceMax) {
			pointOk = false;
			goto endCheck;
		}
	}

endCheck:

	if(!pointOk) {
		// Point not valid, check if we can keep only the previous points
		return verifyFeatureConsistency(*feat);
	}
	else {
		// New point ok, keep tracking
		return true;
	}
}

float getCrossRatio(CvPoint2D32f *points) {
	float ab = iaasTwoPointsDistance(points[0], points[1]);
	float bc = iaasTwoPointsDistance(points[1], points[2]);
	float cd = iaasTwoPointsDistance(points[2], points[3]);
	return ((ab+bc)*(bc+cd))/((bc)*(ab+bc+cd));
}

float getPointCDistance(CvPoint2D32f a, CvPoint2D32f b, CvPoint2D32f d, float crossRatio) {
	float ab = iaasTwoPointsDistance(a, b);
	float bd = iaasTwoPointsDistance(b, d);
	float bc = ab / (crossRatio*(ab+bd)/bd-1);
	return bc;
}

float getCrossRatioDistance(CvPoint2D32f a, CvPoint2D32f b, CvPoint2D32f c, float crossRatio) {
	float ab = iaasTwoPointsDistance(a, b);
	float bc = iaasTwoPointsDistance(b, c);
	float k = crossRatio*bc/(ab+bc);
	float cd = ((1.0f/3.0f)*bc)/(1-k);
	return cd;
}

void filterFeaturesTooClose(CvPoint2D32f *newPoints, int *nNewPoints, CvPoint2D32f *existingPoints, int nExistingPoints) {
	// Delete points too close to others that already exist
	int nDelete = 0;
	for(int i=0; i<(*nNewPoints); i++) {
		bool erase = false;
		// Check distance with all features already tracked
		for(int j=0; j<nExistingPoints; j++) {
			float distance = iaasTwoPointsDistance(newPoints[i],existingPoints[j]);
			if(distance < MIN_DISTANCE) {
				// Delete new feature
				erase = true;
				break;
			}
		}
		if(erase) {
			nDelete++;
		}
		else {
			// Scale element with deleted
			newPoints[i-nDelete] = newPoints[i];
		}
	}
	// Set new size of array
	*nNewPoints = *nNewPoints-nDelete;
}

/*
bool verifyValidFeature(featureMovement feat) {
	int nPoints = feat.positions.size();
	if(nPoints < MINIMUM_LIFE) {
		return false;
	}
	else {
		CvMat line;
		double ptsDistance;
		iaasJoiningLine(feat.positions[0], feat.positions[nPoints-1], &line);
		ptsDistance = iaasTwoPointsDistance(feat.positions[0], feat.positions[nPoints-1]) / 50;

		vector<CvPoint2D32f>::iterator point = feat.positions.begin() + 1;
		while(point != feat.positions.end()) {

			double distance = iaasPointLineDistance(&line, *point);

			// If distance of point is too far from line drop that feature
			if(ptsDistance < distance) {
				return false;
			}
			point++;
		}
	}
	return true;
}*/

void iaasFindAndTrackCorners(double quality_level, IplImage *imageA, IplImage *imageB, int *track_count, CvPoint2D32f *cornersA, CvPoint2D32f *cornersB, float *track_errors, char* track_status){
	//Shi-Tomasi parameters
	CvSize img_sz;
	IplImage *eig_image, *temp_image;

	double min_distance = MIN_DISTANCE;
	int block_size = BLOCK_SIZE;

	//LK parameters
	CvSize pyr_sz;
	int win_size = WIN_SIZE;
	IplImage *pyrA, *pyrB;
	int pyr_layers = PYR_LEVELS;

	//Shi-Tomasi temporary work data-structures
	img_sz = cvGetSize(imageA);
	eig_image = cvCreateImage(img_sz, IPL_DEPTH_32F, 1);
	temp_image = cvCreateImage(img_sz, IPL_DEPTH_32F, 1);

	cvGoodFeaturesToTrack(
			imageA,
			eig_image,
			temp_image,
			cornersA,
			track_count,
			quality_level,
			min_distance,
			0,
			block_size,
			0,
			0.04
	);

	//printf("Number of found features: %d\n", c_count);

	cvFindCornerSubPix(
			imageA,
			cornersA,
			*track_count,
			cvSize(win_size, win_size),
			cvSize(-1, -1),
			cvTermCriteria(CV_TERMCRIT_ITER | CV_TERMCRIT_EPS, 20, .03)
	);

	pyr_sz = cvSize(imageA->width+8, imageB->height/3);
	pyrA = cvCreateImage(pyr_sz, IPL_DEPTH_32F, 1);
	pyrB = cvCreateImage(pyr_sz, IPL_DEPTH_32F, 1);

	cvCalcOpticalFlowPyrLK(
			imageA,
			imageB,
			pyrA,
			pyrB,
			cornersA,
			cornersB,
			*track_count,
			cvSize(win_size, win_size),
			pyr_layers,
			track_status,
			track_errors,
			cvTermCriteria(CV_TERMCRIT_ITER | CV_TERMCRIT_EPS, 20, .3),
			0
	);

	//Release resources
	cvReleaseImage(&eig_image);
	cvReleaseImage(&temp_image);
	cvReleaseImage(&pyrA);
	cvReleaseImage(&pyrB);
}

void iaasFindCorners(IplImage *image, CvPoint2D32f *corners, int *corner_count, double quality) {
	//Shi-Tomasi parameters
	CvSize img_sz;
	static IplImage *eig_image, *temp_image;
	static int firstTime = 0;

	double min_distance = MIN_DISTANCE;
	int block_size = BLOCK_SIZE;

	//Sub-pixel algorithm extra parameter
	int win_size = WIN_SIZE;

	//Shi-Tomasi temporary work data-structures
	if(firstTime==0) {
		img_sz = cvGetSize(image);
		eig_image = cvCreateImage(img_sz, IPL_DEPTH_32F, 1);
		temp_image = cvCreateImage(img_sz, IPL_DEPTH_32F, 1);
	}

	cvGoodFeaturesToTrack(
		image,
		eig_image,
		temp_image,
		corners,
		corner_count,
		quality,
		min_distance,
		0,
		block_size,
		0,
		0.04
	);

	cvFindCornerSubPix(
		image,
		corners,
		*corner_count,
		cvSize(win_size, win_size),
		cvSize(-1, -1),
		cvTermCriteria(CV_TERMCRIT_ITER | CV_TERMCRIT_EPS, 20, .03)
	);
	firstTime = 1;

	//Release resources
	//cvReleaseImage(&eig_image);
	//cvReleaseImage(&temp_image);
}

void iaasTrackCorners(IplImage *imageA, IplImage *imageB, CvPoint2D32f *cornersA, CvPoint2D32f *cornersB, float *track_errors, char* track_status, int corner_count){

	//LK parameters
	int win_size = WIN_SIZE;
	int pyr_layers = PYR_LEVELS;

	cvCalcOpticalFlowPyrLK(
			imageA,
			imageB,
			NULL, //pyrA,
			NULL, //pyrB,
			cornersA,
			cornersB,
			corner_count,
			cvSize(win_size, win_size),
			pyr_layers,
			track_status,
			track_errors,
			cvTermCriteria(CV_TERMCRIT_ITER | CV_TERMCRIT_EPS, 40, .1),
			0
	);

	// Delete corners too close
	for(int i=0; i<corner_count; i++) {
		if(track_status[i]) {
			double distance =  iaasTwoPointsDistance(cornersA[i], cornersB[i]);
			if(distance<MIN_FEATURE_DISTANCE)
				track_status[i] = 0;
		}
	}
}

int iaasNumberFoundCorners(char* track_status, int num_elements){
	int num_found_corners = 0;
	for(int i = 0; i < num_elements; i++){
		if(track_status[i] == 1)
			num_found_corners++;
	}
	return num_found_corners;
}


void iaasFilterByDistance(CvPoint2D32f *cornersA, CvPoint2D32f *cornersB, int num_corners, int *status, CvPoint2D32f vanishing_point, double dist_th){
	for(int i = 0; i < num_corners; i++){
		CvMat joinLine;
		iaasJoiningLine(cornersA[i], cornersB[i], &joinLine);
		if(iaasPointLineDistance<CvPoint2D32f>(&joinLine, vanishing_point) > dist_th){
			status[i] = 0;
		}
	}
}

void iaasFilterByError(float *track_errors, char *track_status, int num_corners, float err_th){
	for(int i = 0; i < num_corners; i++){
		if(track_errors[i] > err_th){
			track_status[i] = 0;
		}
	}
}

void iaasFilterByMotionDirection(CvPoint2D32f *pointsA, CvPoint2D32f *pointsB, int num_points, char *status, CvPoint2D32f vanishing_point){
	for(int i = 0; i < num_points; i++){
		if(status[i] == 1){
			if(!iaasIsMotionCoherent(pointsA[i], pointsB[i], vanishing_point)){
				status[i] = 0;
			}
		}
	}
}

double iaasTimeToImpact(CvPoint2D32f vanishing_point, CvPoint2D32f p_t0, CvPoint2D32f p_t1){
	double time_to_impact;
	double p1_vp, p0_p1;
	CvPoint2D32f pp_t0 = iaasProjectPointToLine(vanishing_point, p_t1, p_t0);

	//Compute distances in image plane
	p1_vp = iaasTwoPointsDistance<CvPoint2D32f>(p_t1, vanishing_point);//C'A'
	p0_p1 = iaasTwoPointsDistance<CvPoint2D32f>(pp_t0, p_t1);//C'B'

	time_to_impact = p1_vp/(p0_p1*FRAME_RATE*(NUM_RECORDS-1));
	return time_to_impact;
}

double iaasMeanTimeToImpact(CvPoint2D32f vanishing_point, CvPoint2D32f *cornersA, CvPoint2D32f *cornersB, int n_corners){
	double tot_tti = 0;
	for(int i = 0; i < n_corners; i++){
		tot_tti += iaasTimeToImpact(vanishing_point, cornersA[i], cornersB[i]);
	}
	return tot_tti/n_corners;
}



CvPoint2D32f iaasEstimateVanishingPoint(CvPoint2D32f *pointsA, CvPoint2D32f *pointsB, int num_points, char *status){
	//Number of tracked corners
	int tracked_corners = iaasNumberFoundCorners(status, num_points);

	//Create set of lines from valid corners
	CvMat *joiningLines = new CvMat[tracked_corners];
	for(int i = 0, j= 0; i < num_points; i++){
		if(status[i] == 1){
			iaasJoiningLine(pointsA[i], pointsB[i], joiningLines+j);
			j++;
		}
	}

	CvPoint2D32f vp = iaasHoughMostCrossedPoint(joiningLines, tracked_corners);

	return vp;
}


CvPoint2D32f iaasHoughMostCrossedPoint(CvMat *lines, int n_lines, bool f_dist, int img_width, int img_height, int patch_size){
	CvPoint2D32f result;
	//Init data structures
	int cols = img_width / patch_size;
	int rows = img_height / patch_size;

	double **patch_votes = new double*[rows];
	int **crossing_lines = new int*[rows];
	for(int r = 0; r < rows; r++){
		patch_votes[r] = new double[cols];
		crossing_lines[r] = new int[cols];
		for(int c = 0; c < cols; c++){
			patch_votes[r][c] = 0.0;
			crossing_lines[r][c] = 0;
		}
	}

	CvPoint2D32f **patch_centres = new CvPoint2D32f*[rows];
	for(int r = 0; r < rows; r++){
		patch_centres[r] = new CvPoint2D32f[cols];
		for(int c = 0; c < cols; c++){
			double x = 2 + patch_size*c;
			double y = 2 + patch_size*r;
			patch_centres[r][c] = cvPoint2D32f(x, y);
		}
	}

	double max_distance = sqrt(2.0)*patch_size/2;
	for(int l = 0; l < n_lines; l++){
		for(int r = 0; r < rows; r++){
			for(int c = 0; c < cols; c++){
				double distance = iaasPointLineDistance(lines+l, patch_centres[r][c]);
				if(distance < max_distance){
					patch_votes[r][c] += 1 - distance/max_distance;
					crossing_lines[r][c] += 1;
				}
			}
		}
	}

	int row; int col;
	if(f_dist){
		iaasArgMaxArray2D<double>(patch_votes, rows, cols, &row, &col);
#ifdef DEBUG
		for(int r = 0; r < rows; r++){
			for(int c = 0; c < cols; c++){
				if(r == row && c == col)
					printf("[%2.0f] ", patch_votes[r][c]);
				else
					printf("%2.0f ", patch_votes[r][c]);
			}
			printf("\n");
		}
#endif
	}else{
		iaasArgMaxArray2D<int>(crossing_lines, rows, cols, &row, &col);
#ifdef DEBUG
		for(int r = 0; r < rows; r++){
			for(int c = 0; c < cols; c++){
				if(r == row && c == col)
					printf("[%2d] ", crossing_lines[r][c]);
				else
					printf("%2d ", crossing_lines[r][c]);
			}
			printf("\n");
		}
#endif
	}

	result = patch_centres[row][col];

	//Release resources
	delete patch_centres;
	delete crossing_lines;
	delete patch_votes;

	return result;
}

CvPoint2D32f iaasHoughMostCrossedPoint(CvPoint2D32f *points0, CvPoint2D32f *points1, int nPoints, bool f_dist, int img_width, int img_height, int patch_size)
{	CvPoint2D32f result;
	//Init data structures
	int cols = img_width / patch_size;
	int rows = img_height / patch_size;

	double **patch_votes = new double*[rows];
	int **crossing_lines = new int*[rows];
	for(int r = 0; r < rows; r++){
		patch_votes[r] = new double[cols];
		crossing_lines[r] = new int[cols];
		for(int c = 0; c < cols; c++){
			patch_votes[r][c] = 0.0;
			crossing_lines[r][c] = 0;
		}
	}

	CvPoint2D32f **patch_centres = new CvPoint2D32f*[rows];
	for(int r = 0; r < rows; r++){
		patch_centres[r] = new CvPoint2D32f[cols];
		for(int c = 0; c < cols; c++){
			double x = 2 + patch_size*c;
			double y = 2 + patch_size*r;
			patch_centres[r][c] = cvPoint2D32f(x, y);
		}
	}

	//Create a set of lines
	CvMat *lines = new CvMat[nPoints];
	for(int i = 0; i < nPoints; i++){
		iaasJoiningLine(points0[i], points1[i], lines+i); // set the i-th line
	}

	double max_distance = sqrt(2.0)*patch_size/2;
	for(int l = 0; l < nPoints; l++){
		for(int r = 0; r < rows; r++){
			for(int c = 0; c < cols; c++){
				double distance = iaasPointLineDistance(lines+l, patch_centres[r][c]);
				if(distance < max_distance){
					patch_votes[r][c] += 1 - distance/max_distance;
					crossing_lines[r][c] += 1;
				}
			}
		}
	}

	delete[] lines;

	int row; int col;
	if(f_dist){
		iaasArgMaxArray2D<double>(patch_votes, rows, cols, &row, &col);
	}else{
		iaasArgMaxArray2D<int>(crossing_lines, rows, cols, &row, &col);
	}
	result = patch_centres[row][col];

#ifdef _DEBUG
	for (int r=0; r<rows; r++)
		for (int c=0; c<cols; c++)
			std::cout << patch_centres[r][c].x << " " << patch_centres[r][c].y << std::endl;
	std::cout << "\n" <<  patch_centres[row][col].x << " " << patch_centres[row][col].y << std::endl;
#endif

	//Release resources
	delete patch_centres;
	delete crossing_lines;
	delete patch_votes;

	return result;
}


CvPoint2D32f iaasMinimumDistantPoint(CvPoint2D32f *points0, CvPoint2D32f *points1, int nPoints){
	//Create a set of lines
	CvMat *joinlines = new CvMat[nPoints];

	for(int i = 0; i < nPoints; i++){
		iaasJoiningLine(points0[i], points1[i], joinlines+i);
	}

	//Solution matrix
	CvMat X;
	double data_X[2];

	// Init matrix X with 2 Row, 1 Column with dataX
	cvInitMatHeader(&X, 2, 1, CV_64FC1, data_X);

	//A and B matrices
	CvMat A; 								CvMat B;
	double *data_A = new double[nPoints*2]; double *data_B = new double[nPoints];

	for(int i = 0; i < nPoints; i++){
		double *line_data = joinlines[i].data.db;
		double a = line_data[0], b = line_data[1], c = line_data[2];

		data_A[2*i] 	= a/sqrt(iaasSquare<double>(a)+iaasSquare<double>(b));
		data_A[2*i+1] 	= b/sqrt(iaasSquare<double>(a)+iaasSquare<double>(b));
		data_B[i] 		= -c/sqrt(iaasSquare<double>(a)+iaasSquare<double>(b));
	}
	cvInitMatHeader(&A, nPoints, 2, CV_64FC1, data_A);
	cvInitMatHeader(&B, nPoints, 1, CV_64FC1, data_B);

	//Solve system with Least Square Method
	cvSolve(&A, &B, &X, CV_SVD);


	if(data_X[2] == 0){
#ifdef DEBUG
		printf("Point at infinity, returning (-1, -1)\n");
#endif
		return cvPoint2D32f(-1, -1);
	}
	double x = data_X[0];
	double y = data_X[1];

	return cvPoint2D32f(x, y);
}

void iaasFilterNotInFOV(CvPoint2D32f *pointsA, CvPoint2D32f *pointsB, int num_points, char *status){
	for(int i = 0; i < num_points; i++){
		if(status[i] == 1){
			if(!(iaasPointIsInFOV(pointsA[i]) && iaasPointIsInFOV(pointsB[i]))){
				status[i] = 0;
			}
		}
	}
}

void iaasCopyFoundCorners(CvPoint2D32f *cornersA, CvPoint2D32f *cornersB, char* track_status, int n_points){
	for(int i = 0, j = 0; i < n_points; i++){
		if(track_status[i] == 1){
			cornersA[j] = cornersB[i];
			j++;
		}
	}
}
