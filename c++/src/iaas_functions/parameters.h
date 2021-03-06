/**
 * @file parameters.h
 * @date Feb 24, 2009
 * @author Alessandro Stranieri
 *
 * Essential parameters for library algorithms. Changes here affects the whole execution
 */

/*
 * Define the direction of process the images (forward or backward if defined)
 */
#define REVERSE_IMAGE

#define MAX_DISTANCE_FEATURE_VP		5.0f

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
#define MAX_CORNERS 100//50
/**
 * Quality of corner
 */
#define QUALITY_LEVEL 0.01 //0.1
/**
 * Minimum distance between two tracked points
 */
#define MIN_DISTANCE 10//10.0
/**
 * Auto-correlation matrix size
 */
#define BLOCK_SIZE 3

//LKT parameters
/**
 * Lukas Kanade algorithm search window size
 */
#define WIN_SIZE 20//50		// TODO: how this parameter change the results

/**
 * Number of pyramid layers used in LK algorithm
 */
#define PYR_LEVELS 5


/**
 * Number of frames corners are to be tracked
 */
#define NUM_RECORDS 5

/**
 * Frame rate. Don't change this.
 */
#define FRAME_RATE 30

#define CRMaxVariance		0.1f
#define CRTollerancePerc	0.10f
#define CRtolleranceMax 	4.0f/3.0f*(1+CRTollerancePerc)
#define CRtolleranceMin		4.0f/3.0f*(1-CRTollerancePerc)

// Enable/Disable filter on features
#define Enable_AngleFilter			1
#define Enable_CheckCrossRatio		1
#define Enable_FilterTooClose		1


#define Enable_OptimizeVanishingPointSVD	0


#define MIN_FEATURE_DISTANCE	0 //1

#define VARIABLE_FRAME_SIZE		1
#define MAX_FRAME_RADIUS		8
#define MIN_FRAME_RADIUS    	2
#define FRAME_SIZE				2*MIN_FRAME_RADIUS+1

#define MINIMUM_LIFE			4

#ifndef PARAMETERS_H_
#define PARAMETERS_H_


#endif /* PARAMETERS_H_ */
