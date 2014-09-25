macro(SSVCMake_setDefaultSettings)
	message("SSVCMake: setting default settings")

	set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type.")
	set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules/;${CMAKE_MODULE_PATH}")
	set(INC_DIR "include")
	set(SRC_DIR "src")
	include_directories("./")
	include_directories("./${INC_DIR}")
endmacro(SSVCMake_setDefaultSettings)

macro(SSVCMake_setDefaultFlags)
	message("SSVCMake: setting default flags")

	set(CMAKE_CXX_FLAGS "-std=c++1y -Wall -Wextra -Wpedantic -pthread" CACHE STRING "")
	set(CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG -O3" CACHE STRING "")
	set(CMAKE_CXX_FLAGS_DEBUG "-fno-omit-frame-pointer -g3 -gdwarf-2" CACHE STRING "")

	if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
		set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Og")
	else()
		set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")
	endif()
endmacro(SSVCMake_setDefaultFlags)

macro(SSVCMake_setDefaultGlobs)
	message("SSVCMake: setting default globs")

	
	file(GLOB_RECURSE SRC_LIST "${INC_DIR}/*" "${SRC_DIR}/*")
endmacro(SSVCMake_setDefaultGlobs)

macro(SSVCMake_findExtlib mExtlib)
	message("SSVCMake: finding ${mExtlib}")

	set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/extlibs/${mExtlib}/cmake/modules/;${CMAKE_MODULE_PATH}")
	find_package("${mExtlib}" REQUIRED)
	string(TOUPPER "${mExtlib}" ${mExtlib}_UPPER)	
	include_directories("${${${mExtlib}_UPPER}_INCLUDE_DIR}")
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
	include_directories("${SFML_INCLUDE_DIR}")
endmacro(SSVCMake_findSFML)

macro(SSVCMake_linkSFML)
	message("SSVCMake: linking SFML")

	target_link_libraries(${PROJECT_NAME} ${SFML_AUDIO_LIBRARY})
	target_link_libraries(${PROJECT_NAME} ${SFML_GRAPHICS_LIBRARY})
	target_link_libraries(${PROJECT_NAME} ${SFML_WINDOW_LIBRARY})
	target_link_libraries(${PROJECT_NAME} ${SFML_SYSTEM_LIBRARY})
	target_link_libraries(${PROJECT_NAME} ${SFML_NETWORK_LIBRARY})
endmacro(SSVCMake_linkSFML)

macro(SSVCMake_setAndInstallHeaderOnly)
	message("SSVCMake: setting up and installing as header-only library")

	add_library(HEADER_ONLY_TARGET STATIC ${SRC_LIST})
	set_target_properties(HEADER_ONLY_TARGET PROPERTIES LINKER_LANGUAGE CXX)
	install(DIRECTORY ${INC_DIR} DESTINATION .)
endmacro(SSVCMake_setAndInstallHeaderOnly)
