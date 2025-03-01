cmake_minimum_required(VERSION 3.10)
project(DeathDPI)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(WINDIVERT_PATH "${CMAKE_SOURCE_DIR}/WinDivert")

add_executable(DeathDPI src/main.cpp)

target_include_directories(DeathDPI PRIVATE
    ${WINDIVERT_PATH}/include
)

target_link_directories(DeathDPI PRIVATE
    ${WINDIVERT_PATH}/x64
) 