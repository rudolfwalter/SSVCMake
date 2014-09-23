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

macro(SSVCMake_findExtlib mExtlib)
	message("SSVCMake: finding ${mExtlib}")

	set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/extlibs/${mExtlib}/cmake/modules/;${CMAKE_MODULE_PATH}")
	find_package("${mExtlib}" REQUIRED)
endmacro(SSVCMake_findExtlib)

macro(SSVCMake_setDefaults)
	message("SSVCMake: setting all defaults")

	SSVCMake_setDefaultSettings()
	SSVCMake_setDefaultFlags()
	SSVCMake_setDefaultGlobs()
endmacro(SSVCMake_setDefaults)

macro(SSVCMake_findSFML)
	message("SSVCMake: finding SFML")

	set(SFML_STATIC_LIBRARIES FALSE CACHE BOOL "Look for static SFML libraries.")
	find_package(SFML 2.1 COMPONENTS audio graphics window system network)
	if(NOT SFML_FOUND)
		set(SFML_INCLUDE_DIR "" CACHE STRING "SFML2 include directory")
		set(SFML_SYSTEM_LIBRARY "" CACHE STRING "SFML2 System library file")
		set(SFML_WINDOW_LIBRARY "" CACHE STRING "SFML2 Window library file")
		set(SFML_GRAPHICS_LIBRARY "" CACHE STRING "SFML2 Graphics library file")
		set(SFML_NETWORK_LIBRARY "" CACHE STRING "SFML2 Network library file")
		set(SFML_AUDIO_LIBRARY "" CACHE STRING "SFML2 Audio library file")
		message("\n-> SFML directory not found. Set include and libraries manually.")
	endif()
endmacro(SSVCMake_findSFML)