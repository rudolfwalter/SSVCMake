macro(SSVCMake_setForceCacheIfNull mVar mX)
#{
	if("${${mVar}}" STREQUAL "")	
	#{
		message("SSVCMake: ${mVar} was null, setting it to ${mX}")
		set("${mVar}" "${mX}" CACHE STRING "" FORCE)
	#}
	else()
	#{
		message("SSVCMake: ${mVar} was already set to: ${${mVar}}")
	#}
	endif()

	if("${SSVCMAKE_FORCE_ALWAYS}")
	#{
		message("SSVCMake: ${mVar} forced to ${mX}")
		set("${mVar}" "${mX}" CACHE STRING "" FORCE)
	#}
	endif()
#}
endmacro()



macro(SSVCMake_setDefaultSettings)
#{
	message("SSVCMake: setting default settings")

	SSVCMake_setForceCacheIfNull(CMAKE_BUILD_TYPE Release)

	set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules/;${CMAKE_MODULE_PATH}")
	
	set(INC_DIR "include" CACHE STRING "")
	set(SRC_DIR "src" CACHE STRING "")

	include_directories("./")
	include_directories("./${INC_DIR}")
#}
endmacro()



macro(SSVCMake_setDefaultFlags)
#{
	message("SSVCMake: setting default flags")

	SSVCMake_setForceCacheIfNull(CMAKE_CXX_FLAGS "-std=c++1y -Wall -Wextra -Wpedantic -pthread -Wundef -Wshadow -Wpointer-arith -Wcast-align -Wwrite-strings -Wunreachable-code")
	SSVCMake_setForceCacheIfNull(CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG -O3")
	SSVCMake_setForceCacheIfNull(SSVCMAKE_CXX_FLAGS_DEBUG "-fno-omit-frame-pointer -g3")
	
	if("${SSVCMAKE_USE_CLANG}")
	#{
		message("SSVCMake: using clang for compilation")
		set(CMAKE_C_COMPILER "/usr/bin/clang")
		set(CMAKE_CXX_COMPILER "/usr/bin/clang++")
		set(CMAKE_CXX_FLAGS_DEBUG "${SSVCMAKE_CXX_FLAGS_DEBUG} -O0")
	#}
	else()
	#{
		message("SSVCMake: using gcc for compilation")
		set(CMAKE_C_COMPILER "/usr/bin/gcc")
		set(CMAKE_CXX_COMPILER "/usr/bin/g++")
		set(CMAKE_CXX_FLAGS_DEBUG "${SSVCMAKE_CXX_FLAGS_DEBUG} -Og")
	#}
	endif()

	if("${SSVCMAKE_PROFILE_COMPILATION}")
	#{
		message("SSVCMake: profiling compilation")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -v -ftime-report")
	#}
	endif()
#}
endmacro()



macro(SSVCMake_setDefaultGlobs)
#{
	message("SSVCMake: setting default globs")	
	file(GLOB_RECURSE SRC_LIST "${INC_DIR}/*" "${SRC_DIR}/*")
#}
endmacro(SSVCMake_setDefaultGlobs)



macro(SSVCMake_findExtlib mExtlib)
#{
	message("SSVCMake: finding ${mExtlib}")

	set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/extlibs/${mExtlib}/cmake/modules/;${CMAKE_MODULE_PATH}")
	find_package("${mExtlib}" REQUIRED)
	string(TOUPPER "${mExtlib}" ${mExtlib}_UPPER)	
	include_directories("${${${mExtlib}_UPPER}_INCLUDE_DIR}")
#}
endmacro()



macro(SSVCMake_setDefaults)
#{
	message("SSVCMake: setting all defaults")

	SSVCMake_setDefaultSettings()
	SSVCMake_setDefaultFlags()
	SSVCMake_setDefaultGlobs()
#}
endmacro()



macro(SSVCMake_findSFML)
#{
	message("SSVCMake: finding SFML")

	set(SFML_STATIC_LIBRARIES FALSE CACHE BOOL "Look for static SFML libraries.")
	find_package(SFML 2.1 COMPONENTS audio graphics window system network)

	if(NOT SFML_FOUND)
	#{
		set(SFML_INCLUDE_DIR "" CACHE STRING "SFML2 include directory")
		set(SFML_SYSTEM_LIBRARY "" CACHE STRING "SFML2 System library file")
		set(SFML_WINDOW_LIBRARY "" CACHE STRING "SFML2 Window library file")
		set(SFML_GRAPHICS_LIBRARY "" CACHE STRING "SFML2 Graphics library file")
		set(SFML_NETWORK_LIBRARY "" CACHE STRING "SFML2 Network library file")
		set(SFML_AUDIO_LIBRARY "" CACHE STRING "SFML2 Audio library file")
		message("\n-> SFML directory not found. Set include and libraries manually.")
	#}
	endif()

	include_directories("${SFML_INCLUDE_DIR}")
#}
endmacro()



macro(SSVCMake_linkSFML)
#{
	message("SSVCMake: linking SFML")

	target_link_libraries(${PROJECT_NAME} ${SFML_AUDIO_LIBRARY})
	target_link_libraries(${PROJECT_NAME} ${SFML_GRAPHICS_LIBRARY})
	target_link_libraries(${PROJECT_NAME} ${SFML_WINDOW_LIBRARY})
	target_link_libraries(${PROJECT_NAME} ${SFML_SYSTEM_LIBRARY})
	target_link_libraries(${PROJECT_NAME} ${SFML_NETWORK_LIBRARY})
#}
endmacro()



macro(SSVCMake_setAndInstallHeaderOnly)
#{
	message("SSVCMake: setting up and installing as header-only library")

	add_library(HEADER_ONLY_TARGET STATIC ${SRC_LIST})
	set_target_properties(HEADER_ONLY_TARGET PROPERTIES LINKER_LANGUAGE CXX)
	install(DIRECTORY ${INC_DIR} DESTINATION .)
#}
endmacro()