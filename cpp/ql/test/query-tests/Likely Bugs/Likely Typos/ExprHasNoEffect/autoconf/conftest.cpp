#include "conftest.h"

int main4() {
  strlen(""); // GOOD: the source file occurs in a `CMakeFiles/CMakeScratch/TryCompile-...` directory
  return 0;
}
