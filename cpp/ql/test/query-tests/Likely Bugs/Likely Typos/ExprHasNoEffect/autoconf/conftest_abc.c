#include "conftest.h"

int main1() {
  strlen(""); // GOOD: the source file occurs in a `CMakeFiles/CMakeScratch/TryCompile-...` directory
  return 0;
}
