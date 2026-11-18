#ifndef LANDISR_PROGRESS_HPP
#define LANDISR_PROGRESS_HPP

#include <Rcpp.h>
#include <algorithm>
#include <cstddef>

namespace landis_progress {
class Reporter {
  SEXP callback_ = Rf_GetOption1(Rf_install("landisR.progress.native"));
  const char* label_ = "";
  double from_ = 0;
  double to_ = 1;
  std::size_t total_ = 0;
  std::size_t next_ = 0;
  std::size_t stride_ = 1;

public:
  explicit operator bool() const { return Rf_isFunction(callback_); }

  void phase(double fraction, const char* label) const {
    if (*this) Rcpp::Function{callback_}(fraction, label);
  }

  void start(double from, double to, const char* label, std::size_t total) {
    if (!*this) return;
    from_ = from;
    to_ = to;
    label_ = label;
    total_ = total;
    stride_ = std::max<std::size_t>(1, (total + 19) / 20);
    next_ = stride_;
    phase(from_, label_);
  }

  bool due(std::size_t done) const {
    return total_ && done >= next_ && done <= total_;
  }

  void advance(std::size_t done) {
    if (!due(done)) return;
    next_ = done + stride_;
    phase(from_ + (to_ - from_) * (static_cast<double>(done) / total_), label_);
  }
};
}
#endif
