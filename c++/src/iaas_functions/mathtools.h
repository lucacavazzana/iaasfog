/*
 * math.h
 *
 *  Created on: Jan 22, 2009
 *      Author: Alessandro Stranieri
 */
/**
 * @file mathtools.h
 *
 * Header file for mathematical utilities.
 */

#ifndef MATH_H_
#define MATH_H_

/**
 * Returns the square of a number
 *
 * @param value The input
 * @return The square of the input
 */
template <class T> T iaasSquare(T a){
	return a*a;
}

/**
 * Return the max of a 1D array
 * @param array An array
 * @param size Size of the array
 * @return max(array)
 */
template <class T> T iaasMaxArray1D(T* array, int size){
	T result = array[0];
	for(int i = 1; i < size; i++){
		result = array[i] > result ? array[i] : result;
	}
	return result;
}

/**
 * Return the index of the first largest value in the array
 * @param array An array
 * @param size Size of the array
 * @param x Contains argmax(array)
 */
template <class T> void iaasArgMaxArray1D(T* array, int size, int *x){
	T max = iaasMaxArray1D<T>(array, size);
	for(int i = 1; i < size; i++){
		if(array[i] == max){
			*x = i;
			return;
		}
	}
}

/**
 * Returns the max of a 2D array.
 *
 * @param array A 2D array
 * @param rows Number of rows
 * @param cols Numeber of columns
 * @return max(array)
 */
template <class T> T iaasMaxArray2D(T **array, int rows, int cols){
	T result = iaasMaxArray1D<T>(array[0], cols);
	for(int i = 1; i < rows; i++){
		T temp = iaasMaxArray1D<T>(array[i], cols);
		result = temp > result ? temp : result;
	}
	return result;
}

/**
 * Returns the indexes of the first largest value in a 2D array
 *
 * @param array A 2D array
 * @param rows Number of rows
 * @param cols Number of columns
 * @param row Stores the row index of argmax
 * @param col Stores the column index of argmax
 */
template <class T> void iaasArgMaxArray2D(T** array, int rows, int cols, int *row, int *col){
	T value = iaasMaxArray1D<T>(array[0], cols);
	iaasArgMaxArray1D<T>(array[0], cols, row);
	for(int i = 1; i < rows; i++){
		T temp = iaasMaxArray1D<T>(array[i], cols);
		if(temp > value){
			value = temp;
			*row = i; iaasArgMaxArray1D<T>(array[i], cols, col);
		}
	}
}

template <class T> bool iaasIsInClosedInterval(T value, double lbound, double rbound){
	if(value >= lbound && value <= rbound)
		return true;
	else
		return false;
}

/**
 * Randomly swaps the element in an array.
 *
 * @param array The array
 * @param size Size of the array
 */
template <class T> void iaasShuffleArray(T *array, int size){
	//Random generator
	CvRNG seed = cvRNG(size);

	for(int i = 0; i < size; i++){
		int pos = cvRandInt(&seed)%size;
		//Swap
		T temp = array[i];
		array[i] = array[pos];
		array[pos] = temp;
	}
}

/**
 * Compute the median of all array elements.
 *
 * @param array The array
 * @param size Size of the array
 * @return The median of array elements
 */
template <class T> double iaasArrayMedian(T* array, int size)
{
	//Order the array
	for(int i = 0; i < size-1; i++){
		for(int j = 1; j < size; j++){
			if(array[i] > array[j]){
				T temp = array[i];
				array[i] = array[j];
				array[j] = temp;
			}
		}
	}
	return array[size/2];
}

/**
 * Computes the mean of all array elements.
 *
 * @param array The array
 * @param size Size of the array
 * @return The mean of array elements
 */
template <class T> double iaasArrayMean(T* array, int size){
	double sum, mean = 0;
	for(int i = 0; i < size; i++){
		sum += array[i];
	}
	mean = sum/size;
	return mean;
}

/**
 * Returns true if value is positive.
 * @param value A number
 * @return True if value > 0
 */
template <class T> bool sign(T value){
	return value > 0;
}

#endif /* MATH_H_ */
