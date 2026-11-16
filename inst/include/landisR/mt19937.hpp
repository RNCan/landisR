#ifndef LANDISR_MT19937_HPP
#define LANDISR_MT19937_HPP

#include <cmath>
#include <cstdint>
#include <limits>
#include <random>
#include <sstream>
#include <stdexcept>
#include <string>

namespace landis_rng {

// LANDIS-II v7 uses the upper 31 bits of one MT19937 word for each uniform.
struct Stream {
  std::mt19937 generator;
  std::uint64_t draws;

  explicit Stream(std::uint32_t seed, std::uint64_t skip = 0)
    : generator(seed), draws(skip) {
    generator.discard(skip);
  }

  double next_double() {
    ++draws;
    return static_cast<double>(generator() >> 1) / 2147483648.0;
  }

  int next(int n) {
    if (n < 1) throw std::runtime_error("Next(n): n must be positive");
    return static_cast<int>(next_double() * n);
  }

  // Stream operators preserve all 624 state words and the current index.
  // Use the classic locale so RDS files can be resumed across platforms.
  std::string encode() const {
    std::ostringstream encoded;
    encoded.imbue(std::locale::classic());
    encoded << generator;
    return encoded.str();
  }

  void restore(const std::string& state) {
    std::istringstream encoded(state);
    encoded.imbue(std::locale::classic());
    if (!(encoded >> generator))
      throw std::runtime_error("Invalid LANDIS MT19937 state");
    encoded >> std::ws;
    if (!encoded.eof()) throw std::runtime_error("Invalid LANDIS MT19937 state");
  }

  static std::uint64_t offset(double n) {
    if (!std::isfinite(n) || n < 0 || n > 9007199254740991.0 || n != std::floor(n))
      throw std::runtime_error("Invalid LANDIS MT19937 draw count");
    return static_cast<std::uint64_t>(n);
  }
};

} // namespace landis_rng
#endif
