# app.R (Kids Water Guide)
suppressWarnings({
  app_dir <- tryCatch({
    if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
      dirname(rstudioapi::getActiveDocumentContext()$path) else getwd()
  }, error = function(e) getwd())
})

# Data files (stored alongside the app)
file_ppb <- file.path(app_dir, "1984_07-2025_06_Port_Phillip_Bay_Water_quality_data.xlsx")
file_wp  <- file.path(app_dir, "1990_02-2025_05_Western_Port_Water_quality_data.xlsx")
file_gl  <- file.path(app_dir, "1990_01-2025_06_Gippsland_Lakes_Water_quality_data.xlsx")

for (p in c(file_ppb, file_wp, file_gl)) if (!file.exists(p)) stop("File not found: ", p)

# Packages
library(shiny)
pkgs <- c("bslib","leaflet","dplyr","readxl","lubridate","stringr","purrr","tibble","htmltools","digest")
need <- setdiff(pkgs, rownames(installed.packages()))
if (length(need)) install.packages(need, repos = "https://cloud.r-project.org")
invisible(lapply(pkgs, library, character.only=TRUE))

# Helpers: parsing and value checks
numify <- function(x){ suppressWarnings(as.numeric(gsub("[^0-9.\\-]", "", as.character(x)))) }
parse_date_any <- function(x){
  if (inherits(x, "Date")) return(as.Date(x))
  if (is.numeric(x)) return(as.Date(x, origin = "1899-12-30"))
  suppressWarnings(lubridate::as_date(x))
}
clip_invalid <- function(x, lo, hi){ ifelse(x < lo | x > hi, NA_real_, x) }

# Numeric formatter for popup text
fmt_num <- function(x){
  y <- suppressWarnings(as.numeric(x))
  d <- ifelse(abs(y) >= 10, 3, 2)
  out <- signif(y, d)
  out[is.na(y)] <- NA
  as.character(out)
}

# Deterministic random pick that rotates over time
pick_rotating <- function(items, key = "", period_seconds = 15){
  if (length(items) == 0) return(NA_character_)
  slot <- floor(as.numeric(Sys.time()) / period_seconds)
  h <- digest::digest(paste0(key, "_", slot), algo = "xxhash64")
  seed <- suppressWarnings(as.integer(strtoi(substr(h, 1, 8), base=16L)))
  if (is.na(seed)) seed <- sample.int(.Machine$integer.max, 1)
  set.seed(seed)
  sample(items, 1)
}

# Content pools used in the UI
FUN_FACTS <- c(
  "Seahorses are fish that swim upright","Dolphins sleep with one eye open",
  "Sea stars can regrow arms","Octopuses have three hearts",
  "Some fish glow under the sea","Penguins can drink salty seawater",
  "Sea turtles can live for more than 50 years","A group of fish is called a school",
  "Crabs wear hard shells called exoskeletons","Some jellyfish are see-through like glass",
  "Clownfish hide in soft sea anemones","A baby fish is called a fry",
  "Seagrass meadows are nurseries for tiny sea animals","Mangroves help keep the water clean",
  "Sea sponges are animals, not plants","Starfish sense with their arms",
  "The fastest fish can beat a city car","Tiny sea snails can drill neat holes in shells",
  "Seaweed is plant-like algae that many animals eat","Shrimp can be smaller than your little fingernail"
)
TRY_THIS_BASE <- c(
  "Shell hunt - find one spiral, one smooth, one bumpy",
  "Beach bingo - spot a crab, a feather, and a striped shell",
  "Sand artist - draw a fish as long as your arm",
  "Wave watcher - count ten big waves in a row",
  "Rock pool explorer - spot tiny crabs and snails",
  "Treasure map - draw a simple map of your beach",
  "Footprints game - can you follow your own trail back",
  "Driftwood drum - tap gentle beats and dance",
  "Sound safari - close eyes and list three ocean sounds",
  "Beach letters - write your name with shells"
)
TRY_THIS_CLEAR  <- c("Starfish spy - look for shapes on the seabed","Pebble window - peek through calm water to the sand","Shadow hunt - can you see fish shadows zip past")
TRY_THIS_CLOUDY <- c("Foam detective - watch bubbles pop and name the shapes","Color quest - find three things that are blue, brown, green","Beach maze - draw a maze in the sand and solve it")
TRY_THIS_WARM   <- c("Toe test - count to ten with toes in the water","Sand bakery - make a warm sand cupcake with a shell on top")
TRY_THIS_COOL   <- c("Skip and splash - ten quick jumps then warm towel time","Stone stacker - build a tiny cool-stone tower")

OCEAN_FRIENDS <- c(
  "🐬 Dolphins leap outside the heads - racing the waves",
  "🐋 Whales pass by in deep seasons - singing low songs",
  "🦭 Fur seals nap on rocks - warming in the sun",
  "🐧 Little penguins parade home at dusk - tiny lines on tiny feet",
  "🐉 Leafy seadragons hide in seagrass - dressed like seaweed",
  "🕊️ Fairy terns skim the surface - quick and light",
  "🐦 Hooded plovers nest in the sand - please watch your step",
  "🪶 Shearwaters glide in flocks - long wings skimming the wind",
  "🐢 Gentle turtles cruise the weeds - calm and steady"
)

# Sheet name helpers for flexible workbooks
normalize <- function(x) gsub("[^a-z0-9]", "", tolower(x))
find_sheet <- function(path, candidates){
  sheets <- try(readxl::excel_sheets(path), silent = TRUE)
  if (inherits(sheets, "try-error")) stop("Can't read sheets in ", basename(path))
  ns <- normalize(sheets)
  for (cand in candidates){
    idx <- which(ns == normalize(cand))
    if (length(idx)) return(sheets[idx[1]])
  }
  for (cand in candidates){
    idx <- which(grepl(normalize(cand), ns, fixed = TRUE))
    if (length(idx)) return(sheets[idx[1]])
  }
  stop("Sheet not found in ", basename(path), ". Have: ",
       paste(sheets, collapse=", "),
       " - looked for one of: ", paste(candidates, collapse=", "))
}

# Read a workbook and return a standardised tibble
read_clean <- function(path, region_name){
  data_sheet <- find_sheet(path, c("Data","Measurements","Sheet1","Sheet 1"))
  meta_sheet_try <- try(find_sheet(path, c("Site Metadata","Sites","Site_Meta","Metadata","Site Info",
                                           "SiteInformation","Locations","Stations")), silent = TRUE)
  
  raw_data <- readxl::read_excel(path, sheet = data_sheet)
  nm <- names(raw_data)
  
  # Map common variants to standard names
  rename_map <- c(
    "site"="site_id","site_code"="site_id","siteid"="site_id","station"="site_id",
    "site_name"="site_name_short","sitename"="site_name_short","beach"="site_name_short",
    "date_sampled"="date","sample_date"="date","sampling_date"="date",
    "chl_a"="CHL_A","chlorophyll_a"="CHL_A","chlorophyll"="CHL_A",
    "turbidity"="Turb","do_mg"="DO_mg","dissolved_oxygen"="DO_mg","do_mg_l"="DO_mg",
    "temperature_c"="Temperature","temp"="Temperature","temp_c"="Temperature",
    "n_total"="N_TOTAL","total_n"="N_TOTAL","tn"="N_TOTAL",
    "lat"="latitude","lon"="longitude","long"="longitude"
  )
  for (k in names(rename_map)){
    if (k %in% tolower(nm) && !(rename_map[[k]] %in% nm)) {
      names(raw_data)[match(k, tolower(nm))] <- rename_map[[k]]
      nm <- names(raw_data)
    }
  }
  
  # Parse and constrain fields of interest
  need_cols_data <- c("site_id","site_name_short","date","CHL_A","Turb","DO_mg","Temperature","N_TOTAL")
  data <- raw_data %>%
    mutate(
      site_id         = if ("site_id" %in% names(.)) .data$site_id else as.character(.data$site_name_short),
      site_name_short = if ("site_name_short" %in% names(.)) .data$site_name_short else as.character(.data$site_id),
      date        = parse_date_any(if ("date" %in% names(.)) .data$date else NA),
      CHL_A       = clip_invalid(numify(if ("CHL_A" %in% names(.)) .data$CHL_A else NA), 0, 1000),
      Turb        = clip_invalid(numify(if ("Turb"  %in% names(.)) .data$Turb  else NA), 0, 1000),
      DO_mg       = clip_invalid(numify(if ("DO_mg" %in% names(.)) .data$DO_mg else NA), 0, 20),
      Temperature = clip_invalid(numify(if ("Temperature" %in% names(.)) .data$Temperature else NA), 0, 40),
      N_TOTAL     = clip_invalid(numify(if ("N_TOTAL" %in% names(.)) .data$N_TOTAL else NA), 0, 5000)
    ) %>%
    select(all_of(need_cols_data)) %>%
    filter(!is.na(site_name_short), !is.na(date)) %>%
    distinct(site_name_short, date, .keep_all = TRUE) %>%
    mutate(site_name_short = stringr::str_squish(as.character(site_name_short)))
  
  # Metadata for coordinates
  meta <- NULL
  if (!inherits(meta_sheet_try, "try-error")){
    raw_meta <- readxl::read_excel(path, sheet = meta_sheet_try)
    nm2 <- names(raw_meta)
    for (k in c("site","site_code","siteid","station")) if (k %in% tolower(nm2) && !"site_id" %in% nm2) names(raw_meta)[match(k, tolower(nm2))] <- "site_id"
    for (k in c("site_name","sitename","beach")) if (k %in% tolower(nm2) && !"site_name_short" %in% nm2) names(raw_meta)[match(k, tolower(nm2))] <- "site_name_short"
    for (k in c("lat")) if (k %in% tolower(nm2) && !"latitude" %in% nm2) names(raw_meta)[match(k, tolower(nm2))] <- "latitude"
    for (k in c("lon","long")) if (k %in% tolower(nm2) && !"longitude" %in% nm2) names(raw_meta)[match(k, tolower(nm2))] <- "longitude"
    meta <- raw_meta %>%
      mutate(
        site_id         = if ("site_id" %in% names(.)) .data$site_id else as.character(.data$site_name_short),
        site_name_short = if ("site_name_short" %in% names(.)) .data$site_name_short else as.character(.data$site_id),
        latitude  = numify(if ("latitude" %in% names(.)) .data$latitude else NA),
        longitude = numify(if ("longitude" %in% names(.)) .data$longitude else NA)
      ) %>%
      select(site_id, site_name_short, latitude, longitude) %>%
      distinct(site_id, .keep_all = TRUE) %>%
      mutate(site_name_short = stringr::str_squish(as.character(site_name_short)))
  } else if (all(c("latitude","longitude") %in% names(raw_data))) {
    meta <- raw_data %>%
      mutate(
        site_id         = if ("site_id" %in% names(.)) .data$site_id else as.character(.data$site_name_short),
        site_name_short = if ("site_name_short" %in% names(.)) .data$site_name_short else as.character(.data$site_id),
        latitude  = numify(.data$latitude),
        longitude = numify(.data$longitude)
      ) %>%
      select(site_id, site_name_short, latitude, longitude) %>%
      distinct(site_id, .keep_all = TRUE) %>%
      mutate(site_name_short = stringr::str_squish(as.character(site_name_short)))
  }
  
  # Join with coordinates and flag region
  if (!is.null(meta)){
    df <- dplyr::left_join(data, meta, by = c("site_id","site_name_short")) %>%
      dplyr::filter(!is.na(latitude), !is.na(longitude)) %>%
      dplyr::arrange(site_name_short, date)
  } else df <- tibble()
  
  if (!nrow(df)) return(tibble(
    site_id=character(), site_name_short=character(), date=as.Date(character()),
    CHL_A=double(), Turb=double(), DO_mg=double(), Temperature=double(), N_TOTAL=double(),
    latitude=double(), longitude=double(), region=character()
  ))
  
  df %>% dplyr::mutate(region = region_name)
}

# Load three regions
ppb <- read_clean(file_ppb, "Port Phillip Bay")
wp  <- read_clean(file_wp,  "Western Port")
gl  <- read_clean(file_gl,  "Gippsland Lakes")

# Combine and compute global bounds
all_df <- dplyr::bind_rows(ppb, wp, gl)
if (nrow(all_df) == 0) stop("No rows after cleaning - datasets lacked coordinates.")
all_regions <- c("All regions", sort(unique(all_df$region)))
all_sites   <- sort(unique(all_df$site_name_short))
min_d <- min(all_df$date, na.rm=TRUE)
max_d <- max(all_df$date, na.rm=TRUE)

# Status code rules and colours
code_to_color <- c(green="#24c38b", amber="#ffb000", red="#e74a5f")
code_to_label <- c(green="Safe", amber="Caution", red="Rest")
region_fills  <- c(
  "Port Phillip Bay"="#d4f6ff",
  "Western Port"    ="#e5ffd9",
  "Gippsland Lakes" ="#ffe6f2"
)
region_border <- "#222"
code_algae   <- function(x) ifelse(is.na(x),"amber", ifelse(x <  2,"green", ifelse(x <=  5,"amber","red")))
code_clarity <- function(x) ifelse(is.na(x),"amber", ifelse(x <= 2,"green", ifelse(x <=  5,"amber","red")))
code_oxygen  <- function(x) ifelse(is.na(x),"amber", ifelse(x >= 6,"green", ifelse(x >=  4,"amber","red")))
code_nutr    <- function(x) ifelse(is.na(x),"amber", ifelse(x < 250,"green", ifelse(x <= 600,"amber","red")))
code_temp    <- function(x) ifelse(is.na(x),"amber", ifelse(x < 24,"green", ifelse(x <= 27,"amber","red")))
overall_code <- function(a,c,o,n,t){
  red_any <- (a=="red") | (c=="red") | (o=="red") | (n=="red") | (t=="red")
  amb_any <- (a=="amber") | (c=="amber") | (o=="amber") | (n=="amber")
  ifelse(red_any, "red", ifelse(amb_any, "amber", "green"))
}

# Short explanatory strings for kids panel
kidline <- function(metric, code) switch(metric,
                                         "Algal Bloom"=switch(code, green="Tiny plants. A few is fine. Too many can make fish tired.",
                                                              amber="Some algae around. Keep watch.",
                                                              red  ="Lots of algae. Fish and crabs may struggle."),
                                         "Clarity"    =switch(code, green="Clear like a window. Great for shell spotting.",
                                                              amber="A little cloudy like frosted glass.",
                                                              red  ="Cloudy like stirred sand. Look first."),
                                         "Oxygen"     =switch(code, green="Plenty of bubbles. Sea life feels strong.",
                                                              amber="Fewer bubbles right now.",
                                                              red  ="Low bubbles. Let the water rest."),
                                         "Nutrients"  =switch(code, green="Just enough food in the water.",
                                                              amber="Extra food. Algae could grow fast.",
                                                              red  ="Too much food. Algae can take over."),
                                         "Temperature"=switch(code, green="Cool and comfy.",
                                                              amber="Getting warm. Take short dips.",
                                                              red  ="Very warm. Animals get sleepy."),
                                         "")

# Theming
theme <- bslib::bs_theme(
  version = 5,
  bootswatch = "minty",
  primary   = "#1a7bd6",
  bg        = "#f3f8ff",
  fg        = "#202022",
  base_font    = bslib::font_google("Nunito"),
  heading_font = bslib::font_google("Baloo 2")
)

# UI
ui <- bslib::page_navbar(
  title = "Kids’ Water Guide - Port Phillip Bay, Western Port & Gippsland Lakes",
  theme = theme,
  header = tagList(
    # CSS and JS assets
    tags$head(
      tags$style(HTML('
:root{ --sea1:#8fd3ff; --sea2:#a4ffd8; --sea3:#ffe6a3; --sea4:#b7f2ff; }
body{
  background:
    radial-gradient(1200px 700px at -10% 0%, var(--sea1), transparent 60%),
    radial-gradient(1200px 800px at 110% 10%, var(--sea2), transparent 60%),
    radial-gradient(900px 700px at 50% 120%, var(--sea3), transparent 60%),
    radial-gradient(800px 500px at 20% 100%, var(--sea4), transparent 60%);
}
.container-lg{ max-width:1280px; }
.top-grid{ display:grid; grid-template-columns: 1.3fr 1fr; gap:16px; align-items:start; }
@media (max-width:1200px){ .top-grid{ grid-template-columns:1fr; } }
#map{ height: 68vh !important; }
.rightcol{ display:grid; grid-template-rows:auto auto 1fr; gap:10px; }

.card-cute{
  background:
    linear-gradient(135deg, rgba(255,255,255,.98), rgba(255,255,255,.98)),
    radial-gradient(12px 12px at 8px 8px, #e9f7ff 30%, transparent 31%) 0 0 / 28px 28px,
    radial-gradient(12px 12px at 22px 22px, #fffbe6 30%, transparent 31%) 0 0 / 28px 28px;
  border:2px solid #000; border-radius:22px; padding:14px; box-shadow:6px 6px 0 #00000018;
}
.big-step{ font-weight:800; }

.map-legend{ background:#ffffffee; border:2px solid #000; border-radius:12px; padding:8px 10px; font-weight:800; z-index:6; }
.mini-dot{ width:12px;height:12px;border-radius:50%;display:inline-block;border:2px solid #000;margin-right:6px }

.story p{ margin:0 0 8px 0; }
.story b{ font-weight:900; }
.story .metric{ font-weight:800; }
.muted{ opacity:.7; font-size:.95rem; }

/* Insights carousel */
.insights-kids{
  background:
    linear-gradient(135deg, rgba(255,255,255,.95), rgba(255,255,255,.95)),
    radial-gradient(40px 40px at 20% 25%, #c6ffe9 30%, transparent 31%) 0 0 / 80px 80px,
    radial-gradient(40px 40px at 70% 60%, #ffeab6 30%, transparent 31%) 0 0 / 88px 88px,
    radial-gradient(40px 40px at 30% 80%, #e6edff 30%, transparent 31%) 0 0 / 76px 76px;
  border:2px solid #0c8b6f; border-radius:22px; box-shadow:6px 6px 0 #00000018;
  padding:14px; color:#103b3c; margin-bottom:0;
  /* make it taller so no empty gap below */
  min-height: 260px;
}
.insights-title{ font-weight:900; font-size:1.15rem; margin:0 0 6px 0; color:#0a6b56 !important; }

.snap-wrap{ position:relative; padding:0 48px; }
@media (max-width:720px){ .snap-wrap{ padding:0 40px; } }
@media (max-width:480px){ .snap-wrap{ padding:0 34px; } }

.snap-track{
  display:flex; gap:14px; overflow-x:auto; scroll-snap-type:x mandatory;
  -webkit-overflow-scrolling: touch; scrollbar-width:none;
}
.snap-track::-webkit-scrollbar{ display:none; }

.snap-slide{
  flex:0 0 100%; scroll-snap-align:start;
  border:2px solid #000; border-radius:18px;
  padding:18px 22px;
  background:#fff; box-shadow:4px 4px 0 #00000014; min-height:220px;
  display:flex; flex-direction:column; justify-content:center;
}

.slide-title{ font-weight:900; margin-bottom:6px; display:flex; align-items:center; justify-content:space-between; gap:10px; }
.slide-body{ font-weight:800; line-height:1.25; }

.inline-row{ display:flex; flex-wrap:wrap; gap:10px 14px; align-items:flex-start; }
.inline-badge{ display:inline-block; padding:3px 10px; border-radius:999px; border:2px solid #000; background:#fff; font-weight:900; box-shadow:3px 3px 0 #00000015; color:#103b3c !important; white-space:nowrap; }
.inline-text{ flex:1 1 auto; min-width:200px; }

.snap-dots{ display:flex; justify-content:center; gap:8px; margin-top:8px; }
.snap-dots .dot{ width:10px; height:10px; border-radius:50%; border:2px solid #000; background:#fff; opacity:.6; }
.snap-dots .dot.active{ opacity:1; background:#0a6b56; }

/* arrows */
.snap-left,.snap-right{
  position:absolute; top:50%; transform:translateY(-50%);
  background:#fff; border:2px solid #000; width:36px; height:36px; border-radius:50%;
  display:grid; place-items:center; box-shadow:3px 3px 0 #00000018; cursor:pointer; user-select:none;
  z-index:2;
}
.snap-left{ left:6px; }
.snap-right{ right:6px; }
.snap-left:after{ content:"‹"; font-size:20px; font-weight:900; line-height:1; }
.snap-right:after{ content:"›"; font-size:20px; font-weight:900; line-height:1; }

/* Quick Help */
details.quickhelp{
  border:2px solid #000; border-radius:22px; padding:14px; background:#ffffff;
  box-shadow:6px 6px 0 #00000018; width:100%;
}
details.quickhelp > summary{ list-style:none; cursor:pointer; font-weight:900; font-size:1.05rem; }
details.quickhelp > summary::-webkit-details-marker{ display:none; }
details.quickhelp > summary:before{ content:"▸"; margin-right:8px; font-weight:900; }
details.quickhelp[open] > summary:before{ content:"▾"; }

/* Background bubbles and critters */
.ocean-bubbles{ position:fixed; inset:0; pointer-events:none; z-index:0; }
.ocean-bubbles span{
  position:absolute; border-radius:50%; opacity:.9;
  background:radial-gradient(circle at 30% 30%, #fff, rgba(255,255,255,.25));
  animation: rise 10s linear infinite;
  filter: drop-shadow(0 0 8px rgba(255,255,255,.7));
}
@keyframes rise{ from{ transform:translateY(30px) scale(.9) } to{ transform:translateY(-120vh) scale(1.1) } }

.ocean-critters{ position:fixed; inset:0; pointer-events:none; z-index:0; }
.ocean-critters span{
  position:absolute; left:-12%;
  bottom:8vh;
  font-size:2rem; opacity:.9; filter: drop-shadow(0 2px 2px rgba(0,0,0,.08));
  animation: swimHoriz linear infinite;
}
@keyframes swimHoriz{
  0%   { transform: translateX(0) scaleX(1); }
  45%  { transform: translateX(115vw) scaleX(1); }
  50%  { transform: translateX(115vw) scaleX(-1); }
  95%  { transform: translateX(0) scaleX(-1); }
  100% { transform: translateX(0) scaleX(-1); }
}

/* Seaweeds band along the bottom */
.ocean-seaweeds{
  position:fixed; left:0; right:0; bottom:0;
  height:16vh; pointer-events:none; z-index:0;
  display:flex; align-items:flex-end; justify-content:space-between;
  padding:0 2vw 0.8vh;
  opacity:.95;
}
.weed{
  --h: 12vh;
  width:1.1vw; min-width:6px; max-width:14px;
  height:var(--h);
  background: linear-gradient(180deg, #1fbf74, #0f8d58);
  border-radius:12px 12px 0 0;
  position:relative;
  transform-origin:bottom center;
  animation: sway 5.6s ease-in-out infinite alternate;
  filter: drop-shadow(0 3px 2px rgba(0,0,0,.08));
}
.weed:before, .weed:after{
  content:""; position:absolute; bottom:36%;
  width:80%; height:36%;
  background:inherit; border-radius:12px 12px 0 0; opacity:.88;
}
.weed:before{ left:-55%; transform:rotate(-22deg); }
.weed:after{  right:-55%; transform:rotate(22deg); }
.weed.s2{ --h:10vh; animation-duration:6.4s; }
.weed.s3{ --h:8.5vh; animation-duration:6.9s; }
.weed.s4{ --h:11vh; animation-duration:6.1s; }
@keyframes sway{
  0% { transform: rotate(-2.4deg); }
  100%{ transform: rotate(2.4deg); }
}

/* Layering order to keep UI above background */
.navbar, .container-lg, .card-cute, .insights-kids, .map-legend, .leaflet-container, .leaflet-control {
  position:relative; z-index:5;
}

/* Date input with calendar icon on the right (centered) */
.date-wrap{ position:relative; height:48px; }           /* give the wrapper a fixed height */
div#pick_date{ height:48px; }                            /* match wrapper */
div#pick_date input.form-control{
  height:48px; line-height:48px; padding-right:2.2rem;  /* make input taller and leave room for icon */
}
.date-wrap .calendar-ico{
  position:absolute; right:10px; top:50%; transform:translateY(-50%);  /* true vertical center */
  font-size:1.15rem; opacity:.9; cursor:pointer; pointer-events:auto;
}

/* Confetti (wasn’t animating before) */
@keyframes confetti-fall{
  0%   { transform: translateY(-20px) rotate(0deg);   opacity:.95; }
  100% { transform: translateY(110vh) rotate(720deg); opacity:.95; }
}
.confetti-toast{
  position:fixed; left:50%; bottom:18px; transform:translateX(-50%);
  background:#fff; border:2px solid #000; border-radius:14px; padding:8px 14px;
  box-shadow:4px 4px 0 #00000018; font-weight:900; z-index:9999; opacity:0; transition:.25s;
}
.confetti-toast.show{ opacity:1; }

/* Misc */
.flash{ animation: flash 1.2s ease-in-out 1; }
@keyframes flash{ 0%{box-shadow:0 0 0 0 rgba(26,123,214,.0)} 50%{box-shadow:0 0 0 10px rgba(26,123,214,.25)} 100%{box-shadow:0 0 0 0 rgba(26,123,214,0)} }

/* Hide legacy egg classes if present */
.egg,.eggs,.egg-stack,.traffic-eggs,.traffic-ovals,.status-egg,.status-oval,[class*="egg" i],[class*="oval" i]{display:none !important;}
      ')),
      tags$script(HTML('
(function(){
  function makeConfettiBurst(durationMs=1600, count=120){
    const colors = ["#24c38b","#ffb000","#1a7bd6","#ff6ec7","#ffd166","#06d6a0","#118ab2"];
    const box = document.createElement("div");
    Object.assign(box.style,{position:"fixed",inset:"0",pointerEvents:"none",zIndex:9999});
    document.body.appendChild(box);
    for(let i=0;i<count;i++){
      const p=document.createElement("span");
      const s=6+Math.random()*6;
      Object.assign(p.style,{
        position:"absolute", top:"-20px", left:(Math.random()*100)+"%",
        width:s+"px",height:s+"px", background:colors[i%colors.length],
        borderRadius:"2px", opacity:"0.9", willChange:"transform",
        animation:"confetti-fall "+(1.4+Math.random()*1.4)+"s linear "+(Math.random()*0.6)+"s 1",
        transform:"rotate("+(Math.random()*360)+"deg)"
      });
      box.appendChild(p);
    }
    setTimeout(()=>{ box.remove(); }, durationMs);
  }

  function setDatePlaceholder(){
    var el = document.querySelector("div#pick_date input.form-control");
    if(el){ el.setAttribute("placeholder","Pick a day"); el.value = el.value || ""; }
  }
  document.addEventListener("DOMContentLoaded", setDatePlaceholder);
  setTimeout(setDatePlaceholder, 0);

  function hookCalendarIcon(){
    var ico = document.querySelector(".date-wrap .calendar-ico");
    var input = document.querySelector("div#pick_date input.form-control");
    if(ico && input){
      ico.addEventListener("click", function(){
        input.focus(); input.click();
      });
    }
  }
  document.addEventListener("DOMContentLoaded", hookCalendarIcon);
  setTimeout(hookCalendarIcon, 0);

  window.Shiny && Shiny.addCustomMessageHandler("scrollTo", function(id){
    var el = document.getElementById(id);
    if(!el) return;
    el.scrollIntoView({behavior:"smooth", block:"center"});
    el.classList.add("flash"); setTimeout(()=>el.classList.remove("flash"), 1200);
  });
  window.Shiny && Shiny.addCustomMessageHandler("setHint", function(html){
    var el = document.getElementById("hintLine"); if(el){ el.innerHTML = html; }
  });
  window.Shiny && Shiny.addCustomMessageHandler("celebrate", function(msg){
    makeConfettiBurst();
    const t = document.createElement("div");
    t.className="confetti-toast";
    t.innerHTML="<div class=\\"t-title\\">"+(msg.title||"Safe spot!")+"</div><div class=\\"t-sub\\">"+(msg.subtitle||"The water sparkles for you. Splash and play.")+"</div>";
    document.body.appendChild(t);
    setTimeout(()=>{ t.classList.add("show"); }, 50);
    setTimeout(()=>{ t.classList.remove("show"); t.remove(); }, 2200);
  });

  window.initInsightsCarousel = function(rootId){
    const root = document.getElementById(rootId);
    if(!root) return;
    const track = root.querySelector(".snap-track");
    const slides = Array.from(root.querySelectorAll(".snap-slide"));
    const dotsC = root.querySelector(".snap-dots");
    const left = root.querySelector(".snap-left");
    const right = root.querySelector(".snap-right");
    if(!track || !slides.length || !dotsC) return;

    if(!dotsC._built){
      dotsC.innerHTML = "";
      slides.forEach((_,i)=>{
        const d = document.createElement("button");
        d.type="button"; d.className="dot"; d.setAttribute("aria-label","Go to slide "+(i+1));
        d.addEventListener("click", ()=>goTo(i,true));
        dotsC.appendChild(d);
      });
      dotsC._built = true;
    }

    let idx = +sessionStorage.getItem("insightsIdx");
    if (isNaN(idx)) idx = 0;

    function setActive(i){
      Array.from(dotsC.children).forEach((d,j)=>d.classList.toggle("active", j===i));
      sessionStorage.setItem("insightsIdx", String(i));
    }
    function goTo(i){
      idx = (i+slides.length)%slides.length;
      const w = track.clientWidth;
      track.scrollTo({left: idx*w, behavior:"smooth"});
      setActive(idx);
    }
    function next(){ goTo(idx+1); }
    function prev(){ goTo(idx-1); }

    left && left.addEventListener("click", prev);
    right && right.addEventListener("click", next);

    let sx=null, ss=null;
    track.addEventListener("pointerdown",(e)=>{ sx=e.clientX; ss=track.scrollLeft; track.setPointerCapture(e.pointerId); });
    track.addEventListener("pointermove",(e)=>{ if(sx!=null){ track.scrollLeft = ss - (e.clientX-sx); }});
    track.addEventListener("pointerup",()=>{ if(sx!=null){ const w = track.clientWidth; const i = Math.round(track.scrollLeft / w); sx=null; ss=null; goTo(i); }});

    let io = new IntersectionObserver((entries)=>{
      entries.forEach(en=>{
        if(en.isIntersecting){
          const i = slides.indexOf(en.target);
          if(i>=0){ idx=i; setActive(i); }
        }
      });
    }, {root: track, threshold: 0.6});
    slides.forEach(s=>io.observe(s));

    setTimeout(()=>goTo(idx), 0);
    root._goCurrent = ()=>goTo(idx);
  };
})();
      '))
    ),
    # Background layers
    tags$div(class="ocean-bubbles",
             lapply(1:48, function(i){
               left <- sample(2:98,1); delay <- runif(1,0,10); size <- sample(12:26,1)
               tags$span(style=sprintf("left:%d%%; bottom:-20px; width:%dpx; height:%dpx; animation-delay:%.2fs;", left,size,size,delay))
             })
    ),
    tags$div(class="ocean-critters",
             lapply(1:12, function(i){
               emojis <- c("🐬","🐢","🐠","🦀","🐋","🐡","🐙","🦑")
               emoji <- sample(emojis,1)
               bottom <- sample(4:24,1)
               dur <- runif(1, 18, 34)
               delay <- runif(1, 0, 18)
               size <- runif(1, 1.6, 2.6)
               tags$span(style=sprintf("bottom:%dvh; font-size:%.1frem; animation-duration:%.1fs; animation-delay:%.1fs;", bottom,size,dur,delay), emoji)
             })
    ),
    tags$div(class="ocean-seaweeds",
             lapply(1:18, function(i){
               cls <- sample(c("weed","weed s2","weed s3","weed s4"), 1)
               tags$div(class=cls)
             })
    )
  ),
  
  # Main content
  div(class="container-lg pt-2",
      div(class="card-cute mb-2",
          tags$div(style="font-weight:900; font-size:1.35rem;", "Play by the Bay - Pick a Friendly Splash Spot"),
          HTML("
        <p>Welcome, Ocean Heroes. These bays are the homeland of ocean friends.</p>
        <p>Pick a region, choose a beach, and set a day. We will tell the water story for that place - how clear it looks, how many bubbles help animals breathe, how many tiny plants are growing, how much food is floating, and how warm it feels.</p>
      ")
      ),
      
      div(class="top-grid",
          # Map and insights
          div(
            bslib::card(class="card-cute", card_header = "Tap a region or a beach to learn its story",
                        leafletOutput("map", height = "68vh")
            ),
            bslib::card(class="insights-kids",
                        div(class="insights-title", "Play by the Bay - Quick Wins"),
                        tags$div(id="insightsCarousel", class="snap-wrap",
                                 tags$button(type="button", class="snap-left",  `aria-label`="Previous"),
                                 tags$div(class="snap-track",
                                          tags$div(class="snap-slide",
                                                   tags$div(class="slide-title","🏆 Top Picks"),
                                                   tags$div(class="slide-body",
                                                            span(class="inline-badge","Top"),
                                                            span(id="top_picks", class="inline-text", uiOutput("top_picks", inline=TRUE))
                                                   )
                                          ),
                                          tags$div(class="snap-slide",
                                                   tags$div(class="slide-title d-flex items-center justify-between",
                                                            HTML("🧠 + 🎒 Ocean Bits"),
                                                            span(class="inline-badge","↻ refreshes")
                                                   ),
                                                   tags$div(class="slide-body",
                                                            div(class="inline-row",
                                                                span(class="inline-badge","Fun fact"),
                                                                span(id="bits_fact", class="inline-text", uiOutput("bits_fact", inline=TRUE))
                                                            ),
                                                            div(class="inline-row mt-1",
                                                                span(class="inline-badge","Try this"),
                                                                span(id="bits_try", class="inline-text", uiOutput("bits_try", inline=TRUE))
                                                            ),
                                                            div(class="inline-row mt-1",
                                                                span(class="inline-badge","Ocean friend"),
                                                                span(id="bits_friend", class="inline-text", uiOutput("bits_friend", inline=TRUE))
                                                            )
                                                   )
                                          ),
                                          tags$div(class="snap-slide",
                                                   tags$div(class="slide-title","🧭 Tip"),
                                                   tags$div(class="slide-body",
                                                            span(class="inline-badge","Map tip"),
                                                            span(class="inline-text",
                                                                 HTML("Shade shows the region - pins show beaches - click a shaded area to zoom")
                                                            )
                                                   )
                                          )
                                 ),
                                 tags$button(type="button", class="snap-right", `aria-label`="Next"),
                                 tags$div(class="snap-dots")
                        ),
                        tags$script(HTML("setTimeout(function(){ if(window.initInsightsCarousel) window.initInsightsCarousel('insightsCarousel'); }, 0);"))
            )
          ),
          
          # Controls and story
          div(class="rightcol",
              bslib::card(class="card-cute", id="pickCard",
                          div(class="big-step","Pick a region"),
                          selectInput("region", NULL, choices=all_regions, selected="All regions", width="100%"),
                          div(class="big-step mt-2","Pick a beach"),
                          selectInput("site", NULL, choices=c("All sites", all_sites), selected="All sites", width="100%"),
                          div(class="big-step mt-2 d-flex align-items-center justify-between",
                              span("Pick a day"), NULL
                          ),
                          div(class="date-wrap",
                              # Default to the latest available date in the dataset
                              dateInput("pick_date", NULL, value = max_d, min=min_d, max=max_d, width="100%"),
                              span(class="calendar-ico","📅")
                          ),
                          div(class="mt-3 d-flex gap-2",
                              actionButton("apply", "OK", class="btn btn-primary"),
                              actionButton("reset", "Reset", class="btn btn-outline-secondary")
                          ),
                          div(class="mt-2 small text-muted", id="hintLine",
                              "Step 1 - pick a region. Step 2 - pick a beach. Step 3 - pick a day. Step 4 - tap OK.")
              ),
              bslib::card(class="card-cute", card_header=uiOutput("panel_title"), id="storyCard",
                          div(class="story", uiOutput("story_block"))
              )
          )
      ),
      
      # Bottom quick help
      div(class="mt-3", id="quickHelpBottom",
          tags$details(class="quickhelp", open=NA,
                       tags$summary(HTML("🌎 Quick Help for Kids")),
                       div(class="qh-line", HTML("🌿 <b>Algae</b> - tiny plants. A little is okay - too much makes fish tired")),
                       div(class="qh-line", HTML("👀 <b>Clarity</b> - clear like a window is best. Cloudy like lemonade - look first")),
                       div(class="qh-line", HTML("🫧 <b>Oxygen</b> - more bubbles means happier sea life - around <b>6 mg/L+</b> is strong")),
                       div(class="qh-line", HTML("🍔 <b>Food for water (nutrients)</b> - after rain there can be extra food that grows algae fast")),
                       div(class="qh-line", HTML("🌡️ <b>Temperature</b> - cool is comfy. Very warm water makes animals sleepy - take short dips")),
                       div(class="qh-line", HTML("<b>Tip:</b> click a <b>shaded region</b> to zoom. Pins are beaches. <span style='color:#24c38b;font-weight:900'>Green</span> = splash - <span style='color:#ffb000;font-weight:900'>Amber</span> = step carefully - <span style='color:#e74a5f;font-weight:900'>Red</span> = rest"))
          )
      )
  )
)

# Server
server <- function(input, output, session){
  # Current selections kept in a reactive list
  rv <- reactiveValues(region_sel="All regions", site_sel="All sites", date_sel=max_d)
  tick15 <- reactiveTimer(15000)  # periodic refresh for bits/facts
  
  set_hint <- function(txt){ session$sendCustomMessage("setHint", txt) }
  scroll_flash <- function(id){ session$sendCustomMessage("scrollTo", id) }
  celebrate_safe <- function(){ session$sendCustomMessage("celebrate", list(title="Safe spot!", subtitle="The water sparkles for you. Splash and play.")) }
  
  # Update site options when region changes
  observeEvent(input$region, {
    sites <- if (is.null(input$region) || input$region=="All regions") all_sites else sort(unique(all_df$site_name_short[all_df$region==input$region]))
    updateSelectInput(session, "site", choices=c("All sites", sites), selected="All sites")
    if (input$region=="All regions") set_hint("Now pick a beach - you can also tap a pin on the map")
    else set_hint("Great - pick a beach in this region, then a day")
  }, ignoreInit = TRUE)
  
  # Hinting when site changes
  observeEvent(input$site, {
    if (input$site=="All sites") set_hint("Pick a day - or tap a pin")
    else set_hint("Good pick - choose a day, then tap OK")
  }, ignoreInit = TRUE)
  
  # Hinting when date changes
  observeEvent(input$pick_date, { set_hint("Looks good - tap OK to show the story") }, ignoreInit = TRUE)
  
  # Choose latest row that has Temperature when available
  pick_latest_with_temp <- function(tbl){
    tbl <- tbl[order(tbl$date, decreasing=TRUE),]
    idx <- which(!is.na(tbl$Temperature))
    if (length(idx)) tbl[idx[1], , drop=FALSE] else tbl[1, , drop=FALSE]
  }
  prev_row <- function(site, date_cut){
    prev <- all_df %>% dplyr::filter(site_name_short==site, date < as.Date(date_cut)) %>% dplyr::arrange(dplyr::desc(date))
    if (nrow(prev)==0) return(NULL)
    pick_latest_with_temp(prev)
  }
  
  # Map data for the current filters
  map_data <- reactive({
    sub <- all_df[all_df$date <= as.Date(rv$date_sel), ]
    if (!is.null(rv$region_sel) && rv$region_sel != "All regions") sub <- sub[sub$region==rv$region_sel,]
    if (nrow(sub)==0) return(all_df[0,])
    split_df <- split(sub, sub$site_name_short)
    mdf <- purrr::list_rbind(purrr::map(split_df, pick_latest_with_temp)) %>%
      dplyr::filter(!is.na(longitude), !is.na(latitude)) %>%
      dplyr::mutate(
        sample_date = date,
        a = code_algae(CHL_A), c = code_clarity(Turb), o = code_oxygen(DO_mg),
        n = code_nutr(N_TOTAL), t = code_temp(Temperature),
        overall = overall_code(a,c,o,n,t),
        color = unname(code_to_color[overall])
      )
    
    dot <- function(code){ sprintf("<span class=\"mini-dot\" style=\"background:%s\"></span>", unname(code_to_color[code])) }
    status <- ifelse(mdf$overall=="green","Splash time",
                     ifelse(mdf$overall=="amber","Step carefully","Better for sandcastles"))
    when_line <- ifelse(as.Date(rv$date_sel) > mdf$sample_date,
                        paste0("No new test since ", format(mdf$sample_date, "%d %b %Y")),
                        paste0("Tested on ", format(mdf$sample_date, "%d %b %Y")))
    kid_a <- vapply(mdf$a, function(cd) kidline("Algal Bloom", cd), character(1))
    kid_c <- vapply(mdf$c, function(cd) kidline("Clarity", cd),     character(1))
    kid_o <- vapply(mdf$o, function(cd) kidline("Oxygen", cd),      character(1))
    kid_n <- vapply(mdf$n, function(cd) kidline("Nutrients", cd),   character(1))
    kid_t <- vapply(mdf$t, function(cd) kidline("Temperature", cd), character(1))
    
    v_chl <- ifelse(is.na(mdf$CHL_A), "-", paste0(fmt_num(mdf$CHL_A)," µg/L"))
    t_chl <- ifelse(is.na(mdf$CHL_A), "", paste0(" • ", kid_a))
    v_trb <- ifelse(is.na(mdf$Turb), "-", paste0(fmt_num(mdf$Turb)," NTU"))
    t_trb <- ifelse(is.na(mdf$Turb), "", paste0(" • ", kid_c))
    v_do  <- ifelse(is.na(mdf$DO_mg), "-", paste0(fmt_num(mdf$DO_mg)," mg/L"))
    t_do  <- ifelse(is.na(mdf$DO_mg), "", paste0(" • ", kid_o))
    v_n   <- ifelse(is.na(mdf$N_TOTAL), "-", paste0(fmt_num(mdf$N_TOTAL)," µg/L"))
    t_n   <- ifelse(is.na(mdf$N_TOTAL), "", paste0(" • ", kid_n))
    v_t   <- ifelse(is.na(mdf$Temperature), "-", paste0(fmt_num(mdf$Temperature)," °C"))
    t_t   <- ifelse(is.na(mdf$Temperature), "", paste0(" • ", kid_t))
    
    mdf$popup_txt <- paste0(
      "<b>", mdf$site_name_short, "</b> · <i>", mdf$region, "</i><br/>",
      status, " • <i>", when_line, "</i><br/>",
      dot(mdf$a)," Algae: ", v_chl, t_chl,
      "<br/>", dot(mdf$c)," Clarity: ", v_trb, t_trb,
      "<br/>", dot(mdf$o)," Oxygen: ", v_do,  t_do,
      "<br/>", dot(mdf$n)," Nutrients: ", v_n, t_n,
      "<br/>", dot(mdf$t)," Temp: ", v_t, t_t
    )
    mdf$label_txt <- paste0("[", mdf$region, "] ", mdf$site_name_short, " : ", unname(code_to_label[mdf$overall]))
    mdf
  })
  
  # Region polygons and label positions
  region_polys <- reactive({
    dat <- all_df[all_df$date <= as.Date(rv$date_sel),]
    res <- list(); cents <- list()
    for (nm in unique(dat$region)){
      pts <- dat %>% dplyr::filter(region==nm, !is.na(longitude), !is.na(latitude)) %>% dplyr::distinct(longitude, latitude)
      if (nrow(pts) == 0) next
      cents[[nm]] <- c(lon = mean(pts$longitude), lat = mean(pts$latitude))
      if (nrow(pts) >= 3){
        h <- chull(pts$longitude, pts$latitude)
        res[[nm]] <- pts[h, , drop=FALSE]
      } else {
        center <- colMeans(pts)
        res[[nm]] <- data.frame(
          longitude=center[1] + c(-0.05,0.05,0.05,-0.05),
          latitude =center[2] + c(-0.05,-0.05,0.05,0.05)
        )
      }
    }
    list(polys=res, cents=cents)
  })
  
  # Apply and reset actions
  observeEvent(input$apply, {
    rv$region_sel <- input$region
    rv$site_sel   <- input$site
    rv$date_sel   <- if (is.na(input$pick_date) || is.null(input$pick_date)) max_d else as.Date(input$pick_date)
    scroll_flash("storyCard")
    if (!is.null(rv$site_sel) && rv$site_sel != "All sites") {
      sub <- all_df %>% dplyr::filter(site_name_short==rv$site_sel, date <= as.Date(rv$date_sel))
      if (nrow(sub)>0){
        row <- pick_latest_with_temp(sub)
        codes <- list(a=code_algae(row$CHL_A), c=code_clarity(row$Turb), o=code_oxygen(row$DO_mg),
                      n=code_nutr(row$N_TOTAL), t=code_temp(row$Temperature))
        if (overall_code(codes$a,codes$c,codes$o,codes$n,codes$t)=="green") celebrate_safe()
      }
    }
  })
  
  observeEvent(input$reset, {
    updateSelectInput(session, "region", selected="All regions")
    updateSelectInput(session, "site",   choices=c("All sites", all_sites), selected="All sites")
    updateDateInput(session, "pick_date", value = max_d, min = min_d, max = max_d)
    rv$region_sel <- "All regions"; rv$site_sel <- "All sites"; rv$date_sel <- max_d
    set_hint("Start again - pick a region, beach, day and then click OK"); scroll_flash("pickCard")
  })
  
  # Click handlers from the map
  observeEvent(input$map_marker_click, {
    id <- input$map_marker_click$id
    reg <- input$map_marker_click$group
    if (!is.null(id) && id %in% all_sites) {
      updateSelectInput(session, "region", selected = ifelse(is.null(reg), "All regions", reg))
      sites <- if (is.null(reg) || reg=="All regions") all_sites else sort(unique(all_df$site_name_short[all_df$region==reg]))
      updateSelectInput(session, "site", choices=c("All sites", sites), selected=id)
      set_hint("Good pick - choose a day, then tap OK"); scroll_flash("pickCard")
    }
  })
  
  observeEvent(input$map_shape_click, {
    sid <- input$map_shape_click$id
    if (!is.null(sid) && startsWith(sid, "poly_")){
      reg <- sub("^poly_", "", sid)
      if (reg %in% unique(all_df$region)){
        updateSelectInput(session, "region", selected = reg)
        rv$region_sel <- reg
        rp <- region_polys()$polys[[reg]]
        if (!is.null(rp) && nrow(rp) > 0){
          leafletProxy("map") %>% fitBounds(
            lng1=min(rp$longitude, na.rm=TRUE), lat1=min(rp$latitude, na.rm=TRUE),
            lng2=max(rp$longitude, na.rm=TRUE), lat2=max(rp$latitude, na.rm=TRUE)
          )
        }
        set_hint(paste0("Great - you are in ", reg, ". Pick a beach, then a day, and tap OK"))
        scroll_flash("pickCard")
      }
    }
  }, ignoreInit = TRUE)
  
  # Base map and label overlay
  output$map <- renderLeaflet({
    leaflet(options = leafletOptions(minZoom=7, maxZoom=16)) %>%
      addMapPane("basemap", zIndex = 200) %>%
      addMapPane("regions", zIndex = 410) %>%
      addMapPane("region-labels", zIndex = 420) %>%
      addMapPane("labels", zIndex = 600) %>%
      addMapPane("site-markers", zIndex = 630) %>%
      addProviderTiles(providers$Esri.OceanBasemap, options = providerTileOptions(pane = "basemap")) %>%
      addProviderTiles(providers$CartoDB.PositronOnlyLabels, options = providerTileOptions(pane = "labels", opacity = 0.95))
  })
  
  # Legends and layer updates when filters change
  add_dynamic_legends <- function(proxy, regions_present){
    proxy %>% clearControls()
    proxy <- proxy %>% addControl(html = HTML(sprintf(
      "<div class='map-legend'>
         <div><span class='mini-dot' style='background:%s'></span> Safe</div>
         <div><span class='mini-dot' style='background:%s'></span> Caution</div>
         <div><span class='mini-dot' style='background:%s'></span> Rest</div>
       </div>", code_to_color["green"], code_to_color["amber"], code_to_color["red"]
    )), position = "topleft")
    if (length(regions_present)){
      html_rows <- vapply(regions_present, function(nm){
        col <- region_fills[[nm]]; if (is.null(col)) col <- "#eee"
        sprintf("<div><span class='mini-dot' style='background:%s'></span> %s</div>", col, nm)
      }, character(1))
      proxy <- proxy %>% addControl(html = HTML(
        paste0("<div class='map-legend' style='margin-top:6px'>", paste(html_rows, collapse=""), "</div>")
      ), position = "topleft")
    }
    proxy
  }
  
  observeEvent(list(rv$region_sel, rv$site_sel, rv$date_sel), {
    mdf <- map_data()
    rp  <- region_polys()
    polys <- rp$polys; cents <- rp$cents
    
    proxy <- leafletProxy("map") %>% clearMarkers() %>% clearPopups() %>% clearShapes() %>% clearMarkerClusters()
    regions_present <- sort(unique(c(mdf$region, names(polys))))
    proxy <- add_dynamic_legends(proxy, regions_present)
    
    # Region polygons
    for (nm in names(polys)){
      poly <- polys[[nm]]
      if (!is.null(poly) && nrow(poly) > 2){
        sel <- !is.null(rv$region_sel) && rv$region_sel != "All regions" && identical(nm, rv$region_sel)
        proxy <- proxy %>% addPolygons(
          lng = poly$longitude, lat = poly$latitude,
          fillColor = region_fills[[nm]], fillOpacity = if (sel) 0.45 else 0.18,
          color = if (sel) "#000" else region_border, weight = if (sel) 3 else 2, opacity = 0.9,
          layerId = paste0("poly_", nm), group = nm,
          options = pathOptions(pane = "regions"),
          highlightOptions = highlightOptions(weight = 3, color = "#000", fillOpacity = 0.5, bringToFront = FALSE)
        )
      }
    }
    # Region labels
    if (length(cents)){
      lab_lng <- sapply(cents, `[[`, "lon")
      lab_lat <- sapply(cents, `[[`, "lat")
      lab_txt <- names(cents)
      proxy <- proxy %>% addLabelOnlyMarkers(
        lng = lab_lng, lat = lab_lat, label = lab_txt, group = "region_labels",
        labelOptions = labelOptions(noHide = TRUE, direction = "center",
                                    textsize = "14px", textOnly = TRUE,
                                    style = list("font-weight"="900","color"="#083344","pointer-events"="none",
                                                 "text-shadow"="0 1px 0 #fff, 0 -1px 0 #fff, 1px 0 0 #fff, -1px 0 0 #fff")),
        options = pathOptions(pane = "region-labels")
      )
    }
    
    # Site markers
    if (nrow(mdf)>0){
      if (!is.null(rv$site_sel) && rv$site_sel != "All sites" && any(mdf$site_name_short==rv$site_sel)) {
        sel <- mdf %>% dplyr::filter(site_name_short == rv$site_sel) %>% dplyr::slice(1)
        proxy %>% addCircleMarkers(
          lng=sel$longitude, lat=sel$latitude, radius=15,
          color="#222", weight=2, fillOpacity=0.96, fillColor=sel$color,
          label=sel$label_txt, popup=sel$popup_txt, layerId=sel$site_name_short, group=sel$region,
          options = pathOptions(pane = "site-markers")
        ) %>% setView(lng=sel$longitude, lat=sel$latitude, zoom=11)
      } else {
        proxy %>% addCircleMarkers(
          lng=mdf$longitude, lat=mdf$latitude, radius=12,
          color="#222", weight=2, fillOpacity=0.95, fillColor=mdf$color,
          label=mdf$label_txt, popup=mdf$popup_txt, layerId=mdf$site_name_short, group=mdf$region,
          options = pathOptions(pane = "site-markers")
        ) %>% fitBounds(
          lng1=min(mdf$longitude, na.rm=TRUE), lat1=min(mdf$latitude, na.rm=TRUE),
          lng2=max(mdf$longitude, na.rm=TRUE), lat2=max(mdf$latitude, na.rm=TRUE)
        )
      }
    } else {
      proxy %>% setView(lng = 145.0, lat = -38.1, zoom = 8)
    }
  }, ignoreInit = FALSE)
  
  # Title above the story panel
  output$panel_title <- renderUI({
    date_str <- format(as.Date(rv$date_sel), "%d %B %Y")
    if (is.null(rv$site_sel) || rv$site_sel=="All sites"){
      if (is.null(rv$region_sel) || rv$region_sel=="All regions")
        HTML(paste0("<b>All regions</b> : ", date_str))
      else
        HTML(paste0("<b>", rv$region_sel, "</b> : ", date_str))
    } else {
      sub <- all_df %>% dplyr::filter(site_name_short==rv$site_sel, date <= as.Date(rv$date_sel))
      validate(need(nrow(sub)>0,"No data"))
      sub <- sub[order(sub$date, decreasing=TRUE),]
      idx <- which(!is.na(sub$Temperature)); if (length(idx)) sub <- sub[idx[1], , drop=FALSE] else sub <- sub[1, , drop=FALSE]
      HTML(paste0("<b>", sub$site_name_short, "</b> (", sub$region, ") : ", date_str,
                  " • <span class='muted'>tested ", format(sub$date, "%d %b %Y"), "</span>"))
    }
  })
  
  # Build the story text for a selected site
  pct_rank <- function(x, vec, high_good=TRUE){
    if (is.na(x)) return(NA_real_)
    vec <- vec[!is.na(vec)]
    if (!length(vec)) return(NA_real_)
    p <- mean(if (high_good) vec <= x else vec >= x)
    round(p*100)
  }
  
  make_story <- function(row, prev, bay_df){
    codes <- list(a = code_algae(row$CHL_A), c = code_clarity(row$Turb), o = code_oxygen(row$DO_mg),
                  n = code_nutr(row$N_TOTAL), t = code_temp(row$Temperature))
    oc <- overall_code(codes$a,codes$c,codes$o,codes$n,codes$t)
    
    opener <- switch(oc,
                     "green" = "The bay feels friendly and calm - a good place for splashes and shell hunts",
                     "amber" = "The bay is lively - step carefully and look for the clearest spots to play",
                     "red"   = "The bay is resting now - best for sandcastles and wave watching"
    )
    
    pct_rank_safe <- function(val, vec, high_good){
      if (is.na(val)) return(NA_real_)
      vec <- vec[!is.na(vec)]
      if (!length(vec)) return(NA_real_)
      p <- mean(if (high_good) vec <= val else vec >= val)
      round(p*100)
    }
    p_clear <- pct_rank_safe(row$Turb, bay_df$Turb, high_good=FALSE)  # lower turbidity is better
    p_oxy   <- pct_rank_safe(row$DO_mg, bay_df$DO_mg, high_good=TRUE)
    p_chl   <- pct_rank_safe(row$CHL_A, bay_df$CHL_A, high_good=FALSE)
    p_temp  <- pct_rank_safe(row$Temperature, bay_df$Temperature, high_good=TRUE)
    clarity_score <- ifelse(is.na(p_clear), NA_real_, 100 - p_clear)
    oxygen_score  <- p_oxy
    algae_score   <- ifelse(is.na(p_chl), NA_real_, 100 - p_chl)
    
    clarity_line <- if (!is.na(clarity_score)) {
      if (clarity_score >= 85) "One of the clearest"
      else if (clarity_score >= 70) "Clearer than most nearby"
      else if (clarity_score >= 45) "About average clarity"
      else if (clarity_score >= 25) "A bit cloudier than most"
      else "One of the cloudiest"
    } else NULL
    oxygen_line <- if (!is.na(oxygen_score)) {
      if (oxygen_score >= 85) "Bubbles near the top"
      else if (oxygen_score >= 70) "More bubbles than most"
      else if (oxygen_score >= 45) "About average bubbles"
      else if (oxygen_score >= 25) "Fewer bubbles than most"
      else "Very low bubbles"
    } else NULL
    temp_line <- if (!is.na(p_temp)) {
      if (p_temp >= 85) "One of the warmer spots"
      else if (p_temp >= 70) "Warmer than most"
      else if (p_temp >= 40 && p_temp <= 60) "About mid temperature"
      else if (p_temp >= 25) "On the cooler side"
      else "One of the cooler spots"
    } else NULL
    algae_line <- if (!is.na(algae_score)) {
      if (algae_score >= 85) "Less algae than almost anywhere"
      else if (algae_score >= 70) "Less algae than most"
      else if (algae_score >= 45) "About average algae"
      else if (algae_score >= 25) "More algae than most"
      else "Algae is high"
    } else NULL
    
    trend <- c()
    if (!is.null(prev)){
      add <- function(label, now, old, good_low=NA){
        if (is.na(now) || is.na(old)) return(NULL)
        d <- now - old
        arrow <- if (abs(d)<1e-9) "↔"
        else if (isTRUE(good_low)) if (d>0) "⬆" else "⬇"
        else if (identical(good_low,FALSE)) if (d>0) "⬆" else "⬇"
        else if (d>0) "⬆" else "⬇"
        paste(label, arrow)
      }
      trend <- Filter(Negate(is.null), list(
        add("clarity",  row$Turb,        prev$Turb,        TRUE),
        add("oxygen",   row$DO_mg,       prev$DO_mg,       FALSE),
        add("algae",    row$CHL_A,       prev$CHL_A,       TRUE),
        add("temp",     row$Temperature, prev$Temperature, NA)
      ))
    }
    
    act_pool <- TRY_THIS_BASE
    if (!is.na(row$Turb)){
      if (row$Turb <= 2) act_pool <- c(act_pool, TRY_THIS_CLEAR) else if (row$Turb > 5) act_pool <- c(act_pool, TRY_THIS_CLOUDY)
    }
    if (!is.na(row$Temperature)){
      if (row$Temperature >= 24) act_pool <- c(act_pool, TRY_THIS_WARM) else if (row$Temperature < 20) act_pool <- c(act_pool, TRY_THIS_COOL)
    }
    act_pick <- pick_rotating(act_pool, key = paste0(row$site_name_short, "_", row$date, "_try"), period_seconds = 15)
    
    metric_line <- function(icon, label, value, unit, detail_text){
      if (is.na(value)) return(NULL)
      paste0("<p>", icon, " <span class='metric'>", label, "</span> ",
             fmt_num(value), if (nzchar(unit)) paste0(" ", unit) else "", " - ", detail_text, ".</p>")
    }
    
    parts <- c(
      # removed "Play by the Bay" header from the story card on purpose (requested)
      "<p>", opener, "</p>"
    )
    parts <- c(parts,
               metric_line("👀","Clarity",      row$Turb,        "NTU",
                           switch(codes$c, green="looks like clean glass", amber="a little cloudy like frosted glass", red="very cloudy like stirred sand")),
               metric_line("🫧","Oxygen",       row$DO_mg,       "mg/L",
                           switch(codes$o, green="bubbles everywhere - fish feel strong", amber="fewer bubbles right now", red="low bubbles - fish get tired")),
               metric_line("🌱","Algae",        row$CHL_A,       "µg/L", kidline("Algal Bloom", codes$a)),
               metric_line("🌡️","Temperature", row$Temperature, "°C",   kidline("Temperature", codes$t))
    )
    
    vs_lines <- Filter(Negate(is.null), c(clarity_line, oxygen_line, algae_line, temp_line))
    if (length(vs_lines)) parts <- c(parts, "<p><b>Vs nearby</b><br/>", paste(vs_lines, collapse = " • "), "</p>")
    if (length(trend))   parts <- c(parts, "<p><b>Since last test</b><br/>", paste(trend,   collapse = " • "), "</p>")
    if (!is.null(act_pick)) parts <- c(parts, "<p><b>Play by the Bay idea</b><br/>", act_pick, ".</p>")
    if (oc=="green") parts <- c(parts, "<p><b>Safe spot</b> 🎉 confetti shows when you tap OK</p>")
    
    HTML(do.call(paste0, as.list(Filter(Negate(is.null), parts))))
  }
  
  # Story panel rendering
  output$story_block <- renderUI({
    if (is.null(rv$site_sel) || rv$site_sel == "All sites") {
      mdf <- map_data()
      counts <- table(factor(mdf$overall, levels = c("green","amber","red"))); counts[is.na(counts)] <- 0
      reg_counts <- sort(table(mdf$region))
      # pick top sparkly spots: safest then newest
      top <- if (nrow(mdf)>0) {
        mdf %>% dplyr::arrange(match(overall, c("green","amber","red")), dplyr::desc(sample_date)) %>% head(3)
      } else mdf[0,]
      top_names <- if (nrow(top)>0) paste(top$site_name_short, collapse=" • ") else "-"
      
      mean_turb <- suppressWarnings(mean(mdf$Turb, na.rm=TRUE));  mean_turb <- if (is.nan(mean_turb)) NA_real_ else mean_turb
      mean_do   <- suppressWarnings(mean(mdf$DO_mg, na.rm=TRUE)); mean_do   <- if (is.nan(mean_do))   NA_real_ else mean_do
      mean_temp <- suppressWarnings(mean(mdf$Temperature, na.rm=TRUE)); mean_temp <- if (is.nan(mean_temp)) NA_real_ else mean_temp
      
      HTML(paste0(
        "<p><b>Here is today’s simple story for all beaches.</b> Think of it as a quick weather report for the water.</p>",
        "<p><b>How many are friendly?</b><br/>",
        as.integer(counts[['green']]), " safe • ",
        as.integer(counts[['amber']]), " caution • ",
        as.integer(counts[['red']]), " rest.</p>",
        if (length(reg_counts)) paste0(
          "<p><b>By region</b><br/>",
          paste(paste0(names(reg_counts), ": ", as.integer(reg_counts)), collapse = " • "),
          "</p>"
        ) else "",
        "<p><b>Top sparkly spots</b><br/>", top_names, "</p>",
        "<p><b>What the water feels like</b></p>",
        "<p>👀 <b>Clarity</b> ~ ", ifelse(is.na(mean_turb), "-", fmt_num(mean_turb)), " NTU - lower numbers look more like clean glass.</p>",
        "<p>🫧 <b>Oxygen</b> ~ ", ifelse(is.na(mean_do), "-", fmt_num(mean_do)), " mg/L - more bubbles keep sea life lively.</p>",
        "<p>🌡️ <b>Temperature</b> ~ ", ifelse(is.na(mean_temp), "-", fmt_num(mean_temp)), " °C - cool feels comfy for quick splashes.</p>",
        "<p><b>Try this today</b><br/>Pick a beach from the list, choose a day, and press OK to see that beach’s own story with a playful idea.</p>"
      ))
    } else {
      sub <- all_df %>% dplyr::filter(site_name_short==rv$site_sel, date <= as.Date(rv$date_sel))
      validate(need(nrow(sub)>0, "No data"))
      row <- sub[order(sub$date, decreasing=TRUE), ]
      idx <- which(!is.na(row$Temperature)); if (length(idx)) row <- row[idx[1], , drop=FALSE] else row <- row[1, , drop=FALSE]
      make_story(row, prev_row(row$site_name_short[1], row$date[1]), map_data())
    }
  })
  
  # Insights cards
  output$top_picks <- renderUI({
    mdf <- map_data()
    regline <- if (!is.null(rv$region_sel) && rv$region_sel != "All regions") paste0("In ", rv$region_sel, ": ") else "All regions: "
    top_txt <- if (nrow(mdf) > 0){
      best <- mdf %>% dplyr::arrange(match(overall, c("green","amber","red")), dplyr::desc(sample_date)) %>% head(3)
      if (nrow(best)>0) paste(best$site_name_short, collapse=" • ") else "-"
    } else "-"
    HTML(paste0(regline, top_txt))
  })
  
  output$bits_fact <- renderUI({
    tick15()
    fact <- pick_rotating(FUN_FACTS, key=paste0(rv$region_sel, "_", rv$date_sel, "_fact"), period_seconds = 15)
    HTML(paste0(fact, "."))
  })
  
  output$bits_try <- renderUI({
    tick15()
    mdf <- map_data()
    trys <- TRY_THIS_BASE
    if (nrow(mdf)>0){
      mean_turb <- suppressWarnings(mean(mdf$Turb, na.rm = TRUE))
      mean_temp <- suppressWarnings(mean(mdf$Temperature, na.rm = TRUE))
      if (!is.nan(mean_turb)){ if (mean_turb <= 2) trys <- c(trys, TRY_THIS_CLEAR) else if (mean_turb > 5) trys <- c(trys, TRY_THIS_CLOUDY) }
      if (!is.nan(mean_temp)){ if (mean_temp >= 24) trys <- c(trys, TRY_THIS_WARM) else if (mean_temp < 20) trys <- c(trys, TRY_THIS_COOL) }
    }
    try_pick <- pick_rotating(trys, key=paste0(rv$region_sel, "_", rv$date_sel, "_try"), period_seconds = 15)
    HTML(paste0(try_pick, "."))
  })
  
  output$bits_friend <- renderUI({
    tick15()
    friend <- pick_rotating(OCEAN_FRIENDS, key=paste0(rv$region_sel, "_", rv$date_sel, "_friend"), period_seconds = 15)
    HTML(friend)
  })
}

shinyApp(ui, server)
