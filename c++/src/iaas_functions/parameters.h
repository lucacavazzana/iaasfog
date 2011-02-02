/**
 * @file parameters.h
 * @date Feb 24, 2009
 * @author Alessandro Stranieri
 *
 * Essential parameters for library algorithms. Changes here affects the whole execution
 */

//Image parameters
/**
 * Frame width.
 * Some functions rely on this number
 */
#define FRAME_WIDTH 320
/**
 * Frame height.
 * Some functions rely on this number
 */
#define FRAME_HEIGHT 200

//Features Selection parameters
/**
 * Number of corners searched in the first frame
 */
#define MAX_CORNERS 500
/**
 * Quality of corner
 */
#define QUALITY_LEVEL 0.01
/**
 * Minimum distance between two tracked points
 */
#define MIN_DISTANCE 10.0
/**
 * Auto-correlation matrix size
 */
#define BLOCK_SIZE 3

//LKT parameters
/**
 * Lukas Kanade algorithm search window size
 */
#define WIN_SIZE 50
/**
 * Number of pyramid layers used in LK algorithm
 */
#define PYR_LEVELS 5

/**
 * Size of the patch used in "Hough" algorithm.
 */
#define PATCH_SIZE 20

/**
 * Number of frames corners are to be tracked
 */
#define NUM_RECORDS 5

/**
 * Frame rate. Don't change this.
 */
#define FRAME_RATE 30

#ifndef PARAMETERS_H_
#define PARAMETERS_H_


#endif /* PARAMETERS_H_ */
