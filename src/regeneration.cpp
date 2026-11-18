#include <Rcpp.h>
#include <algorithm>
#include <vector>

using namespace Rcpp;

// Compare CSR slices only at disturbed sites. Match age and species so
// partial biomass removals keep their cohort identity.
// [[Rcpp::export(rng = false)]]
DataFrame landis_removed_cohorts_cpp(const List& before, const List& after,
                                     const IntegerVector& before_cells,
                                     const IntegerVector& after_cells,
                                     const IntegerVector& active,
                                     const IntegerVector& disturbed) {
  const IntegerVector old_offset = before["offset"], new_offset = after["offset"];
  const IntegerVector old_species = before["species_id"], new_species = after["species_id"];
  const NumericVector old_age = before["age"], new_age = after["age"];
  std::vector<int> cells, species;
  std::vector<double> ages;
  std::vector<unsigned char> matched;
  for (R_xlen_t i = 0; i < disturbed.size(); ++i) {
    if ((i & 16383) == 0) checkUserInterrupt();
    const auto found = std::lower_bound(active.begin(), active.end(), disturbed[i]);
    if (found == active.end() || *found != disturbed[i]) stop("Inactive disturbed cell");
    const auto pos = found - active.begin();
    const int a = before_cells[pos] - 1, b = after_cells[pos] - 1;
    const int begin = new_offset[b], end = new_offset[b + 1];
    matched.assign(end - begin, 0);
    for (int j = old_offset[a]; j < old_offset[a + 1]; ++j) {
      bool survives = false;
      for (int k = begin; k < end; ++k) {
        if (!matched[k - begin] && old_species[j] == new_species[k] && old_age[j] == new_age[k]) {
          matched[k - begin] = 1;
          survives = true;
          break;
        }
      }
      if (!survives) {
        cells.push_back(disturbed[i]);
        species.push_back(old_species[j] + 1);
        ages.push_back(old_age[j]);
      }
    }
  }
  return DataFrame::create(_["cell_id"] = cells, _["species_index"] = species, _["age"] = ages);
}
