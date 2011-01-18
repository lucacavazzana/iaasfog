################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/iaas_functions/algorithms.cpp \
../src/iaas_functions/datatypes.cpp \
../src/iaas_functions/imagetools.cpp \
../src/iaas_functions/logging.cpp \
../src/iaas_functions/mathtools.cpp 

OBJS += \
./src/iaas_functions/algorithms.o \
./src/iaas_functions/datatypes.o \
./src/iaas_functions/imagetools.o \
./src/iaas_functions/logging.o \
./src/iaas_functions/mathtools.o 

CPP_DEPS += \
./src/iaas_functions/algorithms.d \
./src/iaas_functions/datatypes.d \
./src/iaas_functions/imagetools.d \
./src/iaas_functions/logging.d \
./src/iaas_functions/mathtools.d 


# Each subdirectory must supply rules for building sources it contributes
src/iaas_functions/%.o: ../src/iaas_functions/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -D_DEBUG -I/usr/local/include/opencv -I/usr/local/include/opencv2 -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


