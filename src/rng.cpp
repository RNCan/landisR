#include <Rcpp.h>
#include <landisR/mt19937.hpp>
#include <cmath>
#include <cstdint>

using Rcpp::stop;

// [[Rcpp::export(rng = false)]]
std::string landis_mt19937_init_cpp(double seed) {
  if (!std::isfinite(seed) || seed < 0 || seed > 4294967295.0 || seed != std::floor(seed))
    stop("Invalid LANDIS MT19937 seed");
  return landis_rng::Stream(static_cast<std::uint32_t>(seed)).encode();
}
