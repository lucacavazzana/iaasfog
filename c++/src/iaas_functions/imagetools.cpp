/**
 * @file imagetools.cpp
 * @author Alessandro Stranieri, Stefano Cadario, Luca Cavazzana
 * @date Feb 04, 2009
 */
#include "iaas.h"

double iaasTwoLinesAngle(CvMat* line1, CvMat* line2) {
	double angle;
	double l1, l2, m1, m2;
	double *dataL1, *dataL2;

	dataL1 = line1->data.db;
	dataL2 = line2->data.db;

	l1 = dataL1[0];
	l2 = dataL1[1];
	m1 = dataL2[0];
	m2 = dataL2[1];

	angle = (l1 * m1 + l2 * m2) / sqrt((iaasSquare<double>(l1) + iaasSquare<double>(l2)) * (iaasSquare<double>(m1)
			+ iaasSquare<double>(m2)));
	return angle;
}

CvPoint2D32f iaasPointAlongLine(CvMat *line, CvPoint2D32f firstPoint, CvPoint2D32f lastPoint, float pixelDistance) {
	CvPoint2D32f newPoint;

	float angle = atan2((double) lastPoint.y - firstPoint.y, (double) lastPoint.x - firstPoint.x);

	newPoint.x = lastPoint.x + (pixelDistance * cos(angle));
	newPoint.y = lastPoint.y + (pixelDistance * sin(angle));

#ifdef _DEBUG
	float dist = iaasTwoPointsDistance(newPoint, lastPoint);
	printf("TEST: %f\n", dist);
#endif

	return newPoint;
}

CvPoint2D32f iaasIntersectionPoint(CvMat *line1, CvMat *line2) {
	CvPoint2D32f result;
	double* data = new double[3];
	CvMat pointArray = cvMat(3, 1, CV_64FC1, data);
	cvCrossProduct(line1, line2, &pointArray);

	if(pointArray.data.db[2] == 0){
		//TODO handle with exception
#ifdef DEBUG
		printf("Intersection point is at infinity!\n");
		printf("Returning (-1, -1)\n");
#endif
		result = cvPoint2D32f(-1,-1);
	}else{
		result = cvPoint2D32f(pointArray.data.db[0] / pointArray.data.db[2],
				pointArray.data.db[1] / pointArray.data.db[2]);
	}

	return result;
}

void iaasBestJoiningLine(CvPoint2D32f *list, int nPoints, CvMat* joinLine) {
	float *bestLine = new float[4];

	CvMat point_mat = cvMat(1, nPoints, CV_32FC2, list);
	cvFitLine(&point_mat, CV_DIST_L2, 0, 0.01, 0.01, bestLine);

	// Compute parameters
	float m = bestLine[1]/bestLine[0];
	float q = bestLine[3]-bestLine[2]*m;

	delete bestLine;

	// Init result array
	double *data = new double[3];
	*joinLine = cvMat(3, 1, CV_64FC1, data);

	// Redefine parameter of line
	joinLine->data.db[0] = -m;
	joinLine->data.db[1] = 1;
	joinLine->data.db[2] = -q;

}

/* iaasJoiningLine
 * Computer the joining line (CvMat* joinLine) between
 * two points (CvPoint2D32f p1, CvPoint2D32f p2)
 * using cross product in homogeneous coordinates
 */
void iaasJoiningLine(CvPoint2D32f p1, CvPoint2D32f p2, CvMat* joinLine) {
	//First point in homogeneous coordinates
	double* a = new double[3];
	a[0] = p1.x;
	a[1] = p1.y;
	a[2] = 1;
	CvMat pA = cvMat(3, 1, CV_64FC1, a);

	//Second point in homogeneous coordinates
	double* b = new double[3];
	b[0] = p2.x;
	b[1] = p2.y;
	b[2] = 1;
	CvMat pB = cvMat(3, 1, CV_64FC1, b);

	//Init result array
	double* c = new double[3];
	*joinLine = cvMat(3, 1, CV_64FC1, c);

	cvCrossProduct(&pA, &pB, joinLine);
}

CvPoint2D32f iaasProjectPointToLine(CvPoint2D32f oldPoint, CvMat *line) {
	CvPoint2D32f newPoint;
	// y=mx+c m=-(a/b) c=-(c/b)
	float m = -(line->data.db[0]/line->data.db[1]);
	float q = -(line->data.db[2]/line->data.db[1]);

	newPoint.x = (m*oldPoint.y + oldPoint.x - m*q)/(m*m + 1);
	newPoint.y = (m*m*oldPoint.y + m*oldPoint.x + q)/(m*m + 1);
	return newPoint;
}

CvPoint2D32f iaasProjectPointToLine(CvPoint2D32f point1, CvPoint2D32f point2, CvPoint2D32f point3){

	CvMat A;
	double data_A[4];
	data_A[0] = point2.x - point1.x; data_A[1] = point2.y - point1.y;
	data_A[2] = point1.y - point2.y; data_A[3] = point2.x - point1.x;
	cvInitMatHeader(&A, 2, 2, CV_64FC1, data_A);

	CvMat X;
	double data_X[2];
	cvInitMatHeader(&X, 2, 1, CV_64FC1, data_X);

	CvMat B;
	double data_B[2];
	data_B[0] = -(-point3.x*(point2.x - point1.x) - point3.y*(point2.y - point1.y));
	data_B[1] = -(-point1.y*(point2.x - point1.x) + point1.x*(point2.y - point1.y));
	cvInitMatHeader(&B, 2, 1, CV_64FC1, data_B);

	cvSolve(&A, &B, &X);

	double x = data_X[0];
	double y = data_X[1];

	return cvPoint2D32f(data_X[0], data_X[1]);
}

template <typename T>bool iaasPointIsInFOV(const T point, int offset){
	if(iaasIsInClosedInterval<int>(point.x, 0+offset, FRAME_WIDTH-1-offset) &&
			iaasIsInClosedInterval<int>(point.y, 0+offset, FRAME_HEIGHT-1-offset)){
		return true;
	}else
		return false;
}

void iaasDrawStraightLine(IplImage* image, CvMat* line) {
	CvPoint p0, p1;
	int t;
	double a, b, c;

	int xMAX = image->width - 1;
	int yMAX = image->height - 1;
	a = line->data.db[0];
	b = line->data.db[1];
	c = line->data.db[2];

	//Count and store intersections
	int num_intersections = 0;
	CvPoint intersections[4];

	//Intersection Y = 0
	t = cvRound(-c/a);
	if(t >= 0 && t <= xMAX){
		intersections[num_intersections] = cvPoint(t, 0);
		num_intersections++;
	}
	//Intersection Y = yMAX
	t = cvRound((-c-b*yMAX)/a);
	if(t >= 0 && t <= xMAX){
		intersections[num_intersections] = cvPoint(t, yMAX);
		num_intersections++;
	}
	//Intersection X = 0;
	t = cvRound(-c/b);
	if(t >= 0 && t < yMAX){
		intersections[num_intersections] = cvPoint(0, t);
		num_intersections++;
	}
	//Intersection X = xMAX;
	t = cvRound((-c-a*xMAX)/b);
	if(t >= 0 && t < yMAX){
		intersections[num_intersections] = cvPoint(xMAX, t);
		num_intersections++;
	}

	if(num_intersections != 2){
#ifdef DEBUG
		printf("Line [%.2f %.2f %.2f]' is not visible\n", a, b, c);
#endif
		return;
	}

	p0 = intersections[0];
	p1 = intersections[1];

	cvLine(image, p0, p1, CV_RGB(0, 0, 0), 1);
}

void drawFeatures(IplImage *image, CvPoint2D32f *points, int size) {
	for(int i=0; i<size; i++) {
		cvCircle(image, cvPoint(cvRound(points[i].x), cvRound(points[i].y)), 2, CV_RGB(255, 255, 255));
	}
}

void iaasDrawFlowFeature(IplImage* image, featureMovement &feat) {
	for(int i=0; i<feat.positions.size(); i++) {
		cvCircle(image, cvPoint(cvRound(feat.positions[i].x), cvRound(feat.positions[i].y)), 2, CV_RGB(255, 255, 255));
	}
	//iaasDrawStraightLine(image, &feat.fitLine);
}

void iaasDrawFlowFieldNew(IplImage* image, list<featureMovement> listFeatures,
		CvScalar color, bool f_line) {
	CvPoint p, q;
	double angle, pq_distance;

	list<featureMovement>::iterator feat = listFeatures.begin();
	while (feat != listFeatures.end()) {

		int lastValue = feat->positions.size()-1;
		p = cvPoint(cvRound(feat->positions[0].x), cvRound(feat->positions[0].y));

		q = cvPoint(cvRound(feat->positions[lastValue].x), cvRound(feat->positions[lastValue].y));

		//Draw Line
		int line_thickness = 0.5f;
		cvLine(image, p, q, color, line_thickness, CV_AA, 0);

		if (f_line) {
			CvMat line;
			iaasJoiningLine(cvPointTo32f(p), cvPointTo32f(q), &line);
			iaasDrawStraightLine(image, &line);
		}
		//Draw arrow tips
		angle = atan2((double) p.y - q.y, (double) p.x - q.x);
		//pq_distance = iaasTwoPointsDistance<CvPoint>(p, q);
		pq_distance = 15;
		p.x = cvRound(q.x + pq_distance * .6 * cos(angle + PI / 6));
		p.y = cvRound(q.y + pq_distance * .6 * sin(angle + PI / 6));
		cvLine(image, p, q, color, line_thickness, CV_AA, 0);

		p.x = cvRound(q.x + pq_distance * .6 * cos(angle - PI / 6));
		p.y = cvRound(q.y + pq_distance * .6 * sin(angle - PI / 6));
		cvLine(image, p, q, color, line_thickness, CV_AA, 0);

		feat++;
	}
}

void iaasDrawFlowField(IplImage* image, CvPoint2D32f *cornersA,
		CvPoint2D32f *cornersB, int corner_count, char *track_status, CvScalar color, bool f_line) {
	CvPoint p, q;
	double angle, pq_distance;
	for (int i = 0; i < corner_count; i++) {
		if (track_status[i] == 0)
			continue;

		p = cvPoint(cvRound(cornersA[i].x), cvRound(cornersA[i].y));

		q = cvPoint(cvRound(cornersB[i].x), cvRound(cornersB[i].y));

		//Draw Line
		int line_thickness = 1;
		cvLine(image, p, q, color, line_thickness, CV_AA, 0);

		if (f_line) {
			CvMat line;
			iaasJoiningLine(cvPointTo32f(p), cvPointTo32f(q), &line);
			iaasDrawStraightLine(image, &line);
		}
		//Draw arrow tips
		angle = atan2((double) p.y - q.y, (double) p.x - q.x);
		pq_distance = iaasTwoPointsDistance<CvPoint>(p, q);
		p.x = cvRound(q.x + pq_distance * .6 * cos(angle + PI / 4));
		p.y = cvRound(q.y + pq_distance * .6 * sin(angle + PI / 4));
		cvLine(image, p, q, color, line_thickness, CV_AA, 0);

		p.x = cvRound(q.x + pq_distance * .6 * cos(angle - PI / 4));
		p.y = cvRound(q.y + pq_distance * .6 * sin(angle - PI / 4));
		cvLine(image, p, q, color, line_thickness, CV_AA, 0);
	}
}

void iaasDrawROI(IplImage *image, CvScalar color){
	CvRect roi_rect = cvGetImageROI(image);

	CvPoint p1 = cvPoint(roi_rect.x, roi_rect.y);
	CvPoint p2 = cvPoint(p1.x+roi_rect.width-1, p1.y+roi_rect.height-1);

	cvRectangle(image, p1, p2, color, 1);
}

void from2DToHomCoordinates(CvPoint* point, CvMat* array) {

	int* data = new int[3];
	cvInitMatHeader(array, 3, 1, CV_32SC1, data);
	array->data.i[0] = point->x;
	array->data.i[1] = point->y;
	array->data.i[2] = 1;
}

void fromHomCoordinatesTo2D(CvMat* array, CvPoint* point) {
	int *arrayValues = array->data.i;
	if (arrayValues[2] == 0) {
		printf("Error: Array is a point at infinity");
		exit(-1);
	}
	point->x = cvRound(arrayValues[0] / arrayValues[2]);
	point->y = cvRound(arrayValues[1] / arrayValues[2]);
}

void iaasGetACMinEigVals(IplImage *image, CvPoint2D32f *corners, char *track_status, int n_points, float *eigvals){
	//Temp image
	IplImage *eigenval;
	CvSize img_sz = cvGetSize(image);


	eigenval = cvCreateImage(img_sz, IPL_DEPTH_32F, 1);

	//Fill temp_image with auto-correlation matrix minimum values
	cvCornerMinEigenVal(image, eigenval, BLOCK_SIZE);

	//Store eigen_values
	for(int p = 0; p < n_points; p++){
		int offset = 3;
		if(track_status[p] == 1 && iaasPointIsInFOV(corners[p], offset)){
			int x = cvRound(corners[p].x);
			int y = cvRound(corners[p].y);
			double val = cvGetReal2D(eigenval, y, x);
			eigvals[p] = val;
		}else{
			eigvals[p] = 0.0;
		}
	}
}

void iaasGetGreyValues(IplImage *image, CvPoint2D32f *corners, char *track_status, int n_points, float *values){
	//Store eigen_values
	for(int i = 0; i < n_points; i++){
		if(track_status[i] == 1 &&
				iaasPointIsInFOV(corners[i])){
			int x = cvRound(corners[i].x);
			int y = cvRound(corners[i].y);
			double val = cvGetReal2D(image, y, x);
			values[i] = val;
		}else{
			values[i] = 0.0;
		}
	}
}

IplImage* iaasAddImage(IplImage *image0, IplImage *image1) {
	CvSize tot_sz, img0_sz, img1_sz;
	CvRect rect0, rect1;
	int depth, channels;
	IplImage *result_image;
	
	img0_sz = cvGetSize(image0);
	img1_sz = cvGetSize(image1);
	depth = image0->depth;
	channels = image0->nChannels;

	assert(img0_sz.height == img1_sz.height);
	assert(image0->depth == image1->depth);

	tot_sz = cvSize(img0_sz.width + img1_sz.width, img0_sz.height);
	result_image = cvCreateImage(tot_sz, depth, channels);

	rect0 = cvRect(0, 0, img0_sz.width, img0_sz.height);
	rect1 = cvRect(img0_sz.width, 0, img1_sz.width, img1_sz.height);

	cvSetImageROI(result_image, rect0);
	cvCopy(image0, result_image);
	cvSetImageROI(result_image, rect1);
	cvCopy(image1, result_image);

	cvResetImageROI(result_image);

	return result_image;
}

IplImage* iaasAddTTIDisplay(IplImage *image, double tti){
	IplImage *result, *display;
	CvFont font;
	char text[100];
	CvSize img_sz, result_sz, display_sz;
	CvRect rect;
	int image_depth, image_nCh;

	img_sz = cvGetSize(image);
	image_depth = image->depth;
	image_nCh = image->nChannels;
	display_sz = cvSize(img_sz.width, 30);

	display = cvCreateImage(display_sz, image_depth, image_nCh);
	cvSet(display, cvScalar(0,0,0));

	cvInitFont(&font, CV_FONT_HERSHEY_SIMPLEX, 1.0f, 1.0f);
	sprintf(text, "Mean Time to Impact: %.3f s", tti);
	cvPutText(display, text, cvPoint(100, 25), &font, cvScalar(255, 255, 255));

	result_sz = cvSize(img_sz.width, img_sz.height+display_sz.height);
	result = cvCreateImage(result_sz, image_depth, image_nCh);

	rect = cvRect(0, 0, img_sz.width, img_sz.height);
	cvSetImageROI(result, rect);
	cvCopy(image, result);
	rect = cvRect(0, img_sz.height, display_sz.width, display_sz.height);
	cvSetImageROI(result, rect);
	cvCopy(display, result);

	cvResetImageROI(result);

	return result;
}
