#include "IAS_features.h"

#define NAME_WINDOW "^0^"


void Find_features(std::vector<std::string> pathImages, std::string pathOutFile, bool verb){
	TrackRecord *a_records;
	IplImage *imageA, *imageB, *image1, *image0 /*,*image*/;
	CvPoint2D32f *cornersA, *cornersB;
	float *track_errors;
	float *track_contrast;
	int max_corners, corner_count;
	char *track_status;
	int key;

	cvNamedWindow(NAME_WINDOW, CV_WINDOW_AUTOSIZE);

	image0 = cvLoadImage(pathImages[0].c_str(), CV_LOAD_IMAGE_UNCHANGED);
	image1 = cvLoadImage(pathImages[0].c_str(), CV_LOAD_IMAGE_UNCHANGED);

	//Allocate Track Record space
	a_records = new TrackRecord[pathImages.size()];

	for(int track_frame=0; track_frame<(pathImages.size()-1); track_frame++){
		int frameA, frameB;

		frameA = track_frame;
		frameB = track_frame+1;

		//Open 1st frame
		imageA = cvLoadImage(pathImages[frameA].c_str(), CV_LOAD_IMAGE_GRAYSCALE);

#ifdef _DEBUG
		if(track_frame == 0){
			cvShowImage(NAME_WINDOW, imageA);
			key = cvWaitKey(0);
		}
#endif

		//At the beginning of the tracking sequence find new corners
		if(track_frame == 0){
			max_corners = MAX_CORNERS;
			cornersA = new CvPoint2D32f[max_corners];
			corner_count = max_corners;//This value can change
			iaasFindCorners(imageA, cornersA, &corner_count);
			//std::cout << "Find_features --- dopo iaasFindCorners --- corner_count: " << corner_count << std::endl;
		}else{
			//Size of new arrays
			max_corners = iaasNumberFoundCorners(track_status, corner_count);
			//Fill cornerA
			cornersA = new CvPoint2D32f[max_corners];
			iaasCopyFoundCorners(cornersA, cornersB, track_status, corner_count);
			//Used to iterate on array
			corner_count = max_corners;
		}

		//Open 2nd frame
		imageB = cvLoadImage(pathImages[frameB].c_str(), CV_LOAD_IMAGE_GRAYSCALE);

#ifdef _DEBUG
		cvShowImage(NAME_WINDOW, imageB);
		key = cvWaitKey(0);
#endif

		//Track corners in 2nd frame
		cornersB = new CvPoint2D32f[max_corners];
		track_errors = new float[max_corners];
		track_status = new char[max_corners];
		track_contrast = new float[max_corners];
		iaasTrackCorners(imageA, imageB, cornersA, cornersB, track_errors, track_status, corner_count);

		//Store minimum eigenvalues
		iaasGetACMinEigVals(imageA, cornersA, track_status, corner_count, track_contrast);

		//Store tracking results
		iaasStoreTrackRecord(a_records, track_frame, cornersA, track_status, track_contrast);

		//Draw single tracking flaw field
		iaasDrawFlowField(image0, cornersA, cornersB, corner_count, track_status, CV_RGB(255/(track_frame+1),0,0));

		//Last tracking took place

		//Points in cornersB must be stored
		if(track_frame == pathImages.size()-2){
			//Store last tracking results
			max_corners = iaasNumberFoundCorners(track_status, corner_count);
			//std::cout << "Find_features --- dopo iaasNumberFoundCorners --- corner_count: " << corner_count << std::endl;
			cornersA = new CvPoint2D32f[max_corners];
			iaasCopyFoundCorners(cornersA, cornersB, track_status, corner_count);
			//Store minimum eigenvalues
			iaasGetACMinEigVals(imageA, cornersA, track_status, corner_count, track_contrast);
			//Store tracking results
			iaasStoreTrackRecord(a_records, track_frame+1, cornersA, track_status, track_contrast);

			//std::cout << "After iaasStoreTrackRecord" << std::endl;
			//Selection of features and
			//vanishing point estimation can take place
			int sel_corners;
			CvPoint2D32f vp;
			char *status;

			//Free resources
			delete[] cornersA, cornersB, track_status, track_errors, track_contrast;
			//std::cout << "After delete" << std::endl;

			//Select corners sequences according to some criteria

			//Select only those features whose path stays in image
			sel_corners = iaasSelectInFOVFeatures(a_records, pathImages.size());
			//std::cout << "Find_features --- dopo iaasSelectInFOVFeatures --- sel_corners: " << sel_corners << std::endl;

			if(pathImages.size() > 2){
				//Select only those features which approximately move
				//always in the same direction
				sel_corners = iaasSelectCoherentMotionFeatures(a_records, pathImages.size());
				//std::cout << "Find_features --- dopo iaasSelectCoherentMotionFeatures --- sel_corners: " << sel_corners << std::endl;
			}

			//Get selected corners only in first and last array
			cornersA = new CvPoint2D32f[sel_corners];
			cornersB = new CvPoint2D32f[sel_corners];
			iaasGetTrackedPoints(a_records, cornersA, cornersB, pathImages.size());

			//First vp estimation
			int patchSize = 20;
			vp = iaasHoughMostCrossedPoint(cornersA, cornersB, sel_corners, true, image0->width, image0->height, patchSize);

			//std::cout << "Find_features --- dopo 1a stima vp --- sel_corners: " << sel_corners << std::endl;

			//Filter too distant lines
			sel_corners = iaasSelectCloseFlowVectors(a_records, vp, pathImages.size(), patchSize);
			//std::cout << "Find_features --- dopo iaasSelectCloseFlowVectors --- sel_corners: " << sel_corners << std::endl;

			if (verb)
				std::cout << "Find_features: " << sel_corners << " features found." << std::endl;

			//Get selected corners only in first and last array
			iaasGetTrackedPoints(a_records, cornersA, cornersB, pathImages.size());

			//Re-estimate vanishing point
			//Extract minimum distant point from lines joining cornersA and cornersB
			vp = iaasMinimumDistantPoint(cornersA, cornersB, sel_corners);

			if(verb)
				std::cout << "Vanishing point: " << vp.x << "  " << vp.y << std::endl;

			//write a_records on file...
			Print_vp_and_features(pathOutFile, pathImages.size(), vp, a_records);

			//Compute mean time to impact
			//double avg_tti = iaasMeanTimeToImpact(vp, cornersA, cornersB, sel_corners);

			if(verb){
				//Draw flaw field
				iaasDrawFlowField(image1, cornersA, cornersB, sel_corners, track_status, CV_RGB(255, 0, 0));

				//Draw vanishing point
				cvCircle(image1, cvPoint(cvRound(vp.x), cvRound(vp.y)), 2, CV_RGB(255, 255, 255));

				cvShowImage(NAME_WINDOW, image1);
				key = cvWaitKey(0);
			}

			//Attach images and diplay mean time to impact
			//image = iaasAddImage(image0, image1);
			//image = iaasAddTTIDisplay(image, avg_tti);

			//Free resources
			delete[] cornersA, cornersB;
		}

	}

	//Releasing Resources
	//cvReleaseImage(&image);
	cvReleaseImage(&image0);
	cvReleaseImage(&image1);
	cvReleaseImage(&imageA);
	cvReleaseImage(&imageB);
	cvDestroyWindow(NAME_WINDOW);
}

void Print_vp_and_features(std::string filePath, int num_records, CvPoint2D32f vp, TrackRecord *a_records){
	std::ofstream f_out;
	f_out.open(filePath.c_str(), std::ios::out);
	if(f_out.is_open()){
		char *status = a_records[num_records-1].track_status;

		f_out << "vanishing point: (" << vp.x << "," << vp.y << ")" << std::endl;
		f_out << std::endl;
		for(int f = 0; f < MAX_CORNERS; f++){
			if(status[f] == 1){
				for(int rec = 0; rec < num_records; rec++){
					f_out << "(" << a_records[rec].corners[f].x << "," << a_records[rec].corners[f].y << ")\t";
				}
				f_out << std::endl;
			}
		}
	}
	f_out.close();
}


void Extract_features_file(std::string filePath, std::vector<std::vector<std::vector<double> > > *feat_coord, std::vector<double> *vp){
	std::ifstream f_in;
	f_in.open(filePath.c_str(), std::ios::in);
	if(f_in.is_open()){
		std::string lineF;
		double x, y;
		int pos_o, pos_c, pos_v, pos_prec;
		int nIm;

		getline(f_in, lineF);
		//std::cout << "Extract_features_file --- lineF: " << lineF << std::endl;
		if(lineF.find("vanishing point:") != -1){
			//std::cout << "Extract_features_file --- if vanishin point" << std::endl;
			pos_o = lineF.find("(");
			pos_v = lineF.find(",", pos_o);
			pos_c = lineF.find(")", pos_v);
			if((pos_o!=-1) && (pos_v!=-1) && (pos_c!=-1)){
				//std::cout << "Extract_features_file --- if (,)" << std::endl;
				vp->push_back(atof(lineF.substr(pos_o+1, pos_v-(pos_o+1)).c_str()));
				vp->push_back(atof(lineF.substr(pos_v+1, pos_c-(pos_v+1)).c_str()));
				vp->push_back(1);
				//std::cout << "vp->size(): " << vp->size() << std::endl;
			}
		}

		std::vector<double> coord;
		std::vector<std::vector<double> > v_nIm;
		while(!f_in.eof()){
			getline(f_in, lineF);
			pos_prec = 0;
			pos_o=-2; pos_c=-2; pos_v=-2;
			nIm = 0;
			while((pos_o!=-1) && (pos_v!=-1) && (pos_c!=-1)){
				pos_o=lineF.find("(", pos_prec);
				pos_v = lineF.find(",", pos_o);
				pos_c = lineF.find(")", pos_v);
				pos_prec = pos_c;
				if((pos_o!=-1) && (pos_v!=-1) && (pos_c!=-1)){
					coord.clear();
					x = atof(lineF.substr(pos_o+1, pos_v-(pos_o+1)).c_str());
					y = atof(lineF.substr(pos_v+1, pos_c-(pos_v+1)).c_str());
					//Homogeneus coordinates
					coord.push_back(x);
					coord.push_back(y);
					coord.push_back(1);
					if(feat_coord->size()<(nIm+1)){
						//std::cout << "x: " << x << "\ty: " << y << std::endl;
						v_nIm.clear();
						v_nIm.push_back(coord);
						feat_coord->push_back(v_nIm);
					}else{
						(*feat_coord)[nIm].push_back(coord);
					}
				}
				nIm++;
			}
		}
	}
	f_in.close();
}
