#═══════════════════════════════════════════════════════════════
# FILE: CMakeLists.txt
# PHASE: Phase 7 - Communication and Control Features
# LOCATION: varuna_ui/CMakeLists.txt
#═══════════════════════════════════════════════════════════════

cmake_minimum_required(VERSION 3.16)

project(varuna_ui VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Find Qt6 packages
find_package(Qt6 6.2 REQUIRED COMPONENTS
    Core
    Quick
    Qml
    Gui
)

# Add Qt resources
qt_add_resources(QT_RESOURCES resources/resources.qrc)

# Source files
set(SOURCES
    main.cpp
    src/backend/Backend.cpp
    src/backend/CommandHandler.cpp
)

# Header files
set(HEADERS
    src/backend/Backend.h
    src/backend/CommandHandler.h
)

# Create executable
qt_add_executable(${PROJECT_NAME}
    ${SOURCES}
    ${HEADERS}
    ${QT_RESOURCES}
)

# Include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/backend
)

# Link Qt libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
)

# Set target properties for Raspberry Pi optimization
set_target_properties(${PROJECT_NAME} PROPERTIES
    WIN32_EXECUTABLE FALSE
    MACOSX_BUNDLE FALSE
)

# Install target
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
)

# Install Python scripts
install(DIRECTORY python/
    DESTINATION python
    FILES_MATCHING PATTERN "*.py" PATTERN "*.json"
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
)

#═══════════════════════════════════════════════════════════════
# END OF FILE: CMakeLists.txt
#═══════════════════════════════════════════════════════════════
