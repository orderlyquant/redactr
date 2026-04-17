# Internal word banks and name banks used by group and name redaction.
# Not exported. Each list element is a character vector of thematic words.

.word_banks <- list(
  colors = c(
    "amber", "azure", "cobalt", "coral", "crimson", "cyan", "fawn",
    "gold", "indigo", "ivory", "jade", "khaki", "lavender", "lemon",
    "lilac", "lime", "magenta", "maroon", "mauve", "mint", "navy",
    "ochre", "olive", "onyx", "peach", "pearl", "plum", "rose",
    "ruby", "sage", "salmon", "scarlet", "sienna", "silver", "slate",
    "tan", "teal", "topaz", "umber", "violet"
  ),
  animals = c(
    "albatross", "badger", "beaver", "bison", "bobcat", "cobra",
    "condor", "cougar", "coyote", "crane", "dingo", "dolphin",
    "eagle", "falcon", "ferret", "finch", "gecko", "gopher",
    "hawk", "heron", "ibis", "jaguar", "kestrel", "kite",
    "lemur", "lynx", "marmot", "marten", "merlin", "mink",
    "moose", "narwhal", "osprey", "otter", "panther", "puma",
    "raven", "sable", "serval", "skunk", "stoat", "swift",
    "tapir", "thrush", "viper", "vole", "weasel", "wolf"
  ),
  tools = c(
    "adze", "anvil", "auger", "awl", "brace", "caliper", "chisel",
    "clamp", "drawknife", "drill", "file", "gauge", "gimlet",
    "grinder", "hammer", "hatchet", "jack", "lathe", "level",
    "mallet", "mandrel", "maul", "mill", "plane", "planer",
    "pliers", "press", "punch", "rasp", "router", "sander",
    "saw", "scribe", "shaper", "shear", "sledge", "snips",
    "square", "trowel", "vise", "wedge", "wrench"
  ),
  automobiles = c(
    "barracuda", "biscayne", "bonneville", "bronco", "camaro",
    "charger", "comet", "coronet", "corsair", "corvette",
    "cougar", "cyclone", "duster", "fairlane", "falcon",
    "firebird", "galaxie", "gremlin", "hornet", "impala",
    "javelin", "lancer", "maverick", "monaco", "montego",
    "mustang", "nova", "pinto", "polara", "rambler",
    "rebel", "roadrunner", "skylark", "scamp",
    "stingray", "sundance", "torino", "vega", "wildcat"
  ),
  mascots = c(
    "anchor", "arrow", "axe", "badge", "banner", "blade",
    "blaze", "bolt", "boomerang", "buckle", "charge", "crest",
    "crown", "dagger", "ensign", "flame", "flare", "flash",
    "force", "forge", "gale", "herald", "honor", "impact",
    "lance", "legend", "lore", "mark", "might", "pennant",
    "pride", "quest", "rally", "rampart", "ridge", "rise",
    "roar", "shield", "signal", "spark", "spirit", "spire",
    "surge", "titan", "torch", "valor", "vanguard", "vigor"
  )
)

# Valid bank names (exported as a helper for users to discover options)
#' Word bank names available for group redaction
#'
#' Returns the names of the built-in thematic word banks. Pass one of these
#' to the `bank` argument of [col_group()] or [redact_vec()].
#'
#' @return A character vector of bank names.
#' @export
#' @examples
#' word_bank_names()
word_bank_names <- function() names(.word_banks)


# ---- Name banks -------------------------------------------------------

.first_names <- c(
  "Aaron", "Abigail", "Adam", "Adrian", "Alan", "Alice", "Alicia", "Allen",
  "Amanda", "Amber", "Amy", "Andrea", "Andrew", "Angela", "Ann", "Anna",
  "Anthony", "April", "Arthur", "Ashley", "Austin", "Barbara", "Benjamin",
  "Beth", "Betty", "Beverly", "Billy", "Bobby", "Bradley", "Brandon",
  "Brenda", "Brian", "Brittany", "Bruce", "Bryan", "Calvin", "Carl",
  "Carol", "Catherine", "Charles", "Charlotte", "Cheryl", "Chris",
  "Christine", "Christopher", "Cindy", "Claire", "Clarence", "Cody",
  "Colin", "Connie", "Craig", "Crystal", "Curtis", "Cynthia", "Dale",
  "Dana", "Daniel", "David", "Dawn", "Dean", "Deborah", "Denise",
  "Dennis", "Derek", "Diana", "Diane", "Donald", "Donna", "Dorothy",
  "Douglas", "Dylan", "Earl", "Edward", "Elizabeth", "Emily", "Emma",
  "Eric", "Erica", "Ernest", "Ethan", "Eugene", "Eva", "Frances",
  "Frank", "Fred", "Gary", "George", "Gerald", "Gloria", "Grace",
  "Gregory", "Harold", "Harry", "Heather", "Helen", "Henry", "Holly",
  "Howard", "Jacob", "James", "Janet", "Jason", "Jean", "Jeffrey",
  "Jennifer", "Jeremy", "Jesse", "Jessica", "Joan", "Joe", "John",
  "Jonathan", "Joseph", "Joyce", "Judith", "Julia", "Julie", "Justin",
  "Karen", "Katherine", "Kathleen", "Kathryn", "Keith", "Kelly",
  "Kenneth", "Kevin", "Kim", "Kimberly", "Kyle", "Larry", "Laura",
  "Lauren", "Lawrence", "Lee", "Linda", "Lisa", "Logan", "Lori",
  "Louis", "Louise", "Luke", "Madison", "Margaret", "Maria", "Marie",
  "Mark", "Martha", "Martin", "Mary", "Matthew", "Megan", "Melissa",
  "Michael", "Michelle", "Monica", "Nancy", "Nathan", "Nicholas",
  "Nicole", "Noah", "Norma", "Olivia", "Pamela", "Patricia", "Patrick",
  "Paul", "Paula", "Peter", "Philip", "Rachel", "Randy", "Rebecca",
  "Richard", "Robert", "Roger", "Ronald", "Rose", "Roy", "Russell",
  "Ruth", "Ryan", "Sandra", "Sara", "Sarah", "Scott", "Sharon",
  "Shawn", "Shirley", "Sophia", "Stephanie", "Stephen", "Steven",
  "Susan", "Teresa", "Thomas", "Timothy", "Tina", "Todd", "Tyler",
  "Virginia", "Walter", "Wanda", "Wayne", "William", "Zachary"
)

.last_names <- c(
  "Adams", "Alexander", "Allen", "Anderson", "Bailey", "Baker", "Barnes",
  "Bell", "Bennett", "Brooks", "Brown", "Bryant", "Butler", "Campbell",
  "Carter", "Clark", "Collins", "Cook", "Cooper", "Cox", "Davis",
  "Edwards", "Evans", "Fisher", "Fleming", "Foster", "Garcia", "Gonzalez",
  "Grant", "Gray", "Green", "Griffin", "Hall", "Harris", "Hayes",
  "Henderson", "Hill", "Howard", "Hughes", "Jackson", "James", "Jenkins",
  "Johnson", "Jones", "Kelly", "King", "Lane", "Lee", "Lewis", "Long",
  "Lopez", "Martin", "Martinez", "Mason", "Miller", "Mitchell", "Moore",
  "Morgan", "Morris", "Murphy", "Myers", "Nelson", "Nguyen", "Parker",
  "Patterson", "Perry", "Peterson", "Phillips", "Pierce", "Porter",
  "Powell", "Price", "Ramirez", "Reed", "Richardson", "Rivera", "Roberts",
  "Robinson", "Rogers", "Ross", "Russell", "Sanchez", "Sanders", "Scott",
  "Simmons", "Smith", "Stewart", "Sullivan", "Taylor", "Thomas", "Thompson",
  "Torres", "Turner", "Walker", "Ward", "Watson", "White", "Williams",
  "Wilson", "Wood", "Wright", "Young"
)
