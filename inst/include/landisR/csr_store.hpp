#ifndef LANDISR_CSR_STORE_HPP
#define LANDISR_CSR_STORE_HPP

#include <Rcpp.h>

// CSR v3 uses zero-based offsets and species codes, preserving cohort order.
namespace landis_csr {

inline Rcpp::NumericVector numeric_column(const Rcpp::DataFrame& data, const char* name) {
  SEXP column = data[name];
  if (TYPEOF(column) == REALSXP) return Rcpp::NumericVector(column);
  if (TYPEOF(column) == INTSXP) {
    Rcpp::IntegerVector input(column);
    Rcpp::NumericVector output(input.size());
    for (int i = 0; i < input.size(); ++i) output[i] = input[i];
    return output;
  }
  Rcpp::stop("Non-numeric species parameter: %s", name);
}

inline void validate_csr_store(const Rcpp::List& store,
                               int n_species = -1) {
  Rcpp::IntegerVector offset = store["offset"];
  Rcpp::IntegerVector species_id = store["species_id"];
  Rcpp::NumericVector age = store["age"];
  Rcpp::NumericVector biomass = store["biomass"];

  if (offset.size() < 1)
    Rcpp::stop("CSR state store has no offset vector");

  if (offset[0] != 0)
    Rcpp::stop("CSR offsets must start at zero");

  if (species_id.size() != age.size() ||
      species_id.size() != biomass.size())
    Rcpp::stop("CSR cohort vectors have incompatible lengths");

  const int n_cohorts = species_id.size();

  for (int s = 0; s < offset.size(); ++s) {
    if (offset[s] < 0 ||
        offset[s] > n_cohorts)
      Rcpp::stop("CSR offset out of bounds");

    if (s > 0 &&
        offset[s] < offset[s - 1])
      Rcpp::stop("CSR offsets are not monotonic");
  }

  if (offset[offset.size() - 1] != n_cohorts)
    Rcpp::stop("CSR final offset does not equal cohort count");

  if (n_species > 0) {
    for (int i = 0; i < n_cohorts; ++i) {
      if (species_id[i] < 0 ||
          species_id[i] >= n_species)
        Rcpp::stop("CSR species ID out of bounds");
    }
  }
}

inline Rcpp::List make_csr_store(const Rcpp::IntegerVector& offset,
                                const Rcpp::IntegerVector& species_id,
                                const Rcpp::NumericVector& age,
                                const Rcpp::NumericVector& biomass) {
  return Rcpp::List::create(
    Rcpp::_["format"] = "landisR52/state-csr-v3",
    Rcpp::_["offset"] = offset,
    Rcpp::_["species_id"] = species_id,
    Rcpp::_["age"] = age,
    Rcpp::_["biomass"] = biomass
  );
}

} // namespace landis_csr

#endif
