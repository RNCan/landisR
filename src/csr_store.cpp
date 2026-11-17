#include <Rcpp.h>
#include <landisR/csr_store.hpp>
#include <string>
#include <unordered_map>

using namespace Rcpp;


using landis_csr::make_csr_store;
using landis_csr::numeric_column;
using landis_csr::validate_csr_store;

// [[Rcpp::export]]
List bs52_states_list_to_csr_cpp(
    List states,
    CharacterVector species_names) {

  const int n_states = states.size();
  const int n_species = species_names.size();

  if (n_species < 1)
    stop("No species supplied to CSR converter");

  std::unordered_map<std::string, int> species_index;
  species_index.reserve(
    static_cast<std::size_t>(
      n_species * 2
    )
  );

  for (int j = 0; j < n_species; ++j) {
    const std::string name =
      as<std::string>(
        species_names[j]
      );

    if (species_index.find(name) !=
        species_index.end())
      stop("Duplicate species name in CSR converter");

    species_index[name] = j;
  }

  std::size_t total_cohorts = 0;

  for (int s = 0; s < n_states; ++s) {
    DataFrame cohort = states[s];

    NumericVector age =
      numeric_column(
        cohort,
        "age"
      );

    total_cohorts +=
      static_cast<std::size_t>(
        age.size()
      );
  }

  if (total_cohorts >
      static_cast<std::size_t>(
        std::numeric_limits<int>::max()
      ))
    stop("CSR cohort count exceeds integer offset capacity");

  IntegerVector offset(
    n_states + 1
  );

  IntegerVector species_id(
    static_cast<int>(
      total_cohorts
    )
  );

  NumericVector age_out(
    static_cast<int>(
      total_cohorts
    )
  );

  NumericVector biomass_out(
    static_cast<int>(
      total_cohorts
    )
  );

  int cursor = 0;
  offset[0] = 0;

  for (int s = 0; s < n_states; ++s) {
    DataFrame cohort = states[s];

    CharacterVector species =
      cohort["species"];

    NumericVector age =
      numeric_column(
        cohort,
        "age"
      );

    NumericVector biomass =
      numeric_column(
        cohort,
        "biomass"
      );

    if (species.size() != age.size() ||
        species.size() != biomass.size())
      stop("Invalid state while converting to CSR");

    for (int i = 0; i < species.size(); ++i) {
      const std::string name =
        as<std::string>(
          species[i]
        );

      const auto found =
        species_index.find(name);

      if (found ==
          species_index.end())
        stop("Unknown species while converting to CSR");

      species_id[cursor] =
        found->second;

      age_out[cursor] =
        age[i];

      biomass_out[cursor] =
        biomass[i];

      ++cursor;
    }

    offset[s + 1] =
      cursor;
  }

  return make_csr_store(
    offset,
    species_id,
    age_out,
    biomass_out
  );
}


// [[Rcpp::export]]
List bs52_csr_to_states_cpp(
    List store,
    CharacterVector species_names) {

  const int n_species =
    species_names.size();

  validate_csr_store(
    store,
    n_species
  );

  IntegerVector offset =
    store["offset"];

  IntegerVector species_id =
    store["species_id"];

  NumericVector age =
    store["age"];

  NumericVector biomass =
    store["biomass"];

  const int n_states =
    offset.size() - 1;

  List states(
    n_states
  );

  for (int s = 0; s < n_states; ++s) {
    const int begin =
      offset[s];

    const int end =
      offset[s + 1];

    const int n =
      end - begin;

    CharacterVector species(
      n
    );

    NumericVector state_age(
      n
    );

    NumericVector state_biomass(
      n
    );

    for (int i = 0; i < n; ++i) {
      const int k =
        begin + i;

      const int id =
        species_id[k];

      if (id < 0 ||
          id >= n_species)
        stop("Invalid species ID while expanding CSR");

      species[i] =
        species_names[id];

      state_age[i] =
        age[k];

      state_biomass[i] =
        biomass[k];
    }

    states[s] =
      DataFrame::create(
        _["species"] = species,
        _["age"] = state_age,
        _["biomass"] = state_biomass
      );
  }

  return states;
}



// [[Rcpp::export]]
List bs52_state_snapshot_csr_cpp(
    List store,
    int n_species) {

  validate_csr_store(
    store,
    n_species
  );

  IntegerVector offset =
    store["offset"];

  IntegerVector species_id =
    store["species_id"];

  NumericVector age =
    store["age"];

  NumericVector biomass =
    store["biomass"];

  const int n_states =
    offset.size() - 1;

  NumericMatrix state_biomass(
    n_states,
    n_species
  );

  NumericVector state_total_biomass(
    n_states
  );

  NumericVector state_max_age(
    n_states
  );

  for (int s = 0;
       s < n_states;
       ++s) {

    if ((s % 10000) == 0)
      checkUserInterrupt();

    double oldest =
      0.0;

    const int begin =
      offset[s];

    const int end =
      offset[s + 1];

    for (int k = begin;
         k < end;
         ++k) {

      const int id =
        species_id[k];

      state_biomass(
        s,
        id
      ) += biomass[k];

      if (age[k] > oldest)
        oldest =
          age[k];
    }

    // Preserve v2 snapshot summation order exactly:
    // first sum cohorts by species, then total species columns.
    double total =
      0.0;

    for (int j = 0;
         j < n_species;
         ++j) {

      total +=
        state_biomass(
          s,
          j
        );
    }

    state_total_biomass[s] =
      total;

    state_max_age[s] =
      oldest;
  }

  return List::create(
    _["state_biomass"] =
      state_biomass,
    _["state_total_biomass"] =
      state_total_biomass,
    _["state_max_age"] =
      state_max_age
  );
}


// [[Rcpp::export]]
List bs52_csr_diagnostics_cpp(
    List store) {

  validate_csr_store(
    store
  );

  IntegerVector offset =
    store["offset"];

  const int n_states =
    offset.size() - 1;

  const int n_cohorts =
    as<IntegerVector>(
      store["species_id"]
    ).size();

  int max_cohorts =
    0;

  long double sum_cohorts =
    0.0L;

  for (int s = 0;
       s < n_states;
       ++s) {

    const int n =
      offset[s + 1] -
      offset[s];

    if (n > max_cohorts)
      max_cohorts = n;

    sum_cohorts +=
      n;
  }

  return List::create(
    _["n_states"] = n_states,
    _["n_cohorts"] = n_cohorts,
    _["mean_cohorts_per_state"] =
      n_states > 0
        ? static_cast<double>(
            sum_cohorts /
            static_cast<long double>(
              n_states
            )
          )
        : 0.0,
    _["max_cohorts_per_state"] =
      max_cohorts
  );
}
