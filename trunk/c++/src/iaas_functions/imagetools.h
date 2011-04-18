#ifndef _IMAGETOOLS_H_
#define _IMAGETOOLS_H_

/**
 * @file imagetools.h
 * @date Feb 04, 2009
 * @author Alessandro Stranieri
 *
 * Functions mainly use to perform different operations on images.
 * They implement algorithms to compute images transformation, perform projective geometry computations
 * and retrieve set of values.
 */


/**
 * Returns the distance between two points
 *
 * @param point1 First point
 * @param point2 Second point
 * @return The distance
 */
template <class P> double iaasTwoPointsDistance(P point1, P point2) {
	double x1 = point1.x;
	double x2 = point2.x;
	double y1 = point1.y;
	double y2 = point2.y;
	return sqrt(iaasSquare<double>(y2 - y1) + iaasSquare<double>(x2 - x1));
}

CvPoint2D32f iaasPointAlongLine(CvMat *line, CvPoint2D32f startPoint, float pixelDistance);

/**
 * Returns the angle between two lines
 *
 * @param line1 First line
 * @param line2 Second line
 * @return The angle
 */
double iaasTwoLinesAngle(CvMat* line1, CvMat* line2);

/**
 * Returns the distance between a point and a line
 *
 * @param line A line
 * @param point A point
 * @return The distance
 */
template <class P> double iaasPointLineDistance(CvMat* line, P point) {
	double a, b, c, d, *data, x, y;
	data = line->data.db;
	a = data[0];
	b = data[1];
	c = data[2];
	x = point.x;
	y = point.y;

	d = fabs(a * x + b * y + c) / sqrt(iaasSquare<double>(a) + iaasSquare<double>(b));
	return d;
}

/**
 * Compute the parameters of a line joining two points
 *
 * @param p1 First point
 * @param p2 Second point
 * @param joinLine The joining line
 */
void iaasJoiningLine(CvPoint2D32f p1, CvPoint2D32f p2, CvMat* joinLine);


void iaasBestJoiningLine(CvPoint2D32f *list, int nPoints, CvMat* joinLine);

/**
 * Returns the point where the two lines intersects
 *
 * @post If intersection point is at infinity, (-1,-1) is returned
 *
 * @param line1 First line
 * @param line2 Second line
 * @return The intersection point
 */
CvPoint2D32f iaasIntersectionPoint(CvMat *line1, CvMat *line2);

/**
 * TODO
 * @param point1
 * @param point2
 * @param ppoint
 * @return
 */
CvPoint2D32f iaasProjectPointToLine(CvPoint2D32f point1, CvPoint2D32f point2, CvPoint2D32f ppoint);
CvPoint2D32f iaasProjectPointToLine(CvPoint2D32f oldPoint, CvMat *line);
/**
 * Computes and return the centroid of a set points
 *
 * @param points Array of points
 * @param point_count Number of points
 * @return The Centroid
 */
template <class P> CvPoint2D32f iaasCentroid(P *points, int num_points){
	double xC, yC;
	CvPoint2D32f point;
	int sum = 0;

	xC = yC = 0.0;
	for(int i = 0; i < num_points; i++){
		if(!(points[i].x == -1 && points[i].y == -1)){
			xC += points[i].x;
			yC += points[i].y;
			sum++;
		}
	}

	xC = xC/sum;
	yC = yC/sum;

	point = cvPoint2D32f(xC, yC);
	return point;
}

bool iaasPointIsInFOV(CvPoint point, int offset=0);

bool iaasPointIsInFOV(CvPoint2D32f point, int offset=0);

/**
 * Returns true if the corner tracked in two frames is
 * getting coherently farer from the vanishing point.
 *
 * @param p Point in the first frame
 * @param q Point in the second frame
 * @param vp Vanishing point
 * @return True is movement is coherent with vanishing point position
 */
template <class P> bool iaasIsMotionCoherent(P p, P q, P vp){
	//Points on the same Y of vanishing point
	if (p.y == vp.y) {
		if (q.y == vp.y) {
			if (p.x > vp.x) {
				if (q.x > p.x) {
					return true;
				}
			} else if (p.x < vp.x) {
				if (q.x < p.x) {
					return true;
				}
			}
		}
	}
	//Points on the same X of vanishing point
	if (p.x == vp.x) {
		if (q.x == vp.x) {
			if (p.y > vp.y) {
				if (q.y > p.y) {
					return true;
				}
			} else if (p.y < vp.y) {
				if (q.y < p.y) {
					return true;
				}
			}
		}
	}
	//Points under vanishing point
	if (p.y > vp.y) {
		if (q.y > p.y) {
			if (p.x > vp.x) {
				if (q.x > p.x)
					return true;
			} else if (p.x < vp.x) {
				if (q.x < p.x)
					return true;
			}
		}
	}
	//Points over vanishing point
	if (p.y < vp.y) {
		if (q.y < p.y) {
			if (p.x > vp.x) {
				if (q.x > p.x)
					return true;
			} else if (p.x < vp.x) {
				if (q.x < p.x)
					return true;
			}
		}
	}
	return false;
}

/**
 * Draws a line on the image.
 * Given the line parameters, if visible draws the line on the image.
 * @param image
 * @param line
 */
void iaasDrawStraightLine(IplImage* image, CvMat* line);

/**
 * Draws the flow field on an image.
 * Given two arrays of coordinates of the same corners tracked in two images, it draws the vectors connecting the points.
 *
 * @param image The image to draw on
 * @param cornersA Points in the first image
 * @param cornersB Points in the second image
 * @param corners_count Number of points
 * @param track_status Tracked/not tracked flags array
 * @param color Color of the vectors(default RED)
 * @param f_line Flag: true to draw the line joining two points
 */
void iaasDrawFlowField(IplImage* image, CvPoint2D32f *cornersA, CvPoint2D32f *cornersB, int corners_count, char *track_status, CvScalar color = CV_RGB(255,0,0), bool f_line = false);

void iaasDrawFlowFieldNew(IplImage* image, list<featureMovement> listFeatures, CvScalar color, bool f_line=false);
void drawFeatures(IplImage *image, CvPoint2D32f *points, int size);

/**
 * Draw ROI on image. Useful for debugging purposes.
 *
 * @param image
 * @param color
 */
void iaasDrawROI(IplImage* image, CvScalar color=CV_RGB(0,0,0));

void iaasCoordinates2DToHom(CvPoint* point, CvMat* array);

void iaasCoordinatesHomTo2D(CvMat* array, CvPoint* point);

/**
 * Given an image and a set of points, fills an array with the lowest eigenvalues of the auto-correlation
 * matrix of the derivative image at those points.
 *
 * @param image A grey-scale image, must be single channel
 * @param corners A set of points
 * @param track_status Tracked/Not tracked flag array
 * @param n_points Number of points
 * @param values On returns contains the eigenvalues
 */
void iaasGetACMinEigVals(IplImage *image, CvPoint2D32f *corners, char *track_status, int n_points, float *values);

/**
 * Given an image and a set of points, fills an array with the grey values of the image at those points.
 *
 * @param image A grey-scale image
 * @param corners A set of points
 * @param track_status Tracked/Not tracked flag array
 * @param n_points Number of points
 * @param values On returns contains grey values
 */
void iaasGetGreyValues(IplImage *image, CvPoint2D32f *corners, char *track_status, int n_points, float *values);

/**
 * If the input images have the same height, attach them and returns
 * the resulting image.
 *
 * @pre image0 and image1 must have same height
 * @param image0 First image
 * @param image1 Image to attach
 * @return The two images attached
 */
IplImage* iaasAddImage(IplImage *image0, IplImage *image1);

/**
 * This method is used to display the Mean time to impact.
 * It add a black stripe at the bottom of the input image and writes the
 * given value. Returns the actual image to display.
 *
 * @param image An image
 * @param tti The mean time to impact
 * @return The image to display
 */
IplImage* iaasAddTTIDisplay(IplImage *image, double tti);

#endif //_IMAGETOOLS_H_
