#.rst:
# Find GLFW
# ---------
#
# Finds the GLFW library using its cmake config if that exists, otherwise
# falls back to finding it manually. This module defines:
#
#  GLFW_FOUND               - True if GLFW library is found
#  GLFW::GLFW               - GLFW imported target
#
# Additionally, in case the config was not found, these variables are defined
# for internal usage:
#
#  GLFW_LIBRARY             - GLFW library
#  GLFW_INCLUDE_DIR         - Root include dir
#

#
#   This file is part of Magnum.
#
#   Copyright © 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019
#             Vladimír Vondruš <mosra@centrum.cz>
#   Copyright © 2016 Jonathan Hale <squareys@googlemail.com>
#
#   Permission is hereby granted, free of charge, to any person obtaining a
#   copy of this software and associated documentation files (the "Software"),
#   to deal in the Software without restriction, including without limitation
#   the rights to use, copy, modify, merge, publish, distribute, sublicense,
#   and/or sell copies of the Software, and to permit persons to whom the
#   Software is furnished to do so, subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included
#   in all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
#   THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#   DEALINGS IN THE SOFTWARE.
#

# GLFW installs cmake package config files to shared/ folder which handles
# dependencies in case GLFW is built statically. Try to find first, quietly, so
# it doesn't print loud messages when it's not found, since that's okay.
find_package(glfw3 CONFIG QUIET)

if(TARGET glfw)
    if(NOT TARGET GLFW::GLFW)
        # Aliases of (global) targets are only supported in CMake 3.11, so we
        # work around it by this. This is easier than fetching all possible
        # properties (which are impossible to track of) and then attempting to
        # rebuild them into a new target.
        add_library(GLFW::GLFW INTERFACE IMPORTED)
        set_target_properties(GLFW::GLFW PROPERTIES INTERFACE_LINK_LIBRARIES glfw)
    endif()

    # Just to make FPHSA print some meaningful location, nothing else
    get_target_property(_GLFW_INTERFACE_INCLUDE_DIRECTORIES glfw INTERFACE_INCLUDE_DIRECTORIES)
    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args("GLFW" DEFAULT_MSG
        _GLFW_INTERFACE_INCLUDE_DIRECTORIES)
    return()
endif()

# In case no config file was found, try manually finding the library.
find_library(GLFW_LIBRARY NAMES glfw glfw3)

# Include dir
find_path(GLFW_INCLUDE_DIR
    NAMES GLFW/glfw3.h)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args("GLFW" DEFAULT_MSG
    GLFW_LIBRARY
    GLFW_INCLUDE_DIR)

if(NOT TARGET GLFW::GLFW)
    add_library(GLFW::GLFW UNKNOWN IMPORTED)

    # Work around BUGGY framework support on macOS
    # https://cmake.org/Bug/view.php?id=14105
    if(CORRADE_TARGET_APPLE AND ${GLFW_LIBRARY} MATCHES "\\.framework$")
        set_property(TARGET GLFW::GLFW PROPERTY IMPORTED_LOCATION ${GLFW_LIBRARY}/GLFW)
    else()
        set_property(TARGET GLFW::GLFW PROPERTY IMPORTED_LOCATION ${GLFW_LIBRARY})
    endif()

    set_property(TARGET GLFW::GLFW PROPERTY
        INTERFACE_INCLUDE_DIRECTORIES ${GLFW_INCLUDE_DIR})
endif()

mark_as_advanced(GLFW_LIBRARY GLFW_INCLUDE_DIR)
