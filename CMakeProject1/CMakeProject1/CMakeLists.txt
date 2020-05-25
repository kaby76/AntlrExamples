# CMakeList.txt : CMake project for CMakeProject1, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.8)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
set(CMAKE_CXX_STANDARD 11)

# required if linking to static library
#add_definitions(-DANTLR4CPP_STATIC)
# using /MD flag for antlr4_runtime (for Visual C++ compilers only)
set(ANTLR4_WITH_STATIC_CRT OFF)
include(ExternalAntlr4Cpp)
# add antrl4cpp artifacts to project environment
include_directories(${ANTLR4_INCLUDE_DIRS})

set(ANTLR_EXECUTABLE "c:/program files/java/javalib/antlr-4.8-complete.jar")
find_package(ANTLR REQUIRED)

antlr_target(arithmetic arithmetic.g4
    PACKAGE CMakeProject1
    LISTENER
    )

# include generated files in project environment
include_directories(${ANTLR_arithmetic_OUTPUT_DIR})

# add generated grammar to demo binary target
add_executable(CMakeProject1
Program.cpp
CMakeProject1.cpp
CMakeProject1.h
ErrorListener.cpp
ErrorListener.h
Output.cpp
Output.h
${ANTLR_arithmetic_CXX_OUTPUTS})

target_link_libraries(CMakeProject1 antlr4_shared)
add_custom_command(TARGET CMakeProject1
                   POST_BUILD
                   COMMAND ${CMAKE_COMMAND}
                           -E copy ${ANTLR4_RUNTIME_LIBRARIES} .
                   WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
