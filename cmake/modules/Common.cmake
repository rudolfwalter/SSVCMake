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
