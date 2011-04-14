/**
 * @file datatypes.h
 * @date Jan 15, 2009
 * @author Alessandro Stranieri
 *
 * Custom data-structures available in the library
 */

#ifndef DATATYPES_H_
#define DATATYPES_H_

/**
 * Data-structure used to store the needed information from
 * a corner tracking step.
 */
typedef struct{
	int corner_count;
	char *track_status;
	CvPoint2D32f *corners;
	float *contrast;
} TrackRecord;

typedef enum {
	ALIVE,
	NEW,
	UNDEAD,
	DELETE
} featureStatus;

typedef struct {
	int startFrame;
	vector <CvPoint2D32f> positions;
	vector <float> contrast;
	int index;
	featureStatus status;
	double ratio;
} featureMovement;


/**
 * Creates a new instance of a TrackRecord structure and stores it in an array at the specified position.
 *
 * @param a_records Array of TrackRecord structures
 * @param n_record Position of the record inside the array
 * @param corners Corners tracked
 * @param track_status Tracked/Not tracked flag array
 * @param mineigvals Minimum eigenvalues at the tracked corners
 */
void iaasStoreTrackRecord(TrackRecord *a_records, int n_record, CvPoint2D32f *corners, char* track_status, float *mineigvals);

/**
 * Writes data corresponding to positively tracked features to a file.
 *
 * @param a_records Array of TrackRecord instances
 * @param file File identifier
 */
void iaasWriteTrackRecordToFile(TrackRecord *a_records, char *file_path);

/**
 * Print the data of a TrackRecord instance on screen.
 *
 * @param a_records Pointer to a TrackRecord instance
 */
void iaasPrintTrackRecord(TrackRecord *record);

/**
 * Print the whole tracking recording array data on screen.
 *
 * @param a_records Array of TrackRecord instances
 * @param num_records Number of records
 */
void iaasPrintTrackRecords(TrackRecord *a_records, int num_records);

/**
 * Cycle over a TrackRecord array and select only those features which present a
 * coherent motion.
 * Of all the features tracked in every record of the array, only those whose position
 * progressively gets farer are kept.
 *
 * @param a_records Array of TrackRecords
 * @param num_records Number of records
 * @return Number of selected features
 */
int iaasSelectCoherentMotionFeatures(TrackRecord *a_records, int num_records);

/**
 * Cycle over a TrackRecord array and select only those features belonging to
 * a line which is not "far" by the vanishing point. The diagonal of a predefined patch
 * is used as threshold.
 * @see iaasHoughMostCrossedPoint
 *
 * @param a_records Array of TrackRecords
 * @param vp Vanishing Point
 * @param num_records Number of records
 * @param patch_size Size of patch
 * @return Number of selected features
 */
int iaasSelectCloseFlowVectors(TrackRecord *a_records, CvPoint2D32f vp, int num_records, int patch_size);

/**
 * Cycle over a TrackRecord array and select only those features whose "path" is
 * in the field of view.
 *
 * @param a_records Array of TrackRecords
 * @param num_records Number of records
 * @return Number of selected features
 */
int iaasSelectInFOVFeatures(TrackRecord *a_records, int num_records);

/**
 * Cycle over a TrackRecord array and select only those features which present a
 * decreasing minimum eigenvalue.
 * *
 * @param a_records Array of TrackRecords
 * @return Number of selected features
 */
int iaasSelectCoherentEigvalsFeatures(TrackRecord *a_records);

/**
 * Scan an array of TrackRecord instances and, for each features tracked, store
 * the coordinates in the first and last frame in two arrays.
 *
 * @param a_records Array of TrackRecord instance
 * @param points0 Contains corners found in the first image
 * @param points1 Contains corners tracked in the last frame
 * @param num_records Number of records
 */
void iaasGetTrackedPoints(TrackRecord *a_records, CvPoint2D32f *points0, CvPoint2D32f *points1, int num_records);

/**
 * Class implementing a P2 space vector. Each element is an homogenous vector,
 * therefore it consists of three coordinates.
 */
class Hom2DVector{
private:
	CvMat mat1D;
public:
	/**
	 * Constructor from CvPoint
	 * @param point Point in 2D euclidean space
	 * @return An instance of the class
	 */
	Hom2DVector(CvPoint point);

	/**
	 * Constructor from CvPoint2D32f
	 * @param point Point in 2D euclidean space
	 * @return An instance of the class
	 */
	Hom2DVector(CvPoint2D32f point);

	/**
	 * Get an element of the vector.
	 * @pre The argument must be in [0, 2]
	 * @param i The element index
	 * @return The i-th element
	 */
	double getElement(int i);
	/**
	 * Set an element of the vector.
	 * @pre The first argument must be in [0, 2]
	 * @param i The element index
	 * @param val The value
	 */
	void setElement(int i, double val);

	/**
	 * If possible, normalizes the vector.
	 */
	void Normalize();

	/**
	 * Returns the euclidean representation of the point.
	 * @return A point in E2
	 */

	CvPoint2D32f getCartesianPoint();
	/**
	 * Prints on screen the vector
	 */
	void print();
};
#endif /* DATATYPES_H_ */
