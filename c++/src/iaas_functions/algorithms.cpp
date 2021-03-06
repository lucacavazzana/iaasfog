/**
 * @file algorithms.h
 * @author Stefano Cadario, Luca Cavazzana (originally developed by Alessandro Stranieri)
 * @date Feb 04, 2009
 */
#include "iaas.h"
#include <iostream>
#include <vector>

CvRect getContrFrame(CvPoint2D32f *point, IplImage *img, int frameRadius) {
        // Rounding: TODO check if + 0.5 is necessary or not
        int x = int(point->x/*+.5*/);
        int y = int(point->y/*+.5*/);

        return cvRect(	max(0,x-frameRadius),
        				max(0,y-frameRadius),
        				min(frameRadius*2+1, min(img->width-x, x+1)+frameRadius), // radius+1 + (width-1 - x) if on the right,  x + radius+1 if on the left
        				min(frameRadius*2+1, min(img->height-y, y+1)+frameRadius));
}

double getRMSContrast(const IplImage *img, CvPoint2D32f *point, int frameRadius) {

        // Element out of the image
        if (!iaasPointIsInFOV(*point))
                return -1;

        CvScalar avg, sdv;

        cvSetImageROI((IplImage *)img, getContrFrame(point, (IplImage*)img, frameRadius));
        cvAvgSdv(img, &avg, &sdv);

        cvResetImageROI((IplImage *)img);

        return sdv.val[0];
}

double getWeberContrast(const IplImage *img, CvPoint2D32f *point, CvPoint2D32f *vp) {

        // Element out of the image
        if (!iaasPointIsInFOV(*point))
                return -1;

        CvScalar avg;

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

        // Element out of the image
        if (!iaasPointIsInFOV(*point))
        	return -1;

        double maxV, minV;
        cvSetImageROI((IplImage *)img, getContrFrame(point, (IplImage*)img));

        cvMinMaxLoc(img, &minV, &maxV);
        cvResetImageROI((IplImage *)img);

        return (maxV-minV)/(maxV+minV);
}

void BackToTheFeatures(featureMovement &feat, CvPoint2D32f *vp) {
	int i;
	// Prolong line, generate virtual features (computed because inside fog)
	int maxAdd = feat.startFrame - feat.positions.size() + 1;
#ifdef _DEBUG
	cout << "Point found: " << feat.positions.size();
#endif
	int lastIndex = feat.positions.size() - 1;

	CvPoint2D32f lastRealPoint = feat.positions[lastIndex];
	CvPoint2D32f beforeLastRealPoint = feat.positions[lastIndex-1];

	int nFramesAB = lastIndex;	// Distance (in nFrames) between first point A and last point found B

	// Define X1 and X2
	CvPoint2D32f x1 = feat.positions[lastIndex];	// B = farest to image plane (nearest to VP)
	CvPoint2D32f x2 = feat.positions[0];			// A = nearest to image plane (farest to VP)

	for(i=0; i<maxAdd; i++) {
		float newDistance;

		// If null don't use vanishing point
		if(vp != NULL) {
			//float distanceM2 = getPointCDistance(feat.positions[lastIndex-1],feat.positions[lastIndex],*vp, 2.0f);

			float x2x1 = iaasTwoPointsDistance(x2, x1);
			float vpx2 = iaasTwoPointsDistance(x2, *vp);
			float vpx1 = iaasTwoPointsDistance(x1, *vp);

			//newDistance = x2x1 / ((vpx2/vpx1)*(lastIndex+1)-1);

			// Ratio between m/n where m=BC and n=AB
			float pointsRatio = (float)(nFramesAB)/(float)(i+1);	//(float)(i+1)/(float)(nFramesAB);

			//cout << "I: " << i+1 << " nFramesAB: " << nFramesAB << " -> " << pointsRatio << endl;

			float oldDistance = newDistance;
			newDistance = x2x1 / ((vpx2/vpx1)*(1+pointsRatio)-1);

			//cout << "New distance: " << newDistance-oldDistance << endl;
		}
		else {
			newDistance = getCrossRatioDistance(feat.positions[lastIndex-2],feat.positions[lastIndex-1],feat.positions[lastIndex], (4.0f/3.0f));
		}

		// If next point distance is below 0.5 pixel stop
		if(newDistance < 0.5f)
			break;

		// Find two points (two possible functions)
		CvPoint2D32f x0_a, x0_b;
		double delta = sqrt(4*x1.y*x1.y - 4*(x1.y*x1.y - newDistance*newDistance/(1 + pow((x2.x-x1.x)/(x1.y-x2.y), 2))));
		x0_a.y = x1.y + delta/2;
		x0_b.y = x1.y - delta/2;
		x0_a.x = x1.x - (x2.x - x1.x)/(x1.y - x2.y)*(x0_a.y - x1.y);
		x0_b.x = x1.x - (x2.x - x1.x)/(x1.y - x2.y)*(x0_b.y - x1.y);

		double dist_vanpX01 = iaasTwoPointsDistance(*vp,x0_a);
		double dist_vanpX02 = iaasTwoPointsDistance(*vp,x0_b);

		if(dist_vanpX01 <= dist_vanpX02) {
			feat.positions.push_back(x0_a);
		}
		else if (dist_vanpX02 <= dist_vanpX01) {
			feat.positions.push_back(x0_b);
		}
		else {
			cout << "ERROR !!!" << endl;
		}

		//feat.positions.push_back(newPoint);
		lastIndex++;
#ifdef _DEBUG
		float realDistance = iaasTwoPointsDistance(feat.positions[lastIndex-1],feat.positions[lastIndex]);
		cout << "( " << newDistance << "-" << realDistance << ") ";
#endif
	}
#ifdef _DEBUG
	cout << " Point added: " << i << endl;
#endif
}

bool verifyFeatureConsistency(featureMovement &feat) {

	if(feat.positions.size() > MINIMUM_LIFE) {
		// Set as undead
		feat.status = UNDEAD;

		// Correct points positions (move points in order to lie
		// on the best line fitting all points)

		iaasBestJoiningLine(&feat.positions[0], feat.positions.size(), &feat.fitLine);

		float maxDistance = 0;

		for(int i=0; i < feat.positions.size()-1; i++) {
			/*float locDistance = abs(iaasPointLineDistance(&feat.fitLine, feat.positions[i]));
			if(locDistance>maxDistance)
				maxDistance = locDistance;*/
			feat.positions[i] = iaasProjectPointToLine(feat.positions[i], &feat.fitLine);
		}
#ifdef _DEBUG
		cout << "Max Distance " << maxDistance << endl;
#endif

#if Enable_CheckCrossRatio == 1
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

		feat.ratio = ratio;
		if(ratio < CRtolleranceMin || ratio > CRtolleranceMax || variance > CRMaxVariance) {
			feat.status = DELETE;
			cout << "Delete because mean " << ratio << " or variance " << variance << endl;
			return false;
		}
		else {
			// Prolong line, generate virtual features (computed not founded because inside fog)
			//BTTFFeatures(feat);
		}
#endif
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
	double distance = 0;

	// Check if new point is tracked correctly
	if(!trackStatus) {
		pointOk = false;
		goto endCheck;
	}

	// Check if new point is in Field Of View
	if(!iaasPointIsInFOV(newPoint,0)) {
		pointOk = false;
		goto endCheck;
	}

	// Get distance of two points before
	distance = iaasTwoPointsDistance(feat->positions[nPoints-2], feat->positions[nPoints-1]);

	// Check if distance from last two points is less than previous points
#ifdef REVERSE_IMAGE
	if(distance  < iaasTwoPointsDistance(feat->positions[nPoints-1], newPoint)) {
#else
	if(distance > iaasTwoPointsDistance(feat->positions[nPoints-1], newPoint)) {
#endif
		pointOk = false;
		goto endCheck;
	}

	// Check angle
#if	Enable_AngleFilter == 1
	double angle;
	CvMat line1, line2;
	iaasJoiningLine(feat->positions[nPoints-2], feat->positions[nPoints-1], &line1);
	iaasJoiningLine(feat->positions[nPoints-1], newPoint, &line2);
	angle = iaasTwoLinesAngle(&line1, &line2);
	if(angle < 0.95) {
		//cout << "angle: " << angle << endl;
		pointOk = false;
		goto endCheck;
	}
#endif

	// Check cross-ratio value
#if Enable_CheckCrossRatio == 1
	if(nPoints > 3) {
		// Check collinearity (crossRatio)
		float crossRatio = getCrossRatio(&feat->positions[nPoints-4]);
		if(crossRatio < CRtolleranceMin || crossRatio > CRtolleranceMax) {
			pointOk = false;
			goto endCheck;
		}
	}
#endif

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
		else if(nDelete>0){
			// Scale element with deleted
			newPoints[i-nDelete] = newPoints[i];
		}
	}
	// Set new size of array
	*nNewPoints = *nNewPoints-nDelete;
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
			//cvTermCriteria(CV_TERMCRIT_ITER | CV_TERMCRIT_EPS, 40, .1),
			cvTermCriteria(CV_TERMCRIT_ITER | CV_TERMCRIT_EPS, 1000, .05),
			0
	);

#if MIN_FEATURE_DISTANCE > 0
	// Delete corners too close
	for(int i=0; i<corner_count; i++) {
		if(track_status[i]) {
			double distance =  iaasTwoPointsDistance(cornersA[i], cornersB[i]);
			if(distance<MIN_FEATURE_DISTANCE)
				track_status[i] = 0;
		}
	}
#endif
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

double iaasTimeToImpact(CvPoint2D32f vanishing_point, CvPoint2D32f p_t0, CvPoint2D32f p_t1, int n_frames) {
	double time_to_impact;
	double p1_vp, p0_p1;

	//Compute distances in image plane
	p1_vp = iaasTwoPointsDistance<CvPoint2D32f>(p_t1, vanishing_point);//C'A'
	p0_p1 = iaasTwoPointsDistance<CvPoint2D32f>(p_t0, p_t1);//C'B'

	//time_to_impact = p1_vp/(p0_p1)*FRAME_RATE;	// Old formula...it seems that it lacks the -1 (see below)
	time_to_impact = ((p1_vp/p0_p1)-1)*((double)n_frames/(double)FRAME_RATE);

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
	for(int i = 0, j= 0; i < num_points; i++) {
		if(status[i] == 1) {
			iaasJoiningLine(pointsA[i], pointsB[i], joiningLines+j);
			j++;
		}
	}

	CvPoint2D32f vp = iaasHoughMostCrossedPoint(joiningLines, tracked_corners);

	return vp;
}

CvPoint2D32f iaasFindBestCrossedPointRANSAC(IplImage* image, CvMat *lines, int n_lines, float *distancePercentile) {

	srand(time(NULL));

	int iteration = 0;


	CvPoint2D32f vpCandidate, result;

	// Test just a 10% of all possibile intersections
	int max_iteration = (n_lines*n_lines + n_lines)/20;

	vector<float> distances;
	distances.reserve(n_lines);

#ifdef _DEBUG
	cout << "Max iteration: " << max_iteration << endl;
#endif

	float rank = 0;
	float bestRank = 0;

	float distance;

	int inliers = 0;
	int tempInliers = 0;

	int percentile = n_lines/2;	// Percentile = 50%

	while(iteration < max_iteration) {

		// Find a vanishing point candidate
		do {
			vpCandidate = iaasIntersectionPoint(&lines[rand()%n_lines], &lines[rand()%n_lines]);
		} while(!iaasPointIsInFOV(vpCandidate));

		rank = 0;
		tempInliers = 0;

		distances.clear();

		for(int j=0; j<n_lines; j++) {
			distance = iaasPointLineDistance(&lines[j], vpCandidate);
			distances.push_back(distance);
		}

		// Order distance
		quickSort(&distances[0], n_lines);

		// Take the n-th percentile element as rank
		rank = distances[percentile];

		if((rank < bestRank) || (iteration == 0)) {
			result = vpCandidate;
			bestRank = rank;
			inliers = tempInliers;
#ifdef _DEBUG
			cout << "Elected point (" << result.x << ";" << result.y << ") as best Rank with " << bestRank << endl;
#endif
		}
		iteration++;
	}

	*distancePercentile = bestRank;

	// --------------Resolve with SVD--------------
#if Enable_OptimizeVanishingPointSVD == 1
	// Number of elements to take
	inliers = percentile-1;

	//Solution matrix
	CvMat X;
	double data_X[2];

	// Init matrix X with 2 Row, 1 Column with dataX
	cvInitMatHeader(&X, 2, 1, CV_64FC1, data_X);

	//A and B matrices
	CvMat A; 								CvMat B;
	double *data_A = new double[inliers]; double *data_B = new double[inliers];
	int j=0;
	for(int i = 0; i < n_lines; i++) {
		// If data is already filled with all lines we need stop the loop
		if(j >= inliers)
			break;

		// Just inliers count
		if(iaasPointLineDistance(&lines[i], result) < bestRank) {
			double *line_data = lines[i].data.db;
			double a = line_data[0], b = line_data[1], c = line_data[2];

			data_A[2*j] 	= a/sqrt(iaasSquare<double>(a)+iaasSquare<double>(b));
			data_A[2*j+1] 	= b/sqrt(iaasSquare<double>(a)+iaasSquare<double>(b));
			data_B[j] 		= -c/sqrt(iaasSquare<double>(a)+iaasSquare<double>(b));
			j++;
		}
	}
	cout << "Inliers: " << inliers << " J: " << j <<endl;
	cvInitMatHeader(&A, inliers, 2, CV_64FC1, data_A);
	cvInitMatHeader(&B, inliers, 1, CV_64FC1, data_B);

	//Solve system with Least Square Method
	cvSolve(&A, &B, &X, CV_SVD);

	if(data_X[2] == 0){
	#ifdef DEBUG
			printf("SVD not working, returning not optimized point\n");
	#endif
			return result;
		}
		double x = data_X[0];
		double y = data_X[1];

		return cvPoint2D32f(x, y);

#endif

	return result;


}

// Old method, deprecated because too slow
CvPoint2D32f iaasFindBestCrossedPoint(IplImage* image, CvMat *lines, int n_lines, int img_width, int img_height) {
	CvPoint2D32f result;
	CvPoint2D32f temp;
	vector<CvPoint2D32f> intersect;
	vector<CvPoint2D32f> bestFit;
	for(int i=0; i<n_lines; i++) {
		for(int j=i+1; j<n_lines; j++) {
			temp = iaasIntersectionPoint(&lines[i], &lines[j]);
			if(iaasPointIsInFOV(temp)) {
				intersect.push_back(temp);
			}
		}
	}

	// Find best candidate vanishing point from set
	int MAX_DIST = MAX(img_width, img_height)/15;	// Maximum distance where points is minimum
	int MIN_DIST = 2;								// Maximum distance where points is maximum

	float rank = 0;
	float bestRank = 0;
	int Npoints = intersect.size();

	for(int i=0; i<Npoints; i++) {
		rank = 0;
		for(int j=0; j<Npoints; j++) {
			if(i == j) continue;
			// If rank is lower than best even if all subsequent rank are all 1 discard
			if(rank + Npoints - j < bestRank) break;

			// 25% delle distanze
			float distance = iaasTwoPointsDistance(intersect[i], intersect[j]);
			if(distance < MAX_DIST) {
				if(distance < MIN_DIST)
					rank += 1;
				else
					rank += (MAX_DIST-distance)/(MAX_DIST-MIN_DIST);
			}
		}
		if(rank > bestRank) {
			result = intersect[i];
			bestRank = rank;
		}
	}

	// Compute centroid
	float x=0, y=0;
	int size=0;
	for(int i=0; i<intersect.size(); i++) {
		if(iaasTwoPointsDistance(result, intersect[i]) < MAX_DIST) {
			//bestFit.push_back();
			x +=intersect[i].x;
			y +=intersect[i].y;
			size++;
			//cvCircle(image, cvPoint(cvRound(intersect[i].x), intersect[i].y), 1, CV_RGB(255, 255, 255));
		}
	}
	result.x = x/size;
	result.y = y/size;

	return result;
}

// Very old method, deprecated because it sucks
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

// YADSF = Yet another deprecated stupid function
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
