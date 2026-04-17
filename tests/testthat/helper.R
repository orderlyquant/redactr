# Shared test fixtures

sample_tibble <- function() {
  tibble::tibble(
    account_id = c("ACC-001", "ACC-002", "ACC-003", "ACC-001"),
    sector     = c("Tech", "Finance", "Energy", "Tech"),
    revenue    = c(100, 200, 150, 300),
    manager    = c("Alice Brown", "Bob Smith", "Carol Jones", "Alice Brown")
  )
}
