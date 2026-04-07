#include "conftest.h"

int main2() {
  strlen(""); // GOOD: the source file occurs in a `CMakeFiles/CMakeScratch/TryCompile-...` directory
  return 0;
}
