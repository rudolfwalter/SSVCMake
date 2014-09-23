macro(SSVCMake_setDefaultSettings)
	message("SSVCMake: setting default settings")

	set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type.")
	set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules/;${CMAKE_MODULE_PATH}")
endmacro(SSVCMake_setDefaultSettings)

macro(SSVCMake_setDefaultFlags)
	message("SSVCMake: setting default flags")

	set(CMAKE_CXX_FLAGS "-std=c++1y -Wall -Wextra -Wpedantic -pthread" CACHE STRING "" FORCE)
	set(CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG -O3" CACHE STRING "" FORCE)
	set(CMAKE_CXX_FLAGS_DEBUG "-fno-omit-frame-pointer -g3 -gdwarf-2" CACHE STRING "" FORCE)

	if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
		set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Og")
	else()
		set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")
	endif()
endmacro(SSVCMake_setDefaultFlags)

macro(SSVCMake_setDefaultGlobs)
	message("SSVCMake: setting default globs")

	set(INC_DIR "include")
	set(SRC_DIR "src")
	file(GLOB_RECURSE SRC_LIST "${INC_DIR}/*" "${SRC_DIR}/*")
endmacro(SSVCMake_setDefaultGlobs)