# Compiler
FC = gfortran
CXX = clang++  # C++ compiler

# Compiler flags
FCFLAGS = -fopenmp -Wall -Wextra
CXXFLAGS = -std=c++11 `pkg-config --cflags opencv4`  # OpenCV flags for C++
CXXLIBS = `pkg-config --libs opencv4`  # OpenCV libraries

# Source files
SRCS = ifs.f08 functions.f08 rendering.f08
CXXSRCS = pp.cpp  # C++ source file for OpenCV processing

# Object files for all source files
OBJS = $(SRCS:.f08=.o)
CXXOBJS = $(CXXSRCS:.cpp=.o)  # Object files for C++ source files

# Object files specifically for module source files
MODULE_SRCS = functions.f08 rendering.f08
MODULE_OBJS = $(MODULE_SRCS:.f08=.o)

# Executable name
TARGET = ifs

# Default target
all: $(TARGET)

# Rule to link object files to create the executable
$(TARGET): $(OBJS) $(CXXOBJS)
	$(FC) $(FCFLAGS) -o $@ $^ $(CXXLIBS) -lc++

# Rule to compile Fortran source files to object files
%.o: %.f08
	$(FC) $(FCFLAGS) -c $<

# Rule to compile C++ source files to object files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $<

# Dependencies for the main program
ifs.o: $(MODULE_OBJS)

# Rule to clean up object files, module files, and the executable
clean:
	rm -f $(OBJS) $(MODULE_OBJS) $(CXXOBJS) $(TARGET)

# Phony targets
.PHONY: all clean
