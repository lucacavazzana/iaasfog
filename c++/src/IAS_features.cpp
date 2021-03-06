#include "IAS_features.h"

#define NAME_WINDOW "iaasFog"

void FindFeatures(std::vector<std::string> pathImages, std::string pathOutFile, bool verb){
	TrackRecord *a_records;

	IplImage *image0;			// Previous image
	IplImage *image1; 			// Current image

	CvPoint2D32f newCorners[MAX_CORNERS];	// New corners found, keep static
	int newCornersCount;					// number of new corners found

	float *track_errors;
	float *track_contrast;

	char *track_status;
	int key;

	vector<CvPoint2D32f> featuresAlive;
	vector<CvPoint2D32f> tmpFeatures;

	list<featureMovement> listFeatures;

	cvNamedWindow(NAME_WINDOW, CV_WINDOW_AUTOSIZE);

	// Load first image before cycle
#ifdef REVERSE_IMAGE
	image0 = cvLoadImage(pathImages[pathImages.size()-1].c_str(), CV_LOAD_IMAGE_GRAYSCALE);
#else
	image0 = cvLoadImage(pathImages[0].c_str(), CV_LOAD_IMAGE_GRAYSCALE);
#endif

	// Extract features for the first image
	newCornersCount = MAX_CORNERS;					// This value can change

	iaasFindCorners(image0, newCorners, &newCornersCount);

	if(verb)
		cout << "Corners found: " << newCornersCount << endl;

	list<featureMovement>::iterator feat;

#ifdef REVERSE_IMAGE
	for(int frameIndex=pathImages.size()-2; frameIndex >= 0; frameIndex--) {
#else
	for(int frameIndex=1; frameIndex < pathImages.size(); frameIndex++) {
#endif

		// Load new image
		image1 = cvLoadImage(pathImages[frameIndex].c_str(), CV_LOAD_IMAGE_GRAYSCALE);

		// Track NEW features from image0 in image1
		tmpFeatures.reserve(newCornersCount);
		track_errors = new float[newCornersCount];
		track_status = new char[newCornersCount];
		iaasTrackCorners(image0, image1, newCorners, &tmpFeatures[0], track_errors, track_status, newCornersCount);

		int cornersMatching = 0;
		// Count number of corners matching in the second image
		for(int i=0; i<newCornersCount; i++) {
			cornersMatching += track_status[i];
			// Add corner
			if(track_status[i]) {
				featureMovement ft;
#ifdef REVERSE_IMAGE
				ft.startFrame = frameIndex + 1;
#else
				ft.startFrame = frameIndex - 1;
#endif

				ft.positions.push_back(newCorners[i]);
				ft.positions.push_back(tmpFeatures[i]);
				ft.status = NEW;

				// Get contrast from first image
				//ft.contrast.push_back(getAroundContrast(image0, &newCorners[i]));
				//ft.contrast.push_back(getAroundContrast(image1, &tmpFeatures[i]));

				listFeatures.push_back(ft);
			}
		}
		if(verb)
			cout << "New corners matching: " << cornersMatching << endl;

		delete track_errors;
		delete track_status;

		// Track OLD (existing BEFORE image0) features from image0 in image1
		tmpFeatures.reserve(featuresAlive.size());
		track_errors = new float[featuresAlive.size()];
		track_status = new char[featuresAlive.size()];
		iaasTrackCorners(image0, image1, &featuresAlive[0], &tmpFeatures[0], track_errors, track_status, featuresAlive.size());

		// Add new features to features to track
		featuresAlive.clear();

		feat = listFeatures.begin();

		while (feat != listFeatures.end()) {
			bool erase = false;

			// If feature in array is still alive
			if (feat->status == ALIVE) {
				int actualIndex = feat->index;

				erase = !verifyNewFeatureIsOk(feat, tmpFeatures[actualIndex], track_status[actualIndex]);

				if(feat->status == ALIVE) { // Feature is still alive and new point is ok

					// Add new position
					feat->positions.push_back(tmpFeatures[actualIndex]);

					// Add contrast
					//feat->contrast.push_back(getAroundContrast(image1, &tmpFeatures[actualIndex]));
				}

			}
			if(erase) {
				// Delete that feature, return the next feature
				feat = listFeatures.erase(feat);
			}
			else {
				// TODO: save contrast ?

				// Goto the next feature
				feat++;
			}
		}

		feat = listFeatures.begin();
		// Prepare new array of features/point to track in the next frame
		featuresAlive.clear();
		int ind=0;
		while (feat != listFeatures.end()) {
			// If features is not dead (is alive or to add)
			if(feat->status != UNDEAD) {
				feat->index = ind++;										// set new index
				feat->status = ALIVE;										// set all as alive
				int lastElementIndex = feat->positions.size() - 1;
				featuresAlive.push_back(feat->positions[lastElementIndex]);	// get last index
			}
			feat++;
		}

		// Find new features in image1
		newCornersCount = MAX_CORNERS;				// This value can change
		iaasFindCorners(image1, newCorners, &newCornersCount);
		if(verb)
			cout << "Corners found: " << newCornersCount << endl;

		// Delete points too close to others that already exist
		// TODO: tmpFeatures include values not valid (depends on track_status, etc.)
#if Enable_FilterTooClose == 1
		filterFeaturesTooClose(newCorners, &newCornersCount, &tmpFeatures[0], featuresAlive.size());

		// Remove new features too close to already tracked

		feat = listFeatures.begin();
		while(feat != listFeatures.end()) {
			filterFeaturesTooClose(newCorners, &newCornersCount, &feat->positions[0], feat->positions.size());
			feat++;
		}
		tmpFeatures.clear();
#endif

		// Deallocate image0 (not useful anymore)
		cvReleaseImage(&image0);

		// Set previous image (image0) as actual image (image1) for the next cycle
		image0 = image1;

	}

	// Filter features still alive and create array with lines
	int j = 0;
	CvMat *joiningLines = new CvMat[listFeatures.size()];
	image0 = cvLoadImage(pathImages[0].c_str(), CV_LOAD_IMAGE_GRAYSCALE);

	feat = listFeatures.begin();
	while (feat != listFeatures.end()) {
		// If features is not undead (still alive)
		bool erase = false;
		if(feat->status != UNDEAD) {
			erase = !verifyFeatureConsistency(*feat);
		}
		if(erase) {
			feat = listFeatures.erase(feat);
		}
		else {
			joiningLines[j++] = feat->fitLine;
			iaasDrawStraightLine(image0, &feat->fitLine);
			feat++;
		}
	}

#ifdef _DEBUG
	time_t begin, end;
	time(&begin);
#endif

	// Estimate vanishing point
	float distancePercentile;
	CvPoint2D32f vp = iaasFindBestCrossedPointRANSAC(image0, joiningLines, j, &distancePercentile);

#ifdef _DEBUG
	time(&end);
	cout.precision(4);
	cout << "Time elapsed for vanishing point: " << fixed << difftime(end, begin) << " seconds"<< endl;

	cout << "VP: (" << vp.x << ";" << vp.y << ")" << endl;
#endif

	if(verb) {
		drawFeatures(image0, &vp, 1);

		char *outFileName = "beforeFilter.png";
		// Save screenshot to file
		if(!cvSaveImage(outFileName,image0)) printf("Could not save: %s\n",outFileName);

		//cvShowImage(NAME_WINDOW, image0);
		//key = cvWaitKey(0);
	}
		cvReleaseImage(&image0);

	// Remove features too far from vanishing point
	image0 = cvLoadImage(pathImages[0].c_str(), CV_LOAD_IMAGE_GRAYSCALE);

	feat = listFeatures.begin();
	while (feat != listFeatures.end()) {
		// If features is not undead (still alive)
		float distance = iaasPointLineDistance(&feat->fitLine, vp);
		if(distance > distancePercentile) {
			feat = listFeatures.erase(feat);
		}
		else {
			// Estimate positions of feature using vanishing point
			BackToTheFeatures(*feat, &vp);
			float TTI = 0;
			float mean = 0;
#ifdef _DEBUG
			cout << "Time to impact: ";
#endif
			for(int i=0; i < feat->positions.size()-1; i++) {
				TTI = iaasTimeToImpact(vp, feat->positions[i+1], feat->positions[0], i+1);
				mean += TTI;
#ifdef _DEBUG
				cout << TTI << " " << " \t\n ";
#endif
			}
			mean = mean/(feat->positions.size()-1);
#ifdef _DEBUG
			cout << "Mean start: " << mean << endl;
#endif

			// Add time to impact corrected
			for(int i=0; i < feat->positions.size(); i++) {
				feat->timeToImpact.push_back(mean+(float)i/(float)FRAME_RATE);
			}
			iaasDrawStraightLine(image0, &feat->fitLine);
			feat++;
		}
	}

	if(verb) {
		cout << endl << "Total features found: " << listFeatures.size() << endl;
		drawFeatures(image0, &vp, 2);


		char *outFileName = "afterFilter.png";
		// Save screenshot to file
		if(!cvSaveImage(outFileName,image0)) printf("Could not save: %s\n",outFileName);

		//cvShowImage(NAME_WINDOW, image0);
		//key = cvWaitKey(0);
	}
	cvReleaseImage(&image0);

	// Extract contrast for each corner
#ifdef REVERSE_IMAGE
	for(int frameIndex=pathImages.size()-1; frameIndex >= 0; frameIndex--) {
#else
	for(int frameIndex=0; frameIndex < pathImages.size(); frameIndex++) {
#endif
		// Load image
		image0 = cvLoadImage(pathImages[frameIndex].c_str(), CV_LOAD_IMAGE_GRAYSCALE);

		// For each feature
		list<featureMovement>::iterator feat = listFeatures.begin();
		while (feat != listFeatures.end()) {
#ifdef REVERSE_IMAGE
			int firstFeatFrame = feat->startFrame + 1 - feat->positions.size();
			int index = frameIndex -  firstFeatFrame;
			// Invert
			index = feat->positions.size() - index - 1;
#else
			int index = frameIndex - feat->startFrame;
#endif
			// TODO: Choice of algorithm as parameter (Get contrast of point)
			if(index >= 0 && index < feat->positions.size()) {
				int radiusSize = MIN_FRAME_RADIUS;
#if VARIABLE_FRAME_SIZE == 1
				radiusSize = MIN_FRAME_RADIUS + iaasTwoPointsDistance(vp, feat->positions[index])/FRAME_WIDTH*5;
#endif
				float contrast;
				contrast = getRMSContrast(image0, &feat->positions[index], radiusSize);
				feat->contrast.push_back(contrast);
			}
			feat++;
		}

		// Free memory
		cvReleaseImage(&image0);
	}

	image0 = cvLoadImage(pathImages[0].c_str(), CV_LOAD_IMAGE_GRAYSCALE);


#ifdef _DEBUG
	feat = listFeatures.begin();

	// Print contrast from features in images
	int i=0;
	while (feat != listFeatures.end()) {

		cout << "Feature " << i++ << " contrast: ";
		for(int j=0; j<feat->contrast.size(); j++) {
			cout << feat->contrast[j] << "\t";
		}
		iaasDrawFlowFeature(image0, *feat);
		cvShowImage(NAME_WINDOW, image0);
		//key = cvWaitKey(0);
		//cout << endl;
		feat++;
	}
	cvShowImage(NAME_WINDOW, image0);
	key = cvWaitKey(0);
#endif
	cvReleaseImage(&image0);
	image0 = cvLoadImage(pathImages[0].c_str(), CV_LOAD_IMAGE_GRAYSCALE);

	if(verb) {
		//Draw flaw field
		iaasDrawFlowFieldNew(image0, listFeatures, CV_RGB(255, 0, 0));
		drawFeatures(image0, &vp, 1);

		cvShowImage(NAME_WINDOW, image0);
		key = cvWaitKey(0);
	}

	printFeatures(pathOutFile, listFeatures);

	//Releasing Resources
	cvReleaseImage(&image0);
	cvDestroyWindow(NAME_WINDOW);
}

// OLD VERSION
void OldFind_features(std::vector<std::string> pathImages, std::string pathOutFile, bool verb){
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

	for(int track_frame=0; track_frame<(pathImages.size()-1); track_frame++) {
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
		} else {
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
		//cvShowImage(NAME_WINDOW, imageB);
		//key = cvWaitKey(0);
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

			if(verb) {
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

// Save features to file
void printFeatures(std::string filePath, list<featureMovement> listFeatures) {

	// Open file to write
	std::ofstream f_out;
	f_out.open(filePath.c_str(), std::ios::out);

	// If ok write
	if(f_out.is_open()){
		//char *status = a_records[num_records-1].track_status;
		list<featureMovement>::iterator feat = listFeatures.begin();
		while (feat != listFeatures.end()) {
			f_out << feat->startFrame << "\t" << feat->contrast.size() << "\t";
			for(int rec = 0; rec < feat->contrast.size(); rec++) {
				f_out << feat->positions[rec].x << "\t"<< feat->positions[rec].y << "\t" << feat->contrast[rec] << "\t";
				//if(rec < feat->contrast.size() - 1)
					f_out << feat->timeToImpact[rec] << "\t";
			}
			f_out << std::endl;
			feat++;
		}
	}
	f_out.close();
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
