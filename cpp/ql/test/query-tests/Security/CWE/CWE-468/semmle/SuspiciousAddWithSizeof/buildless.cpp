// semmle-extractor-options: --expect_errors

void test_buildless(const char *p_c, const short *p_short, const int *p_int, const uint8_t *p_8, const uint16_t *p_16, const uint32_t *p_32) {
  *(p_c + sizeof(int)); // GOOD (`sizeof(char)` is 1)
  *(p_short + sizeof(int)); // BAD
  *(p_int + sizeof(int)); // BAD
  *(p_8 + sizeof(int)); // GOOD (`sizeof(p_8)` is 1) [FALSE POSITIVE]
  *(p_16 + sizeof(int)); // BAD
  *(p_32 + sizeof(int)); // BAD
}
