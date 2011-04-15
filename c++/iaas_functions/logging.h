/**
 * @file logging.h
 * @date Feb 24, 2009
 * @author Alessandro Stranieri
 */

#ifndef LOGGING_H_
#define LOGGING_H_

/**
 * Prints on screen a set of data resulting from a tracking step.
 * It prints in columns:
 *	1) Points found in the first image
 *	2) Points found in the second image
 *	3) 'yes' is the point is considered tracked, 'no otherwise'
 *	4) The tracking error TODO
 *	5) The distance between the found points
 *
 * @param cornersA Corners in the first image
 * @param cornersB Corners in the second image
 * @param track_status Array of Tracked/Not tracked flags
 * @param track_errors Array of tracking errors
 * @param track_count Number of points in the arrays
 */
void iaasPrintTrackingStatistics(CvPoint2D32f* cornersA, CvPoint2D32f* cornersB, char* track_status, float* track_errors, int track_count);


#endif /* LOGGING_H_ */
