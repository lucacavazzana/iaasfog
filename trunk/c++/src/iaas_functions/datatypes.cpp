/**
 * @file datatypes.cpp
 * @date Jan 15, 2009
 * @author Alessandro Stranieri
 */
#include "iaas.h"
#include <iostream>

void iaasStoreTrackRecord(TrackRecord *a_records, int n_record, CvPoint2D32f *corners, char* track_status, float *mineigvals){
	//Init structure
	TrackRecord record;
	record.corners = new CvPoint2D32f[MAX_CORNERS];
	record.track_status = new char[MAX_CORNERS];
	record.contrast = new float[MAX_CORNERS];

	record.corner_count = 0;
	for(int i = 0; i < MAX_CORNERS; i++){
		record.corners[i] = cvPoint2D32f(0.0f,0.0f);
		record.track_status[i] = 0;
		record.contrast[i] = 0;
	}

	if(n_record == 0){
		//First record. All elements have to be copied
		for(int i = 0; i < MAX_CORNERS; i++){
			record.corners[i] = corners[i];
			record.track_status[i] = track_status[i];
			record.contrast[i] = mineigvals[i];
		}
	}else{
		//For other records, copy takes place only for elements
		//That were successfully tracked in the previous frame
		TrackRecord *last_record = a_records+(n_record-1); //Last element
		for(int i = 0, j = 0; i < MAX_CORNERS; i++){
			if(last_record->track_status[i] == 1){
				record.corners[i] = corners[j];
				record.track_status[i] = track_status[j];
				record.contrast[i] = mineigvals[j];
				j++;
			}
		}
	}

	a_records[n_record] = record;
}

void iaasWriteTrackRecordToFile(TrackRecord *a_records, char *file_path){
	FILE *file = fopen(file_path, "w");

	char* status = a_records[NUM_RECORDS-1].track_status;
	for(int p = 0; p < MAX_CORNERS; p++){
		if(status[p] == 1){
			for(int rec = 0; rec < NUM_RECORDS; rec++){
				//printf("%d (%06.2f %06.2f) ", p, a_records[rec].corners[p].x, a_records[rec].corners[p].y);
				fprintf(file, "%.6f ", a_records[rec].contrast[p]);
			}
			//printf("\n");
			fprintf(file, "\n");
			fflush(file);
		}
	}

	fclose(file);
}

void iaasPrintTrackRecord(TrackRecord *record){
	char *status = record->track_status;
	for(int p = 0; p < MAX_CORNERS; p++){
		printf("(%07.3f, %07.3f) ", record->corners[p].x, record->corners[p].y);

		printf("[%.10f] ", record->contrast[p]);

		printf("%c\n", status[p] == 1 ? 'y' : 'n');
	}
}

void iaasPrintTrackRecords(TrackRecord *a_records, int num_records){
	char *status = a_records[num_records-1].track_status;
	for(int p = 0; p < MAX_CORNERS; p++){
		if(status[p] == 1){
			for(int rec = 0; rec < num_records; rec++){
				printf("(%07.3f, %07.3f) ", a_records[rec].corners[p].x, a_records[rec].corners[p].y);
			}
			for(int rec = 0; rec < num_records; rec++){
				printf("[%07.6f] ", a_records[rec].contrast[p]);
			}
			printf("%c\n", status[p] == 1 ? 'y' : 'n');
		}
	}
}

int iaasSelectCoherentMotionFeatures(TrackRecord *a_records, int num_records){
	char *status = a_records[num_records-1].track_status;
	int counter = 0;
	for(int p = 0; p < MAX_CORNERS; p++){
		if(status[p] == 1){
			CvPoint2D32f p0 = a_records[0].corners[p];
			CvPoint2D32f p1 = a_records[1].corners[p];
			bool sign_x = sign<float>(p0.x-p1.x);
			bool sign_y = sign<float>(p0.y-p1.y);
			for(int rec = 2; rec < num_records; rec++){
				CvPoint2D32f p2 = a_records[rec].corners[p];
				if(sign_x != sign<float>(p1.x-p2.x) || sign_y != sign<float>(p1.y-p2.y)){
					status[p] = 0;
					break;
				}else{
					p1 = p2;
					if(rec == num_records-1)
						counter++;
				}
			}
		}
	}
	return counter;
}

int iaasSelectCloseFlowVectors(TrackRecord *a_records, CvPoint2D32f vp, int num_records, int patch_size){
	char *status = a_records[num_records-1].track_status;
	int counter = 0;
	double dist_th = sqrt(2.0)*patch_size;
	for(int p = 0; p < MAX_CORNERS; p++){
		if(status[p] == 1){
			CvPoint2D32f p0 = a_records[0].corners[p];
			CvPoint2D32f p1 = a_records[num_records-1].corners[p];
			CvMat line;
			iaasJoiningLine(p0, p1, &line);
			double dist = iaasPointLineDistance(&line, vp);
			if(dist > dist_th){
				status[p] = 0;
			}
			else {
				counter++;
			}
		}
	}
	return counter;
}


int iaasSelectInFOVFeatures(TrackRecord *a_records, int num_records){
	char *status = a_records[num_records-1].track_status;
	int counter = 0;
	for(int p = 0; p < MAX_CORNERS; p++){
		if(status[p] == 1){
			for(int rec = 1; rec < num_records; rec++){
				CvPoint2D32f p0 = a_records[rec].corners[p];
				if(!iaasPointIsInFOV(p0)){
					status[p] = 0;
					break;
				}
				else {
					if(rec == num_records-1)
						counter++;
				}
			}
		}
	}
	return counter;
}

int iaasSelectCoherentEigvalsFeatures(TrackRecord *a_records){
	char *status = a_records[NUM_RECORDS-1].track_status;
	int counter = 0;
	for(int p = 0; p < MAX_CORNERS; p++){
		if(status[p] == 1){
			for(int rec = 1; rec < NUM_RECORDS; rec++){
				double c0 = a_records[rec-1].contrast[p];
				double c1 = a_records[rec].contrast[p];
				if(c1 > c0){//Two elements in the sequence are not in descending order
					status[p] = 0;
					break;
				}else{
					//Last record, everything went ok
					if(rec == NUM_RECORDS-1)
						counter++;
				}
			}
		}
	}
	return counter;
}

void iaasGetTrackedPoints(TrackRecord *a_records, CvPoint2D32f *points0, CvPoint2D32f *points1, int num_records){
	char *status = a_records[num_records-1].track_status;
	for(int p = 0, j = 0; p < MAX_CORNERS; p++){
		if(status[p] == 1){
			points0[j] = a_records[0].corners[p];
			points1[j] = a_records[num_records-1].corners[p];
			j++;
		}
	}
}

Hom2DVector::Hom2DVector(CvPoint point){
	double *data = new double[3];

	data[0] = point.x;
	data[1] = point.y;
	data[2] = 1.00;
	cvInitMatHeader(&mat1D, 3, 1, CV_64FC1, data);

//	for(int r = 0; r < mat1D.rows; r++){
//		for(int c = 0; c < mat1D.cols; c++){
//			printf("%f ", cvGet2D(&mat1D, r, c).val[0]);
//		}
//		printf("\n");
//	}
//	printf("\n");
}

Hom2DVector::Hom2DVector(CvPoint2D32f point){
	double *data = new double[3] ;

	data[0] = point.x;
	data[1] = point.y;
	data[2] = 1;
	cvInitMatHeader(&mat1D, 3, 1, CV_64FC1, data);
}

double Hom2DVector::getElement(int i){
	assert(i >= 0 && i < 3);

	return mat1D.data.db[i];
}

void Hom2DVector::setElement(int i, double val){
	assert(i >= 0 && i < 3);

	mat1D.data.db[i] = val;
}

void Hom2DVector::Normalize(){
	double *data = mat1D.data.db;

	data[0] = data[0]/data[2];
	data[1] = data[1]/data[2];
	data[2] = data[2]/data[2];

}

CvPoint2D32f Hom2DVector::getCartesianPoint(){
	double *data = mat1D.data.db;
	Normalize();
	return cvPoint2D32f(data[0], data[1]);
}

void Hom2DVector::print(){
	double* data = mat1D.data.db;
	printf("[%.2f %.2f %.2f]'\n", data[0], data[1], data[2]);
}
