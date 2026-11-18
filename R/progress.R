# Render one console line for both coupled and standalone runs.
landisR_progress_enabled <- function(progress) {
  if (!identical(progress, TRUE) && !identical(progress, FALSE))
    stop("progress must be TRUE or FALSE.", call. = FALSE)
  progress
}

landis_progress_bar <- function(progress, title) {
  if (!landisR_progress_enabled(progress)) return(NULL)
  width <- min(100L, getOption("width") - 1L)
  previous <- ""
  update <- function(fraction, detail) {
    percent <- as.integer(floor(100 * fraction))
    filled <- as.integer(12 * fraction)
    bar <- paste0(strrep("=", filled), strrep(" ", 12L - filled))
    detail <- gsub("[[:cntrl:]]", " ", detail)
    line <- strtrim(sprintf("[%s] %3d%% %s | %s", bar, percent, title, detail), width)
    if (identical(previous, line)) return(invisible(NULL))
    padding <- max(0L, nchar(previous, type = "width") - nchar(line, type = "width"))
    cat("\r", line, strrep(" ", padding), sep = "")
    utils::flush.console()
    previous <<- line
    invisible(NULL)
  }
  finish <- function() {
    if (nzchar(previous)) {
      cat("\n")
      utils::flush.console()
      previous <<- ""
    }
    invisible(NULL)
  }
  list(update = update, close = finish)
}

# Install a callback just for one native operation. The scoped callback is
# never stored in a simulation or checkpoint.
landis_progress_native <- function(report, from, to, code) {
  if (is.null(report)) return(force(code))
  restore <- options(landisR.progress.native = function(fraction, label)
    report(from + (to - from) * fraction, label))
  on.exit(options(restore), add = TRUE)
  force(code)
}

landisR_extension_label <- function(extension, id) {
  label <- attr(extension, "progress_label", exact = TRUE)
  if (is.null(label)) id else label
}
