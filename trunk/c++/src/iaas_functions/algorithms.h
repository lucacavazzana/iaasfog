/**
 * @file algorithms.h
 * @author Alessandro Stranieri
 * @date Feb 04, 2009
 *
 * Main algorithms used in the library.
 */

#ifndef ALGORITHMS_H_
#define ALGORITHMS_H_

#define MIN_FEATURE_DISTANCE 0//1
#define FRAME_RADIUS	2
#define FRAME_SIZE	2*FRAME_RADIUS+1
#define MINIMUM_LIFE	6

#include "parameters.h"
/**
 * Given a sequence of two images, finds corners in the first one and tracks them in the second one.
 * The function returns the corners in both mages as well as the number of found corners, an array of
 * tracking errors and an array of flags indicating whether the corner was found or not. This function is basically
 * a wrapper for OpenCV functions.
 *
 * @param quality_level Minimum quality of corner
 * @param imageA First image in sequence
 * @param imageB Second image in sequence
 * @param track_count Number of found corners
 * @param cornersA Corners found in first image
 * @param cornersB Corners found in second image
 * @param track_errors Tracking errors
 * @param track_status Tracked/Not tracked flags
 */
void iaasFindAndTrackCorners(double quality_level, IplImage *imageA, IplImage *imageB, int *track_count, CvPoint2D32f *cornersA, CvPoint2D32f *cornersB,  float *track_errors, char* track_status);

/**
 * Wraps the corner search steps. It returns the corners founds and their number.
 *
 * @param image An image
 * @param corners Array to store the corners' coordinates
 * @param corner_count Size of the array. This value is changed on return
 * @param quality Minimum quality of corners
 */
void iaasFindCorners(IplImage *image, CvPoint2D32f *corners, int *corner_count, double quality=QUALITY_LEVEL);

/**
 * Wraps the corner tracking steps. Returns an array of found corners. Two further arrays are filled:
 * one contains tracking errors and one a flag for each corner which states whether the corners has been found or not.
 *
 * @param imageA First image
 * @param imageB Second image
 * @param cornersA Corners to track
 * @param cornersB Tracked corners
 * @param track_errors Tracking error
 * @param track_status Tracked/Not tracked flag (1/0)
 * @param track_count Number of elements in the array
 */
void iaasTrackCorners(IplImage *imageA, IplImage *imageB, CvPoint2D32f *cornersA, CvPoint2D32f *cornersB, float *track_errors, char* track_status, int track_count);

/**
 * Counts how many corners have been marked as tracked.
 *
 * @param track_status Tracked/Not tracked flag array (1/0)
 * @param num_elements Number of elements in the array
 * @return The number of tracked elements
 */
int iaasNumberFoundCorners(char* track_status, int num_elements);

/**
 * According to the array of Tracked/Not tracked flags, copies tracked elements
 * into a new array.
 *
 * @param new_array New array
 * @param array Old array
 * @param status Tracked/Not tracked flag array (1/0)
 * @param n_points Number of points in the old array
 */
void iaasCopyFoundCorners(CvPoint2D32f *new_array, CvPoint2D32f *array, char* status, int n_points);

/**
 * Mark as Not Tracked those point pairs whose joining line is too far from the vanishing point
 *
 * @param cornersA Corners in first frame
 * @param cornersB Corners in second frame
 * @param num_corners Number of corners
 * @param status Tracked/Not tracked flags
 * @param vanishing_point Vanishing point
 * @param dist_th Distance threshold
 */
void iaasFilterByDistance(CvPoint2D32f *cornersA, CvPoint2D32f *cornersB, int num_corners, int *status, CvPoint2D32f vanishing_point, double dist_th);

/**
 * Mark as Not Tracked those point pairs whose tracking error is higher than a threshold
 * @param track_errors Array of tracking errors
 * @param track_status Tracked/Not tracked flags
 * @param num_corners Number of points
 * @param err_th Error threshold
 */
void iaasFilterByError(float *track_errors, char *track_status, int num_corners, float err_th);

/**
 * Mark as Not Tracked those point pairs for which at least one element is not in the field
 * of view.
 *
 * @param pointsA Points in the first frame
 * @param pointsB Points in the second frame
 * @param num_points Number of points
 * @param status Tracked/Not tracked flag array
 */
void iaasFilterNotInFOV(CvPoint2D32f *pointsA, CvPoint2D32f *pointsB, int num_points, char *status);

/**
 * Mark as Not Tracked those point pairs whose apparent motion is incoherent with respect to
 * the vanishing point.
 *
 * @param pointsA Points in the first frame
 * @param pointsB Points in the second frame
 * @param num_points Number of points
 * @param status
 * @param vanishing_point
 */
void iaasFilterByMotionDirection(CvPoint2D32f *pointsA, CvPoint2D32f *pointsB, int num_points, char *status, CvPoint2D32f vanishing_point);

/**
 * Estimate vanishing point using an a la Hough approach. A set of lines is provied as argument. These lines
 * are the joining lines of tracked corners. Divides the images in cells. For each cell assigns a vote
 * for each line passing through that cell. If the flag f_dist is true the vote is not discrete but proportional
 * to the distance from the centre of the cell. The cell with the highest value likely contains the vanishing point.
 * @param lines A set of lines
 * @param n_lines Number of lines
 * @param f_dist
 * @param img_width Image width
 * @param img_height Image height
 * @param patch_size Cell size
 * @return Center of the most crossed cell
 */
CvPoint2D32f iaasHoughMostCrossedPoint(CvMat *lines, int n_lines, bool f_dist=true, int img_width=FRAME_WIDTH, int img_height=FRAME_HEIGHT, int patch_size=PATCH_SIZE);

/**
 * Estimate vanishing point using an a la Hough approach. Two arrays of point are provided as argument.
 * Divides the images in cells and for each cell assigns a vote for each of the joining lines passing
 * through that cell. If the flag f_dist is true the vote is not discrete but proportional
 * to the distance from the centre of the cell. The cell with the highest value likely contains the vanishing point.
 * @param points0 First array of points
 * @param points1 Second array of points
 * @param nPoints Number of points
 * @param f_dist
 * @param img_width Image width
 * @param img_height Image height
 * @param patch_size Cell size
 * @return Center of the most crossed cell
 */
CvPoint2D32f iaasHoughMostCrossedPoint(CvPoint2D32f *points0, CvPoint2D32f *points1, int nPoints, bool f_dist=true, int img_width=FRAME_WIDTH, int img_height=FRAME_HEIGHT, int patch_size=PATCH_SIZE);
/**
 * Given two set of points, compute the parameters of each line joining points at the same position and returns
 * the point which minimizes the distance from each line.
 *
 * @param points0 First array of points
 * @param points1 Second array of points
 * @param nPoints Number of points in the array
 * @return A point
 */
CvPoint2D32f iaasMinimumDistantPoint(CvPoint2D32f *points0, CvPoint2D32f *points1, int nPoints);

/**
 * Old function. Possibly to be re-implemented.
 * @param pointsA Points in first frame
 * @param pointsB Points in second frame
 * @param num_points Number of points
 * @param status Tracked/Not tracked flag array
 * @return Estimated vanishing point
 */
CvPoint2D32f iaasEstimateVanishingPoint(CvPoint2D32f *pointsA, CvPoint2D32f *pointsB, int num_points, char *status);

/**
 * Computes the time to impact with the image plane of an object tracked in two frames. The functions makes use
 * of the Cross Ratio invariance for Homographies for the following four points:
 * 1) Vanishing point
 * 2) An object
 * 3) Same object tracked
 * 4) Intersection between line joining the tracked objects points and the image plane.
 *
 * @param vanishing_point Vanishing point
 * @param p_t0 Point in oldest frame
 * @param p_t1 Point in newest frame
 * @return Time to impact.
 */
double iaasTimeToImpact(CvPoint2D32f vanishing_point, CvPoint2D32f p_t0, CvPoint2D32f p_t1);

/**
 * Computes the mean time to impact for a set of objects tracked in two frames
 * @param vanishing_point Vanishing point
 * @param cornersA Corners in oldest frame
 * @param cornersB Corners in newest frame
 * @param n_corners Number of corners
 * @return Mean time to impact
 */
double iaasMeanTimeToImpact(CvPoint2D32f vanishing_point, CvPoint2D32f *cornersA, CvPoint2D32f *cornersB, int n_corners);

/*
 * Returns a rect representing the frame around the feature, making sure not to
 * exceed the border of the image
 * @param coordinates of the feature
 * @param image
 */
CvRect getContrFrame (CvPoint2D32f *point, IplImage *img);

/*
 * Computes the mean the Root Mean Square coontrast at the given coordinates.
 * Remember: unlike RMS value is not image-depth indipendent
 * @param img image to analyze
 * @oaram point coordinates
 */
double getRMSContrast(const IplImage *img, CvPoint2D32f *point);

/*
 * Computes the mean the Weber contrast at the given coordinates (using the
 * mean luminance of the vanishing point if provided, using the mean luminance
 * of the feature itself otherwise)
 * @param img image to analyze
 * @param point coordinates
 * @param vanishing point coordinates
 */
double getWeberContrast(const IplImage *img, CvPoint2D32f *point, CvPoint2D32f *vp=NULL);

/*
 * Computes the mean the Michelson coontrast at the given coordinates
 * @param img image to analyze
 * @param point coordinates
 */
double getMichelsonContrast(const IplImage *img, CvPoint2D32f *point);

//bool verifyValidFeature(featureMovement feat);
bool verifyNewFeatureIsOk(list<featureMovement>::iterator feat, const CvPoint2D32f newPoint, const int trackStatus=1);
bool verifyFeatureConsistency(featureMovement &feat);

float getCrossRatioDistance(CvPoint2D32f a, CvPoint2D32f b, CvPoint2D32f c, float crossRatio);
float getPointCDistance(CvPoint2D32f a, CvPoint2D32f b, CvPoint2D32f d, float crossRatio);
void filterFeaturesTooClose(CvPoint2D32f *newPoints, int *nNewPoints, CvPoint2D32f *existingPoints, int nExistingPoints);
float getCrossRatio(CvPoint2D32f *points);

#endif //ALGORITHMS_H_
