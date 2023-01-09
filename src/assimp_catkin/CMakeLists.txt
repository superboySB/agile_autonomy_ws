cmake_minimum_required(VERSION 2.8.3)
project(assimp_catkin)

find_package(catkin_simple REQUIRED)
catkin_simple()

include(ExternalProject)

file(MAKE_DIRECTORY ${CATKIN_DEVEL_PREFIX}/include)

ExternalProject_Add(
  assimp_src
  URL https://github.com/assimp/assimp/archive/v4.0.1.zip
  URL_MD5 cb1dfa82c6e27f97e8672e5483853d39
  UPDATE_COMMAND ""
  CONFIGURE_COMMAND cd ../assimp_src &&
     cmake . -G "Unix Makefiles"
       -DCMAKE_INSTALL_PREFIX:PATH=${CATKIN_DEVEL_PREFIX}
       -DBUILD_SHARED_LIBS:BOOL=true
       -DCMAKE_BUILD_TYPE:STRING=Release
       -DASSIMP_BUILD_ASSIMP_TOOLS=OFF
       -DASSIMP_BUILD_SAMPLES=OFF
       -DASSIMP_BUILD_TESTS=OFF
       -DASSIMP_COVERALLS=OFF
  BUILD_COMMAND cd ../assimp_src && make
  INSTALL_COMMAND cd ../assimp_src && make install
)

cs_add_library(${PROJECT_NAME} src/dependency_tracker.cc)
add_dependencies(${PROJECT_NAME} assimp_src)
target_link_libraries(${PROJECT_NAME} 
  ${CATKIN_DEVEL_PREFIX}/lib/libassimp${CMAKE_SHARED_LIBRARY_SUFFIX})

cs_install()

cs_export(INCLUDE_DIRS ${CATKIN_DEVEL_PREFIX}/include
  CFG_EXTRAS assimp-extras.cmake)
