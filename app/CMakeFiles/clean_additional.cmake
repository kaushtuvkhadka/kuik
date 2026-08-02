# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Release")
  file(REMOVE_RECURSE
  "CMakeFiles\\KUik_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\KUik_autogen.dir\\ParseCache.txt"
  "KUik_autogen"
  )
endif()
