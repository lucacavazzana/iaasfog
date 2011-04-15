/**
 * @file logging.cpp
 * @date Feb 24, 2009
 * @author Alessandro Stranieri
 */
#include "iaas.h"

void iaasPrintTrackingStatistics(CvPoint2D32f* cornersA, CvPoint2D32f* cornersB, char* track_status, float* track_errors, int track_count) {
	double total_error, avg_error = 0.0;
	double max_error, min_error = track_errors[0];
	int tracked_corners;
	printf("Tracking Statistics\n");
	printf("- - - - - - - ");
	printf("- - - - - - - ");
	printf("- - - - -");
	printf("- - - - - -");
	printf("- - - - - - -");
	printf("\n");
	printf("|   FrameA   |");
	printf("|   FrameB   |");
	printf("| Found |");
	printf("|  Error  |");
	printf("|  Length  |");
	printf("\n");
	for (int p = 0; p < track_count; p++) {
		printf("| (%03d, %03d) |", cvRound(cornersA[p].x), cvRound(
				cornersA[p].y));
		printf("| (%03d, %03d) |", cvRound(cornersA[p].x), cvRound(
				cornersB[p].y));
		printf("|  %s  |", track_status[p] == 0 ? " no" : "yes");
		printf("| %07.3f |", track_errors[p]);
		printf("|  %07.3f |", iaasTwoPointsDistance<CvPoint2D32f>(cornersA[p], cornersB[p]));
		printf("\n");

		if (track_status[p] == 1) {
			total_error += track_errors[p];
			max_error = track_errors[p] > max_error ? track_errors[p] : max_error;
			min_error = track_errors[p] < min_error ? track_errors[p] : min_error;
		}
	}
	avg_error = total_error / track_count;
	printf("Max error is: %.3f\n", max_error);
	printf("Min error is: %.3f\n", min_error);
	printf("Avg error is: %.3f\n", avg_error);

}
