# redactr

**Prepare data for LLM projects by anonymizing sensitive information.**

redactr anonymizes vectors and tibbles so that sensitive data can be safely
shared with large language models. Five redaction strategies are supported,
each preserving structural characteristics that keep the data useful for
analysis and prompting.

## Redaction strategies

| Type | What changes | What stays the same |
|------|-------------|---------------------|
| `"code"` | Alpha and numeric tokens replaced randomly | Format (separators, token lengths, letter case) |
| `"group"` | Each unique value mapped to a thematic word | Count of unique values, consistent substitution |
| `"name"` | Replaced with fake-but-realistic names | Name format (First Last / Last, First / single) |
| `"numeric"` | Values randomly permuted within the column | Full distribution (min, max, mean, SD) |
| `col_formula()` | Column recomputed from an R expression | Arithmetic relationship to other columns |

## Installation

```r
# Install from GitHub (once published):
# pak::pak("orderlyquant/redactr")

# During development, load with:
devtools::load_all()
```

## Quick start

```r
library(redactr)
library(tibble)

dat <- tibble(
  account_id = c("ACC-001", "ACC-002", "ACC-003", "ACC-001"),
  sector     = c("Tech", "Finance", "Energy", "Tech"),
  revenue    = c(100, 200, 150, 300),
  manager    = c("Alice Brown", "Bob Smith", "Carol Jones", "Alice Brown")
)

set.seed(42)
result <- redact(
  dat,
  col_types = list(
    account_id = "code",
    sector     = "group",
    revenue    = "numeric",
    manager    = "name"
  )
)

# Redacted columns keep their original names; assign to a new object
# to keep both the original and redacted copies in your workspace.
dat_rdct <- result$data
dat_rdct
#> # A tibble: 4 × 4
#>   account_id sector  revenue manager
#>   <chr>      <chr>     <dbl> <chr>
#> 1 KPQ-283    cobalt      300 Sandra Wilson
#> 2 MWX-719    falcon      100 Mark Taylor
#> 3 RVT-504    drill       150 Carol Reed
#> 4 KPQ-283    cobalt      200 Sandra Wilson

result$mapping
#> $account_id
#> # A tibble: 3 × 2
#>   original redacted
#>   <chr>    <chr>
#> 1 ACC-001  KPQ-283
#> ...
```

## Column type specification

Pass a named list to `col_types`. Names must match column names in your data.
Any column not mentioned is left unchanged (`"skip"`).

```r
# Plain strings (shorthand)
col_types = list(
  account_id = "code",
  sector     = "group",
  revenue    = "numeric",
  manager    = "name",
  notes      = "skip"       # explicit skip; also the default
)

# col_*() constructors — use when you need extra options
col_types = list(
  sector = col_group(bank = "animals"),  # pick a specific word bank
  region = col_group(bank = "colors")
)

# col_formula() — recompute a derived column from already-redacted values
col_types = list(
  alloc    = "numeric",
  selec    = "numeric",
  tot_attr = col_formula(~ alloc + selec)
)
```

Available word banks (see `word_bank_names()`):

- `"colors"` — amber, azure, cobalt, coral, …
- `"animals"` — albatross, badger, beaver, …
- `"tools"` — adze, anvil, auger, …
- `"automobiles"` — barracuda, biscayne, camaro, …
- `"mascots"` — anchor, arrow, blaze, bolt, …

Use `bank = "auto"` (the default) to pool all banks into one large draw.

## Preserving relationships between columns

When a dataset contains derived columns — e.g. `tot_attr = alloc + selec` in
attribution data — independently redacting all three columns breaks that
relationship. Use `col_formula()` to recompute the derived column from the
already-redacted source columns instead:

```r
set.seed(1)
attr_dat <- tibble(
  sector   = c("Energy", "Energy", "Energy"),
  alloc    = c( 0.00,  0.00,  0.00),
  selec    = c(-0.002,  0.010, -0.014),
  tot_attr = c(-0.014,  0.000,  0.041)   # alloc + selec
)

result <- redact(
  attr_dat,
  col_types = list(
    sector   = "group",
    alloc    = "numeric",
    selec    = "numeric",
    tot_attr = col_formula(~ alloc + selec)
  )
)

result$data
# tot_attr equals alloc + selec in the redacted output
```

**Execution order:** `col_formula()` columns are always evaluated in a second
pass, after all `"code"`, `"group"`, `"name"`, and `"numeric"` columns have
been processed. This means a formula that references a `"numeric"` column sees
the *shuffled* values, not the originals.

**No mapping stored:** formula columns appear in `result$columns` but not in
`result$mapping`. Because they are derived rather than independently
anonymized, there is nothing to store or re-apply with `apply_redact()`.

## Single-vector redaction

```r
set.seed(1)

# Codes
redact_vec(c("ACC-001", "ACC-002", "ACC-003"), type = "code")

# Groups with a specific bank
redact_vec(c("Tech", "Finance", "Energy"), type = "group", bank = "animals")

# Names
redact_vec(c("Alice Brown", "Bob Smith"), type = "name")

# Numeric shuffle
redact_vec(c(10, 20, 30, 40, 50), type = "numeric")
```

## Applying a mapping across files

Store the mapping from one file and apply it consistently to related files:

```r
# --- File 1 ---
set.seed(42)
result_train <- redact(
  train_data,
  col_types = list(sector = "group", account_id = "code", manager = "name")
)
saveRDS(result_train$mapping, "redact_mapping.rds")

# --- File 2 ---
mapping <- readRDS("redact_mapping.rds")
test_redacted <- apply_redact(test_data, mapping)
```

`apply_redact()` ensures the same original value always produces the same
redacted substitute. Numeric columns (whose shuffle is row-specific) must be
re-shuffled independently with a fresh `redact()` call.

## Reproducibility

Pass `seed` to `redact()` or `redact_vec()` for reproducible output:

```r
result <- redact(dat, col_types = list(sector = "group"), seed = 123)
```

## Design notes

- **No auto-detection.** Column types must be declared explicitly, similar to
  `readr::read_csv(col_types = ...)`. This avoids silent misclassification.
- **Columns keep their original names.** Redacted values replace originals
  in-place. Assign `result$data` to a new name to keep both copies.
- **Mappings stored for code, group, and name only.** These are deterministic
  look-ups, making cross-file consistency trivial via `apply_redact()`.
  Numeric permutations are one-way by design; formula columns are derived and
  have no independent mapping to store.
- **Format-preserving codes.** `"ACC-1234"` becomes something like
  `"KPQ-7829"` — same structure, different values, same readability.
- **Thematic word banks.** Group substitutes come from curated word lists
  (colors, animals, tools, automobiles, mascots) so the redacted data remains
  easy to read and discuss.

## Contributing

Bug reports and pull requests are welcome at
<https://github.com/orderlyquant/redactr/issues>.
