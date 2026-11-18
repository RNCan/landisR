#ifndef LANDISR_ARRAY_SORT_HPP
#define LANDISR_ARRAY_SORT_HPP
#include <algorithm>

namespace landis_array_sort {

// Reproduce the tie order from .NET's Array.Sort. LANDIS-II uses this
// behavior for rank-only stand and distance-only neighborhood sorting.
template<class T, class Less>
void down_heap(T* values, int node, int count, Less less) {
  const T value = values[node - 1];
  while (node <= count / 2) {
    int child = node * 2;
    if (child < count && less(values[child - 1], values[child])) ++child;
    if (!less(value, values[child - 1])) break;
    values[node - 1] = values[child - 1];
    node = child;
  }
  values[node - 1] = value;
}

template<class T, class Less>
void intro_sort(T* values, int count, int depth, Less less) {
  const auto swap_if_greater = [&](int left, int right) {
    if (less(values[right], values[left])) std::swap(values[left], values[right]);
  };
  while (count > 1) {
    const int hi = count - 1;
    if (count <= 16) {
      if (count == 2) {
        swap_if_greater(0, 1);
      } else if (count == 3) {
        swap_if_greater(0, 1);
        swap_if_greater(0, 2);
        swap_if_greater(1, 2);
      } else {
        for (int i = 1; i < count; ++i) {
          const T value = values[i];
          int j = i;
          while (j > 0 && less(value, values[j - 1])) {
            values[j] = values[j - 1];
            --j;
          }
          values[j] = value;
        }
      }
      return;
    }
    if (depth == 0) {
      for (int i = count / 2; i >= 1; --i) down_heap(values, i, count, less);
      for (int i = hi; i >= 1; --i) {
        std::swap(values[0], values[i]);
        down_heap(values, 1, i, less);
      }
      return;
    }
    --depth;
    const int mid = hi / 2;
    swap_if_greater(0, mid);
    swap_if_greater(0, hi);
    swap_if_greater(mid, hi);
    const T pivot = values[mid];
    std::swap(values[mid], values[hi - 1]);
    int left = 0;
    int right = hi - 1;
    while (left < right) {
      while (less(values[++left], pivot)) {}
      while (less(pivot, values[--right])) {}
      if (left >= right) break;
      std::swap(values[left], values[right]);
    }
    if (left != hi - 1) std::swap(values[left], values[hi - 1]);
    intro_sort(values + left + 1, hi - left, depth, less);
    count = left;
  }
}

template<class T, class Less>
void landis_sort(T* values, int count, Less less) {
  int bits = 0;
  for (int n = count; n > 0; n /= 2) ++bits;
  intro_sort(values, count, 2 * bits, less);
}

}
#endif
