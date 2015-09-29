# Adapted from Louis Dionne's hana CMake files.

# Copyright Louis Dionne 2015
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.md or copy at http://boost.org/LICENSE_1_0.txt)

# Initializes the `PROJECT_NAME_UPPER` variable.
# It contains the project name, uppercase.
macro(vrm_cmake_init_project_name_upper)
#{
    set(PROJECT_NAME_UPPER "")
    string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
#}
endmacro()

# Initializes the `${PROJECT_NAME_UPPER}_SOURCE_DIR` variable.
macro(vrm_cmake_init_project_source_dir)
#{
    set("${PROJECT_NAME_UPPER}_SOURCE_DIR" "${CMAKE_CURRENT_SOURCE_DIR}")
#}
endmacro()

# Initializes common data for a C++ CMake project.
# * Project name and uppercase project name.
# * Appends common module paths.
# * Enables testing.
macro(vrm_cmake_init_project project_name)
#{
    project(${project_name} CXX)
    enable_testing()

    vrm_cmake_init_project_name_upper()
    vrm_cmake_init_project_source_dir()

    list(APPEND CMAKE_MODULE_PATH
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")
#}
endmacro()

# Initializes an option `{PROJECT_NAME_UPPER}_${name}`.
# Description `desc` and default value `default`.
macro(vrm_cmake_project_option name desc default)
#{
    option("{PROJECT_NAME_UPPER}_${name}" desc default)
#}
endmacro()

# Includes a CMake module only once.
macro(vrm_cmake_include_once module flag)
#{
    if(${flag})
    #{

    #}
    else()
    #{
        include(${module})
        set(${flag} true)
    #}
    endif()
#}
endmacro()

# Includes `CheckCXXCompilerFlag` if required.
macro(vrm_cmake_init_compiler_flag_check)
#{
    vrm_cmake_include_once(CheckCXXCompilerFlag
        VRM_CMAKE_COMPILER_FLAG_CHECK_INCLUDED)
#}
endmacro()

# Creates `testname` variable that checks for compiler flag `flag`.
# The flag is enabled, if possible.
macro(vrm_cmake_add_compiler_flag testname flag)
#{
    set(PROJECT_TESTNAME "${PROJECT_NAME_UPPER}_${testname}")

    vrm_cmake_init_compiler_flag_check()
    check_cxx_compiler_flag(${flag} ${PROJECT_TESTNAME})

    if(${PROJECT_TESTNAME})
    #{
        add_compile_options(${flag})
    #}
    endif()
#}
endmacro()

# Creates an install target that installs the project as an header-only library.
# Library files are in the list `file_list`.
# The `src_dir` is copied to `dest_dir`.
macro(vrm_cmake_header_only_install file_list src_dir dest_dir)
#{
    set_source_files_properties(${file_list} PROPERTIES HEADER_FILE_ONLY 1)
    add_library(HEADER_ONLY_TARGET STATIC ${file_list})
    set_target_properties(HEADER_ONLY_TARGET PROPERTIES LINKER_LANGUAGE CXX)
    install(DIRECTORY ${src_dir} DESTINATION ${dest_dir})
#}
endmacro()

# Creates an install target that installs the project as an header-only library.
# Automatically globs `src_dir`.
macro(vrm_cmake_header_only_install_glob src_dir dest_dir)
#{
    # Glob library header files.
    file(GLOB_RECURSE INSTALL_FILES_LIST "${src_dir}/*")

    # Create header-only install target.
    vrm_cmake_header_only_install("${INSTALL_FILES_LIST}" "${src_dir}" "${dest_dir}")
#}
endmacro()

# Creates a `check` target, intended for tests and examples.
# Uses CTest.
macro(vrm_check_target)
#{
    add_custom_target(check
        COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Build and then run all the tests.")
#}
endmacro()

# Return an unique name for a file target.
# Replaces slashes with `.`, assumes `.cpp` if the extension is not specified.
function(vrm_cmake_target_name_for out file)
#{
    if(NOT ARGV2)
        set(_extension ".cpp")
    else()
        set(_extension "${ARGV2}")
    endif()

    file(RELATIVE_PATH _relative "${PROJECT_NAME_UPPER}_SOURCE_DIR" ${file})
    string(REPLACE "${_extension}" "" _name ${_relative})
    string(REGEX REPLACE "/" "." _name ${_name})
    set(${out} "${_name}" PARENT_SCOPE)
#}
endfunction()

# Look for valgrind, if memcheck is enabled.
macro(vrm_cmake_add_option_memcheck)
#{
    vrm_cmake_project_option(ENABLE_MEMCHECK "Run the unit tests and examples under Valgrind if it is found." OFF)

    if("${PROJECT_NAME_UPPER}_ENABLE_MEMCHECK")
    #{
        find_package(Valgrind REQUIRED)
    #}
    endif()
#}
endmacro()

# Disable exceptions if the user wants to.
macro(vrm_cmake_add_option_no_exceptions)
#{
    vrm_cmake_project_option(DISABLE_EXCEPTIONS "Build with exceptions disabled." OFF)

    if("${PROJECT_NAME_UPPER}_DISABLE_EXCEPTIONS")
    #{
        vrm_cmake_add_compiler_flag(HAS_FNO_EXCEPTIONS -fno-exceptions)
    #}
    endif()
#}
endmacro()

# Enable `-Werror` if the user wants to.
macro(vrm_cmake_add_option_werror)
#{
    vrm_cmake_project_option(ENABLE_WERROR "Fail and stop if a warning is triggered." OFF)

    if("${PROJECT_NAME_UPPER}_ENABLE_WERROR")
    #{
        vrm_cmake_add_compiler_flag(HAS_WERROR -Werror)
        vrm_cmake_add_compiler_flag(HAS_WX -WX)
    #}
    endif()
#}
endmacro()

# Creates a test called `name` which runs the given `command` with the given arguments.
# Uses Valgrind if memcheck is enabled.
function(vrm_cmake_add_test name)
#{
    if("${PROJECT_NAME_UPPER}_ENABLE_MEMCHECK")
    #{
        add_test(${name} ${Valgrind_EXECUTABLE} --leak-check=full --error-exitcode=1 ${ARGN})
    #}
    else()
    #{
        add_test(${name} ${ARGN})
    #}
    endif()
#}
endfunction()

# Adds a test, also as part of the `tests` target.
function(vrm_cmake_add_unit_test name)
#{
    vrm_cmake_add_test(${ARGV})
    add_dependencies(tests ${name})
#}
endfunction()

# Adds a test for a public header, making sure including it works properly.
# Adds them to the `tests` target.
function(vrm_cmake_add_public_header_test header)
#{
    string(REGEX REPLACE "/" "." _target "${header}")

    if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/header/${header}.cpp")
    #{
        file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/header/${header}.cpp" "
            #include <${header}>
            int main() { return 0; }
        ")
    #}
    endif()

    add_executable(test.header.${_target} EXCLUDE_FROM_ALL
                        "${CMAKE_CURRENT_BINARY_DIR}/header/${header}.cpp")

    vrm_cmake_add_test(test.header.${_target}
                            ${CMAKE_CURRENT_BINARY_DIR}/test.header.${_target})

    add_dependencies(tests test.header.${_target})
#}
endfunction()

# Generate tests that include each public header.
macro(vrm_cmake_generate_public_header_tests header_list inc_dir)
#{
    foreach(_header IN LISTS header_list)
    #{
        file(RELATIVE_PATH _relative "${inc_dir}" "${_header}")
        vrm_cmake_add_header_test("${_relative}")
    #}
    endforeach()
#}
endmacro()

# Generate unit tests.
macro(vrm_cmake_generate_unit_tests test_srcs)
#{
    foreach(_file IN LISTS ${test_srcs})
    #{
        file(READ "${_file}" _contents)
        vrm_cmake_target_name_for(_target "${_file}")

        add_executable(${_target} EXCLUDE_FROM_ALL "${_file}")
        vrm_cmake_add_unit_test(${_target} ${CMAKE_CURRENT_BINARY_DIR}/${_target})
    #}
    endforeach()
#}
endmacro()

# Generate unit tests.
macro(vrm_cmake_generate_unit_tests_glob glob_pattern)
#{
    # Glob all tests.
    file(GLOB_RECURSE _srcs ${glob_pattern})

    # Add all the unit tests.
    vrm_cmake_generate_unit_tests(_srcs)
#}
endmacro()

# Generate unit tests.
macro(vrm_cmake_generate_public_header_tests_glob glob_pattern inc_dir)
#{
    # Glob all public headers. (Detail headers can be removed here.)
    file(GLOB_RECURSE _pub_headers "${inc_dir}/${glob_pattern}")
    vrm_cmake_list_remove_glob(_pub_headers GLOB_RECURSE "dummy")

    # Generate tests that include each public header.
    vrm_cmake_generate_public_header_tests(_pub_headers "${inc_dir}")
#}
endmacro()

# Adds common compiler safety/warning flags/definitions to the project.
macro(vrm_cmake_add_common_compiler_flags_safety)
#{
    vrm_cmake_add_compiler_flag(HAS_PEDANTIC                          -pedantic)
    vrm_cmake_add_compiler_flag(HAS_STDCXX1Y                          -std=c++1y)
    vrm_cmake_add_compiler_flag(HAS_W                                 -W)
    vrm_cmake_add_compiler_flag(HAS_WALL                              -Wall)
    vrm_cmake_add_compiler_flag(HAS_WEXTRA                            -Wextra)
    vrm_cmake_add_compiler_flag(HAS_WNO_UNUSED_LOCAL_TYPEDEFS         -Wno-unused-local-typedefs)
    vrm_cmake_add_compiler_flag(HAS_WWRITE_STRINGS                    -Wwrite-strings)
    vrm_cmake_add_compiler_flag(HAS_WSHADOW                           -Wshadow)
    vrm_cmake_add_compiler_flag(HAS_WUNDEF                            -Wundef)
    vrm_cmake_add_compiler_flag(HAS_WNO_MISSING_FIELD_INITIALIZERS    -Wno-missing-field-initializers)
    vrm_cmake_add_compiler_flag(HAS_WPOINTER_ARITH                    -Wpointer-arith)
    vrm_cmake_add_compiler_flag(HAS_WCAST_ALIGN                       -Wcast-align)
    vrm_cmake_add_compiler_flag(HAS_WNO_UNREACHABLE_CODE              -Wno-unreachable-code)
    vrm_cmake_add_compiler_flag(HAS_WNON_VIRTUAL_DTOR                 -Wnon-virtual-dtor)
    vrm_cmake_add_compiler_flag(HAS_WOVERLOADED_VIRTUAL               -Woverloaded-virtual)
#}
endmacro()

# Adds common compiler release flags/definitions to the project.
macro(vrm_cmake_add_common_compiler_flags_release)
#{
    vrm_cmake_add_compiler_flag(HAS_OFAST                             -Ofast)
    vrm_cmake_add_compiler_flag(HAS_FFAST_MATH                        -ffast-math)

    add_definitions(-DNDEBUG -DSSVUT_DISABLE -DSSVU_ASSERT_FORCE_OFF=1)
#}
endmacro()

# Adds common compiler debug flags/definitions to the project.
macro(vrm_cmake_add_common_compiler_flags_debug)
#{
    vrm_cmake_add_compiler_flag(HAS_F_NO_OMIT_FRAME_POINTER           -fno-omit-frame-pointer)
    vrm_cmake_add_compiler_flag(HAS_G3                                -g3)
#}
endmacro()

# Adds common compiler flags/definitions, depending on the build type.
macro(vrm_cmake_add_common_compiler_flags)
#{
    vrm_cmake_add_common_compiler_flags_safety()

    if("${CMAKE_BUILD_TYPE}" STREQUAL "RELEASE")
    #{
        message("vrm_cmake: release mode")
        vrm_cmake_add_common_compiler_flags_release()
    #}
    elseif("${CMAKE_BUILD_TYPE}" STREQUAL "WIP_OPT")
    #{
        message("vrm_cmake: debug mode")
        vrm_cmake_add_common_compiler_flags_debug()
    #}
    else()
    #{
        message("vrm_cmake: wip mode")
    #}
    endif()
#}
endmacro()

# Returns a list of globbed objects except the listed ones.
macro(vrm_cmake_list_remove_glob list glob)
#{
    list(REMOVE_ITEM ${list} ${ARGN})
#}
endmacro()