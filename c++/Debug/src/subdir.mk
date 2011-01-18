################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/Find_features.cpp \
../src/IAS_features.cpp \
../src/matlabfunctions.cpp 

OBJS += \
./src/Find_features.o \
./src/IAS_features.o \
./src/matlabfunctions.o 

CPP_DEPS += \
./src/Find_features.d \
./src/IAS_features.d \
./src/matlabfunctions.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -D_DEBUG -I/usr/local/include/opencv -I/usr/local/include/opencv2 -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


