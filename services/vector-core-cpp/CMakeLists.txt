cmake_minimum_required(VERSION 3.10)
project(ACOS_VectorCore)

set(CMAKE_CXX_STANDARD 17)

include_directories(include)
add_executable(vector_core src/main.cpp)

# Core High-Performance Dependencies
find_package(OpenSSL REQUIRED)
target_link_libraries(vector_core OpenSSL::SSL)
