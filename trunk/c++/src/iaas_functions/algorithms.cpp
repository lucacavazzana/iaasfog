/**
 * @file algorithms.h
 * @author Alessandro Stranieri && Stefano Cadario, Luca Cavazzana
 * @date Feb 04, 2009
 */
#include "iaas.h"
#include <iostream>
#include <vector>

double getAroundContrast(const IplImage *img, CvPoint2D32f *point) {

	IplImage *rect = cvCreateImage(cvSize(RECTANGLE_SIZE, RECTANGLE_SIZE), IPL_DEPTH_32F, 1);
	IplImage *rectDiff = cvCreateImage(cvSize(RECTANGLE_SIZE, RECTANGLE_SIZE), IPL_DEPTH_32F, 1);

	double contrast;

	// Get the area around the point
	cvGetRectSubPix(img, rect, *point);

	// Get Mean
	cvNormalize(rect, rectDiff);
	CvScalar tmp = cvAvg(rectDiff);

	// Sub Mean from image
	cvSubS(rectDiff, tmp, rect);

	// Pow
	cvPow(rect, rectDiff, 2);

	// Sum elements
	tmp = cvSum(rectDiff);
	contrast = sqrt(tmp.val[0]/(RECTANGLE_SIZE*RECTANGLE_SIZE));

	return contrast;
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
		// TODO: check collinearity (cross-ratio)
	}

endCheck:
	if(!pointOk) {
		// Point not valid, check if we can keep only the previous points
		if(nPoints > MINIMUM_LIFE) {
			// Set as undead
			feat->status = UNDEAD;

			// Correct points positions (move points in order to lie
			// on the line connecting first and last points)
			CvPoint2D32f firstPt, lastPt;
			firstPt = feat->positions[0];
			lastPt = feat->positions[feat->positions.size()-1];
			CvMat line;
			iaasJoiningLine(firstPt, lastPt, &line);
			double a, b, c;
			a = line.data.db[0];
			b = line.data.db[1];
			c = line.data.db[2];
			cout << "Line: " << a << " " << b << " " << c << endl;
			// TODO: find best line connecting features

			float *bestLine = new float[4];
			CvMemStorage* storage = cvCreateMemStorage(0);

			CvSeq* point_seq = cvCreateSeq(CV_32FC2, sizeof(CvSeq), sizeof(CvPoint2D32f), storage);
			for (int i=0; i<feat->positions.size(); i++) {
				cvSeqPush(point_seq, &feat->positions[i]);
			}
			cvFitLine(point_seq,CV_DIST_L2,0,0.01,0.01,bestLine);
			fprintf(stdout,"v=(%f,%f),vy/vx=%f,(x,y)=(%f,%f) \n",bestLine[0],bestLine[1],bestLine[1]/bestLine[0],bestLine[2],bestLine[3]);
			cvClearSeq(point_seq);
			cvReleaseMemStorage(&storage);


			for(int i=1; i < feat->positions.size()-1; i++) {
				//cout << "distance " << iaasPointLineDistance(&line, feat->positions[i]);
				feat->positions[i] = iaasProjectPointToLine(firstPt, lastPt, feat->positions[i]);
				// TODO: function iaasProjectPointToLine where line is defined as CvMat
				//cout << " " << iaasPointLineDistance(&line, feat->positions[i]) << endl;
			}
			// TODO: find best ratio between features distances
			double ratio = 0;
			double mean = 0;
			double variance = 0;

			//cout << "Ratio: ";
			for(int i=0; i<feat->positions.size()-2; i++) {
				double distance1 = iaasTwoPointsDistance(feat->positions[i],feat->positions[i+1]);
				double distance2 = iaasTwoPointsDistance(feat->positions[i+1],feat->positions[i+2]);
				ratio = distance1/distance2;
				//cout << ratio << " ";
				mean += ratio;
				variance += ratio*ratio;
			}
			ratio = mean/(feat->positions.size()-2);
			variance = variance/(feat->positions.size()-2);
			variance = sqrt(variance - ratio*ratio);
			// TODO: generate virtual features (computed not founded because inside fog)

			feat->ratio = ratio;
			//cout << endl;
			cout << "Ratios: " << ratio << " " << variance << endl;
			if(variance > 0.1) {
				feat->status = DELETE;
				//cout << "Ratio: " << ratio << endl;
				return false;
			}
			else {
				// Prolong line
				for(int i=0; i<10; i++) {
					feat->positions.push_back(iaasPointAlongLine(&line, feat->positions[feat->positions.size()-1], 10.0f));
				}
			}
			return true;
		}
		else {
			// Too short life, drop feature
			feat->status = DELETE;
			return false;
		}
	}
	else {
		// New point ok, keep tracking
		//feat->status = ALIVE;
		return true;
	}
}

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
}

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
