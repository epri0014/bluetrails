# ====================== app.R (Two Regions + Region Zoom + Bottom Quick Help + Clickable Pins) ======================
# ---------- paths ----------
suppressWarnings({
  app_dir <- tryCatch({
    if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
      dirname(rstudioapi::getActiveDocumentContext()$path) else getwd()
  }, error = function(e) getwd())
})
file_ppb <- file.path(app_dir, "1984_07-2024_06_Port_Phillip_Bay_Water_quality_data.xlsx")
file_wp  <- file.path(app_dir, "1990_02-2024_06_Western_Port_Water_quality_data.xlsx")
for (p in c(file_ppb, file_wp)) if (!file.exists(p)) stop("File not found: ", p)

# ---------- packages ----------
library(shiny)
pkgs <- c("bslib","leaflet","dplyr","readxl","lubridate","stringr","purrr","tibble","htmltools","digest")
need <- setdiff(pkgs, rownames(installed.packages()))
if (length(need)) install.packages(need, repos = "https://cloud.r-project.org")
invisible(lapply(pkgs, library, character.only=TRUE))

# ---------- helpers ----------
numify <- function(x){ suppressWarnings(as.numeric(gsub("[^0-9.\\-]", "", as.character(x)))) }
parse_date_any <- function(x){
  if (inherits(x, "Date")) return(as.Date(x))
  if (is.numeric(x)) return(as.Date(x, origin = "1899-12-30"))
  suppressWarnings(lubridate::as_date(x))
}
clip_invalid <- function(x, lo, hi){ ifelse(x < lo | x > hi, NA_real_, x) }
fmt <- function(x, unit=""){ ifelse(is.na(x), "–", paste0(signif(as.numeric(x), ifelse(abs(as.numeric(x))>=10,3,2)), " ", unit)) }

# ---------- rotating picks ----------
pick_rotating <- function(items, key = "", period_seconds = 10){
  if (length(items) == 0) return(NA_character_)
  slot <- floor(as.numeric(Sys.time()) / period_seconds)
  h <- digest::digest(paste0(key, "_", slot), algo = "xxhash64")
  seed <- suppressWarnings(as.integer(strtoi(substr(h, 1, 8), base=16L)))
  if (is.na(seed)) seed <- sample.int(.Machine$integer.max, 1)
  set.seed(seed)
  sample(items, 1)
}

# ---------- content pools ----------
FUN_FACTS <- c(
  "Seahorses are fish that swim upright","Dolphins sleep with one eye open",
  "Sea stars can regrow arms","Octopuses have three hearts",
  "Some fish glow in the dark under the sea","Penguins can drink salty seawater",
  "Sea turtles can live for more than 50 years","A group of fish is called a school",
  "Crabs wear hard shells called exoskeletons","Some jellyfish are see-through like glass",
  "Clownfish hide in soft sea anemones","A baby fish is called a fry",
  "Seagrass meadows are nurseries for tiny sea animals","Mangroves help keep the water clean",
  "Sea sponges are animals, not plants","Starfish sense with their arms instead of a brain like ours",
  "The fastest fish can beat a city car in traffic","Tiny sea snails can drill neat holes in shells",
  "Seaweed is plant-like algae that many animals eat","Shrimp can be smaller than your little fingernail"
)
TRY_THIS_BASE <- c(
  "Shell hunt. Find one spiral, one smooth, one bumpy",
  "Beach bingo. Spot a crab, a feather, and a striped shell",
  "Sand artist. Draw a fish as long as your arm",
  "Wave watcher. Count ten big waves in a row",
  "Rock pool explorer. Spot tiny crabs and snails",
  "Treasure map. Draw a simple map of your beach",
  "Footprints game. Can you follow your own trail back?",
  "Driftwood drum. Tap gentle beats and dance",
  "Sound safari. Close eyes and list three ocean sounds",
  "Beach letters. Write your name with shells"
)
TRY_THIS_CLEAR <- c("Starfish spy. Look for shapes on the seabed","Pebble window. Peek through calm water to the sand","Shadow hunt. Can you see fish shadows zip past?")
TRY_THIS_CLOUDY <- c("Foam detective. Watch bubbles pop and name the shapes","Color quest. Find three things that are blue, brown, green","Beach maze. Draw a maze in the sand and solve it")
TRY_THIS_WARM <- c("Toe test. Count to ten with toes in the water","Sand bakery. Make a warm sand cupcake with a shell on top")
TRY_THIS_COOL <- c("Skip and splash. Ten quick jumps then warm towel time","Stone stacker. Build a tiny cool-stone tower")

# ---------- flexible sheet helpers ----------
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
       " — looked for one of: ", paste(candidates, collapse=", "))
}

# ---------- read & clean (exclude datasets with no coords) ----------
read_clean <- function(path, region_name){
  data_sheet <- find_sheet(path, c("Data","Measurements","Sheet1","Sheet 1"))
  meta_sheet_try <- try(find_sheet(path, c("Site Metadata","Sites","Site_Meta","Metadata","Site Info",
                                           "SiteInformation","Locations","Stations")), silent = TRUE)
  
  raw_data <- readxl::read_excel(path, sheet = data_sheet)
  nm <- names(raw_data)
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
  
  # try to get coordinates
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
  
  # join & HARD FILTER: if no coords at all -> return empty (exclude dataset)
  if (!is.null(meta)){
    df <- left_join(data, meta, by = c("site_id","site_name_short")) %>%
      filter(!is.na(latitude), !is.na(longitude)) %>%
      arrange(site_name_short, date)
  } else {
    df <- tibble() # no coords available at all
  }
  
  if (!nrow(df)) return(tibble(
    site_id=character(), site_name_short=character(), date=as.Date(character()),
    CHL_A=double(), Turb=double(), DO_mg=double(), Temperature=double(), N_TOTAL=double(),
    latitude=double(), longitude=double(), region=character()
  ))
  
  df %>% mutate(region = region_name)
}

# read the two datasets; any that lack coords will be empty and dropped
ppb <- read_clean(file_ppb, "Port Phillip Bay")
wp  <- read_clean(file_wp,  "Western Port")

# union & globals (only datasets with coords survive)
all_df <- dplyr::bind_rows(ppb, wp)
if (nrow(all_df) == 0) stop("No rows after cleaning; datasets lacked coordinates.")

all_regions <- c("All regions", sort(unique(all_df$region)))
all_sites   <- sort(unique(all_df$site_name_short))
min_d <- min(all_df$date, na.rm=TRUE)
max_d <- max(all_df$date, na.rm=TRUE)

# ---------- R-A-G logic ----------
code_to_color <- c(green="#24c38b", amber="#ffb000", red="#e74a5f")
code_to_label <- c(green="Safe", amber="Caution", red="Rest")
region_fills  <- c("Port Phillip Bay"="#d4f6ff", "Western Port"="#e5ffd9")
region_border <- "#222"

code_algae   <- function(x) ifelse(is.na(x),"amber", ifelse(x <  2,"green", ifelse(x <=  5,"amber","red")))
code_clarity <- function(x) ifelse(is.na(x),"amber", ifelse(x <= 2,"green", ifelse(x <=  5,"amber","red")))
code_oxygen  <- function(x) ifelse(is.na(x),"amber", ifelse(x >= 6,"green", ifelse(x >=  4,"amber","red")))
code_nutr    <- function(x) ifelse(is.na(x),"amber", ifelse(x < 250,"green", ifelse(x <= 600,"amber","red")))
code_temp    <- function(x) ifelse(is.na(x),"amber", ifelse(x < 24,"green", ifelse(x <= 27,"amber","red")))
overall_code <- function(a,c,o,n,t){
  red_any <- (a=="red") | (c=="red") | (o=="red") | (n=="red") | (t=="red")
  amb_any <- (a=="amber") | (c=="amber") | (o=="amber") | (n=="amber") | (t=="amber")
  ifelse(red_any, "red", ifelse(amb_any, "amber", "green"))
}

# ---------- kid lines ----------
kidline <- function(metric, code) switch(metric,
                                         "Algal Bloom"=switch(code, green="Tiny plants. A few is fine - too many can make fish tired.",
                                                              amber="Some algae around - Keep watch.",
                                                              red="Lots of algae - Fish and crabs may struggle."),
                                         "Clarity"    =switch(code, green="Clear like a window - easy shell spotting!",
                                                              amber="A bit cloudy like frosted glass.",
                                                              red="Cloudy like stirred sand - look first."),
                                         "Oxygen"     =switch(code, green="Plenty of bubbles - sea life feels strong.",
                                                              amber="Fewer bubbles today.",
                                                              red="Low bubbles - let the water rest."),
                                         "Nutrients"  =switch(code, green="Just enough food in the water.",
                                                              amber="Extra food - algae could grow fast.",
                                                              red="Too much food - algae can take over."),
                                         "Temperature"=switch(code, green="Cool and comfy.",
                                                              amber="Getting warm - take short dips.",
                                                              red="Very warm - animals get sleepy."),
                                         "")

# ---------- theme ----------
theme <- bslib::bs_theme(
  version = 5,
  bootswatch = "minty",
  primary   = "#1a7bd6",
  bg        = "#f3f8ff",
  fg        = "#202022",
  base_font    = bslib::font_google("Nunito"),
  heading_font = bslib::font_google("Baloo 2")
)

# ---------- UI ----------
ui <- bslib::page_navbar(
  title = "Kids’ Water Guide - Port Phillip Bay & Western Port",
  theme = theme,
  
  header = tagList(
    # JS helpers
    tags$script(HTML("
      function makeConfettiBurst(durationMs=1600, count=120){
        const colors = ['#24c38b','#ffb000','#1a7bd6','#ff6ec7','#ffd166','#06d6a0','#118ab2'];
        const box = document.createElement('div');
        Object.assign(box.style,{position:'fixed',inset:'0',pointerEvents:'none',zIndex:9999});
        document.body.appendChild(box);
        for(let i=0;i<count;i++){
          const p=document.createElement('span');
          const s=6+Math.random()*6;
          Object.assign(p.style,{position:'absolute',top:'-10px',left:(Math.random()*100)+'%',width:s+'px',height:s+'px',
            background:colors[i%colors.length],borderRadius:'2px',opacity:'0.9',
            animation:'confetti-fall '+(1.2+Math.random()*1.2)+'s linear '+(Math.random()*0.4)+'s 1',
            transform:'rotate('+(Math.random()*360)+'deg)'});
          box.appendChild(p);
        }
        setTimeout(()=>{ box.remove(); }, durationMs);
      }
      Shiny.addCustomMessageHandler('scrollTo', function(id){
        var el = document.getElementById(id);
        if(!el) return;
        el.scrollIntoView({behavior:'smooth', block:'center'});
        el.classList.add('flash');
        setTimeout(function(){ el.classList.remove('flash'); }, 1200);
      });
      Shiny.addCustomMessageHandler('setHint', function(html){
        var el = document.getElementById('hintLine'); if(el){ el.innerHTML = html; }
      });
      Shiny.addCustomMessageHandler('celebrate', function(msg){
        makeConfettiBurst();
        const t = document.createElement('div');
        t.className='confetti-toast';
        t.innerHTML='<div class=\"t-title\">'+(msg.title||'Safe spot!')+'</div><div class=\"t-sub\">'+(msg.subtitle||'The water sparkles for you. Splash and play.')+'</div>';
        document.body.appendChild(t);
        setTimeout(()=>{ t.classList.add('show'); }, 50);
        setTimeout(()=>{ t.classList.remove('show'); t.remove(); }, 2200);
      });
    ")),
    # CSS + backdrop bubbles
    tags$head(
      tags$style(HTML("
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

        .map-legend{ background:#ffffffee; border:2px solid #000; border-radius:12px; padding:8px 10px; font-weight:800; }
        .mini-dot{ width:12px;height:12px;border-radius:50%;display:inline-block;border:2px solid #000;margin-right:6px }

        .story p{ margin:0 0 8px 0; }
        .story b{ font-weight:900; }
        .story .metric{ font-weight:800; }
        .muted{ opacity:.7; font-size:.95rem; }

        .insights-kids{
          background:
            linear-gradient(135deg, rgba(255,255,255,.95), rgba(255,255,255,.95)),
            radial-gradient(40px 40px at 20% 25%, #c6ffe9 30%, transparent 31%) 0 0 / 80px 80px,
            radial-gradient(40px 40px at 70% 60%, #ffeab6 30%, transparent 31%) 0 0 / 88px 88px,
            radial-gradient(40px 40px at 30% 80%, #e6edff 30%, transparent 31%) 0 0 / 76px 76px;
          border:2px solid #0c8b6f; border-radius:22px; box-shadow:6px 6px 0 #00000018;
          padding:14px; color:#103b3c;
        }
        .insights-kids, .insights-kids *{ color:#103b3c !important; }
        .insights-title{ font-weight:900; font-size:1.15rem; margin:0 0 6px 0; color:#0a6b56 !important; }
        .insights-list{ list-style:none; padding-left:0; margin:6px 0 0; }
        .insights-list li{ margin:8px 0; font-weight:800; line-height:1.25; }
        .badge{ display:inline-block; padding:3px 10px; border-radius:999px; border:2px solid #000; background:#fff; margin-right:8px; font-weight:900; box-shadow:3px 3px 0 #00000015; color:#103b3c !important; }
        .badge.good{ background:#b9ffdf; }
        .badge.fact{ background:#cfe1ff; }
        .badge.tip{  background:#fff2bf; }

        details.quickhelp{ border:2px solid #000; border-radius:22px; padding:10px 14px; background:#ffffffee;
                           box-shadow:6px 6px 0 #00000018; }
        details.quickhelp > summary{ list-style:none; cursor:pointer; font-weight:900; font-size:1.05rem; }
        details.quickhelp > summary::-webkit-details-marker{ display:none; }
        details.quickhelp > summary:before{ content:'▸'; margin-right:8px; font-weight:900; }
        details.quickhelp[open] > summary:before{ content:'▾'; }
        .qh-line{ margin:6px 0; font-weight:700; }
        .qh-muted{ color:#2b2b2b; opacity:.7; font-weight:700; }

        .flash{ animation: flash 1.2s ease-in-out 1; }
        @keyframes flash{ 0%{box-shadow:0 0 0 0 rgba(26,123,214,.0)} 50%{box-shadow:0 0 0 10px rgba(26,123,214,.25)} 100%{box-shadow:0 0 0 0 rgba(26,123,214,0)} }
        @keyframes confetti-fall{ 0%{ transform:translateY(-10px) rotate(0deg);} 100%{ transform:translateY(-120vh) rotate(360deg);} }
        .confetti-toast{
          position:fixed; left:50%; top:16px; transform:translateX(-50%) scale(.95);
          background:#ffffff; border:2px solid #000; border-radius:16px; padding:10px 16px;
          box-shadow:6px 6px 0 #00000018; opacity:0; transition:.2s ease; z-index:10000; text-align:center;
        }
        .confetti-toast.show{ opacity:1; transform:translateX(-50%) scale(1); }

        .ocean-bubbles{ position:fixed; inset:0; pointer-events:none; z-index:0; }
        .ocean-bubbles span{
          position:absolute; border-radius:50%; opacity:.9;
          background:radial-gradient(circle at 30% 30%, #fff, rgba(255,255,255,.25));
          animation: rise 10s linear infinite;
          filter: drop-shadow(0 0 8px rgba(255,255,255,.7));
        }
        @keyframes rise{ from{ transform:translateY(30px) scale(.9) } to{ transform:translateY(-120vh) scale(1.1) } }

        .egg,.eggs,.egg-stack,.traffic-eggs,.traffic-ovals,.status-egg,.status-oval,[class*='egg' i],[class*='oval' i]{display:none !important;}
      "))
    ),
    tags$div(class="ocean-bubbles",
             lapply(1:48, function(i){
               left <- sample(2:98,1); delay <- runif(1,0,10); size <- sample(12:26,1)
               tags$span(style=sprintf("left:%d%%; bottom:-20px; width:%dpx; height:%dpx; animation-delay:%.2fs;", left,size,size,delay))
             })
    )
  ),
  
  # -------- MAIN TAB ----------
  bslib::nav_panel(
    "Explore",
    div(class="container-lg pt-2",
        # Intro
        div(class="card-cute mb-2",
            tags$div(style="font-weight:900; font-size:1.35rem;", "Ocean Heroes - Find today’s best splash spots!"),
            HTML("
              <p>Welcome, explorers! This page helps you pick a safe, comfy place to play by the bay.</p>
              <p>Tap a <b>region</b> or a <b>pin</b> to see the beach story for <b>today</b>
              with clarity, bubbles, algae, and temperature.</p>
            ")
        ),
        # Main two-column layout
        div(class="top-grid",
            # LEFT: Map + Insights
            div(
              bslib::card(class="card-cute", card_header = "Tap a region or a beach to learn its story",
                          leafletOutput("map", height = "68vh")
              ),
              bslib::card(class="insights-kids", id="insightsCard",
                          div(class="insights-title", "Quick Wins and Fun Bits"),
                          uiOutput("insights")
              )
            ),
            # RIGHT: Pickers + Story
            div(class="rightcol",
                bslib::card(class="card-cute", id="pickCard",
                            div(class="big-step","Pick a region"),
                            selectInput("region", NULL, choices=all_regions, selected="All regions", width="100%"),
                            div(class="big-step mt-2","Pick a beach"),
                            selectInput("site", NULL, choices=c("All sites", all_sites), selected="All sites", width="100%"),
                            div(class="big-step mt-2","Pick a day"),
                            dateInput("date", NULL, value=max_d, min=min_d, max=max_d, width="100%"),
                            div(class="mt-3 d-flex gap-2",
                                actionButton("apply", "OK", class="btn btn-primary"),
                                actionButton("reset", "Reset", class="btn btn-outline-secondary")
                            ),
                            div(class="mt-2 small text-muted", id="hintLine",
                                "Step 1: Pick a region. Step 2: Pick a beach. Step 3: Pick a day. Step 4: Tap OK.")
                ),
                bslib::card(class="card-cute", card_header=uiOutput("panel_title"), id="storyCard",
                            div(class="story", uiOutput("story_block"))
                )
            )
        ),
        # ---- BOTTOM: Quick Help (collapsible) ----
        div(class="mt-3", id="quickHelpBottom",
            tags$details(class="quickhelp", open=NA,
                         tags$summary(HTML("🌎 Quick Help for Kids")),
                         div(class="qh-line", HTML("🌿 <b>Algae</b> - Tiny plants. A little is okay - <i>too much</i> makes fish tired.")),
                         div(class="qh-line", HTML("👀 <b>Clarity</b> - Clear like a window is best. Cloudy like lemonade? Look first.")),
                         div(class="qh-line", HTML("🫧 <b>Oxygen</b> - More bubbles = happier sea life. Around <b>6 mg/L+</b> is strong.")),
                         div(class="qh-line", HTML("🍔 <b>Food for Water (Nutrients)</b> - After rain there can be <i>extra food</i> that grows algae fast.")),
                         div(class="qh-line", HTML("🌡️ <b>Temperature</b> - Cool is comfy. Very warm water makes animals sleepy, take short dips.")),
                         div(class="qh-line qh-muted", HTML("Tip: Click a <b>shaded region</b> to zoom. Pins are beaches. <span style='color:#24c38b;font-weight:900'>Green</span> = Splash • <span style='color:#ffb000;font-weight:900'>Amber</span> = Step carefully • <span style='color:#e74a5f;font-weight:900'>Red</span> = Rest."))
            )
        )
    )
  )
)

# ---------- server ----------
server <- function(input, output, session){
  rv <- reactiveValues(region_sel="All regions", site_sel="All sites", date_sel=max_d)
  tick10 <- reactiveTimer(10000)
  
  set_hint <- function(txt){ session$sendCustomMessage("setHint", txt) }
  scroll_flash <- function(id) session$sendCustomMessage("scrollTo", id)
  celebrate_safe <- function(){ session$sendCustomMessage("celebrate", list(title="Safe spot!", subtitle="The water sparkles for you. Splash and play.")) }
  
  # region -> site choices
  observeEvent(input$region, {
    sites <- if (is.null(input$region) || input$region=="All regions") {
      all_sites
    } else {
      sort(unique(all_df$site_name_short[all_df$region==input$region]))
    }
    updateSelectInput(session, "site", choices=c("All sites", sites), selected="All sites")
    if (input$region=="All regions") set_hint("Now pick a beach. You can also tap a pin on the map.")
    else set_hint("Great. Pick a beach in this region, then a day.")
  }, ignoreInit = TRUE)
  
  observeEvent(input$site, { if (input$site=="All sites") set_hint("Pick a day. Or tap a pin.") else set_hint("Nice. Pick a day, then tap OK.") }, ignoreInit = TRUE)
  observeEvent(input$date, { set_hint("Looks good. Tap OK to show the story.") }, ignoreInit = TRUE)
  
  # prefer row with Temperature, else latest
  pick_latest_with_temp <- function(tbl){
    tbl <- tbl[order(tbl$date, decreasing=TRUE),]
    idx <- which(!is.na(tbl$Temperature))
    if (length(idx)) tbl[idx[1], , drop=FALSE] else tbl[1, , drop=FALSE]
  }
  prev_row <- function(site, date_cut){
    prev <- all_df %>% filter(site_name_short==site, date < as.Date(date_cut)) %>% arrange(desc(date))
    if (nrow(prev)==0) return(NULL)
    pick_latest_with_temp(prev)
  }
  
  # map-ready data (only rows with coords)
  map_data <- reactive({
    sub <- all_df[all_df$date <= as.Date(rv$date_sel), ]
    if (!is.null(rv$region_sel) && rv$region_sel != "All regions") sub <- sub[sub$region==rv$region_sel,]
    if (nrow(sub)==0) return(all_df[0,])
    split_df <- split(sub, sub$site_name_short)
    mdf <- purrr::list_rbind(purrr::map(split_df, pick_latest_with_temp)) %>%
      filter(!is.na(longitude), !is.na(latitude)) %>%
      mutate(
        sample_date = date,
        a = code_algae(CHL_A), c = code_clarity(Turb), o = code_oxygen(DO_mg),
        n = code_nutr(N_TOTAL), t = code_temp(Temperature),
        overall = overall_code(a,c,o,n,t),
        color = unname(code_to_color[overall])
      )
    
    dot <- function(code){ sprintf("<span class='mini-dot' style='background:%s'></span>", unname(code_to_color[code])) }
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
    
    mdf$popup_txt <- paste0(
      "<b>", mdf$site_name_short, "</b> · <i>", mdf$region, "</i><br/>",
      status, " • <i>", when_line, "</i><br/>",
      dot(mdf$a)," Algae: ", fmt(mdf$CHL_A,"µg/L"), " • ", kid_a,
      "<br/>", dot(mdf$c)," Clarity: ", fmt(mdf$Turb,"NTU"), " • ", kid_c,
      "<br/>", dot(mdf$o)," Oxygen: ", fmt(mdf$DO_mg,"mg/L"), " • ", kid_o,
      "<br/>", dot(mdf$n)," Nutrients: ", fmt(mdf$N_TOTAL,"µg/L"), " • ", kid_n,
      "<br/>", dot(mdf$t)," Temp: ", fmt(mdf$Temperature,"°C"), " • ", kid_t
    )
    mdf$label_txt <- paste0("[", mdf$region, "] ", mdf$site_name_short, " : ", unname(code_to_label[mdf$overall]))
    mdf
  })
  
  # region polygons (convex hull) and region NAME labels (centroid)
  region_polys <- reactive({
    dat <- all_df[all_df$date <= as.Date(rv$date_sel),]
    res <- list()
    cents <- list()
    for (nm in unique(dat$region)){
      pts <- dat %>% filter(region==nm, !is.na(longitude), !is.na(latitude)) %>% distinct(longitude, latitude)
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
  
  # apply/reset
  observeEvent(input$apply, {
    rv$region_sel <- input$region
    rv$site_sel   <- input$site
    rv$date_sel   <- as.Date(input$date)
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
    updateDateInput(session, "date", value=max_d)
    rv$region_sel <- "All regions"; rv$site_sel <- "All sites"; rv$date_sel <- max_d
    set_hint("Start again. Pick a region, beach, day and then click OK."); scroll_flash("pickCard")
  })
  
  # map marker click -> prefill
  observeEvent(input$map_marker_click, {
    id <- input$map_marker_click$id
    reg <- input$map_marker_click$group
    if (!is.null(id) && id %in% all_sites) {
      updateSelectInput(session, "region", selected = ifelse(is.null(reg), "All regions", reg))
      sites <- if (is.null(reg) || reg=="All regions") all_sites else sort(unique(all_df$site_name_short[all_df$region==reg]))
      updateSelectInput(session, "site", choices=c("All sites", sites), selected=id)
      set_hint("Nice choice. Pick a day, then tap OK."); scroll_flash("pickCard")
    }
  })
  
  # NEW: region polygon click -> select region + zoom to its bounds
  observeEvent(input$map_shape_click, {
    sid <- input$map_shape_click$id
    if (!is.null(sid) && startsWith(sid, "poly_")){
      reg <- sub("^poly_", "", sid)
      if (reg %in% unique(all_df$region)){
        updateSelectInput(session, "region", selected = reg)
        rv$region_sel <- reg
        # zoom to polygon bounds
        rp <- region_polys()$polys[[reg]]
        if (!is.null(rp) && nrow(rp) > 0){
          leafletProxy("map") %>% fitBounds(
            lng1=min(rp$longitude, na.rm=TRUE), lat1=min(rp$latitude, na.rm=TRUE),
            lng2=max(rp$longitude, na.rm=TRUE), lat2=max(rp$latitude, na.rm=TRUE)
          )
        }
        set_hint(paste0("Great. You're in ", reg, ". Pick a beach, then a day, and tap OK."))
        scroll_flash("pickCard")
      }
    }
  }, ignoreInit = TRUE)
  
  # current & previous rows
  current_row <- reactive({
    if (is.null(rv$site_sel) || rv$site_sel=="All sites") return(NULL)
    sub <- all_df %>% filter(site_name_short==rv$site_sel, date <= as.Date(rv$date_sel))
    if (nrow(sub)==0) return(NULL)
    pick_latest_with_temp(sub)
  })
  current_prev <- reactive({
    r <- current_row(); if (is.null(r)) return(NULL); prev_row(r$site_name_short[1], r$date[1])
  })
  
  # -------- map (with panes) --------
  output$map <- renderLeaflet({
    leaflet(options = leafletOptions(minZoom=7, maxZoom=16)) %>%
      addMapPane("regions", zIndex = 410) %>%
      addMapPane("region-labels", zIndex = 420) %>%
      addMapPane("site-markers", zIndex = 630) %>%
      addProviderTiles(providers$Esri.OceanBasemap)
  })
  
  add_dynamic_legends <- function(proxy, regions_present){
    proxy %>% clearControls()
    # traffic legend
    proxy <- proxy %>% addControl(html = HTML(sprintf(
      "<div class='map-legend'>
         <div><span class='mini-dot' style='background:%s'></span> Safe</div>
         <div><span class='mini-dot' style='background:%s'></span> Caution</div>
         <div><span class='mini-dot' style='background:%s'></span> Rest</div>
       </div>", code_to_color["green"], code_to_color["amber"], code_to_color["red"]
    )), position = "topleft")
    # region legend (only those present)
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
    
    # polygons (selected region stands out) -> in "regions" pane
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
    # region name labels (centroid) -> in "region-labels" pane, pointer-events none
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
    
    # markers -> in "site-markers" pane
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
  
  # ---------- Panels ----------
  output$panel_title <- renderUI({
    date_str <- format(as.Date(rv$date_sel), "%d %B %Y")
    if (is.null(rv$site_sel) || rv$site_sel=="All sites"){
      if (is.null(rv$region_sel) || rv$region_sel=="All regions")
        HTML(paste0("<b>All regions</b> : ", date_str))
      else
        HTML(paste0("<b>", rv$region_sel, "</b> : ", date_str))
    } else {
      r <- current_row(); validate(need(!is.null(r)&&nrow(r)==1,"No data"))
      HTML(paste0("<b>", r$site_name_short, "</b> (", r$region, ") : ", date_str,
                  " • <span class='muted'>tested ", format(r$date, "%d %b %Y"), "</span>"))
    }
  })
  
  pct_rank <- function(x, vec, high_good=TRUE){
    if (is.na(x)) return(NA_real_)
    vec <- vec[!is.na(vec)]
    if (!length(vec)) return(NA_real_)
    p <- mean(if (high_good) vec <= x else vec >= x)
    round(p*100)
  }
  band_phrase <- function(score, top, good, avg, low, bottom){
    if (is.na(score)) return(NULL)
    if (score >= 85) return(top)
    if (score >= 70) return(good)
    if (score >= 45) return(avg)
    if (score >= 25) return(low)
    return(bottom)
  }
  
  make_story <- function(row, prev, bay_df){
    p_clear <- pct_rank(row$Turb, bay_df$Turb, high_good=FALSE)
    p_oxy   <- pct_rank(row$DO_mg, bay_df$DO_mg, high_good=TRUE)
    p_chl   <- pct_rank(row$CHL_A, bay_df$CHL_A, high_good=FALSE)
    p_temp  <- pct_rank(row$Temperature, bay_df$Temperature, high_good=TRUE)
    clarity_score <- ifelse(is.na(p_clear), NA_real_, 100 - p_clear)
    oxygen_score  <- p_oxy
    algae_score   <- ifelse(is.na(p_chl), NA_real_, 100 - p_chl)
    temp_line <- if (!is.na(p_temp)) {
      if (p_temp >= 85) "One of the warmer spots"
      else if (p_temp >= 70) "Warmer than most"
      else if (p_temp >= 40 && p_temp <= 60) "About mid temperature"
      else if (p_temp >= 25) "On the cooler side"
      else "One of the cooler spots"
    } else NULL
    
    clarity_line <- if (!is.na(clarity_score)) {
      if (clarity_score >= 85) "One of the clearest today"
      else if (clarity_score >= 70) "Clearer than most nearby"
      else if (clarity_score >= 45) "About average clarity"
      else if (clarity_score >= 25) "A bit cloudier than most"
      else "One of the cloudiest today"
    } else NULL
    oxygen_line <- if (!is.na(oxygen_score)) {
      if (oxygen_score >= 85) "Bubbles near the top"
      else if (oxygen_score >= 70) "More bubbles than most"
      else if (oxygen_score >= 45) "About average bubbles"
      else if (oxygen_score >= 25) "Fewer bubbles than most"
      else "Very low bubbles today"
    } else NULL
    algae_line <- if (!is.na(algae_score)) {
      if (algae_score >= 85) "Less algae than almost anywhere"
      else if (algae_score >= 70) "Less algae than most"
      else if (algae_score >= 45) "About average algae"
      else if (algae_score >= 25) "More algae than most"
      else "Algae is high today"
    } else NULL
    
    codes <- list(a = code_algae(row$CHL_A), c = code_clarity(row$Turb), o = code_oxygen(row$DO_mg),
                  n = code_nutr(row$N_TOTAL), t = code_temp(row$Temperature))
    oc <- overall_code(codes$a,codes$c,codes$o,codes$n,codes$t)
    opener <- if (oc=="green") "Splash day. Water looks friendly." else if (oc=="amber") "Step carefully. Pick the clearest patch." else "Better for sandcastles. Let the waves rest."
    
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
    act_pick <- pick_rotating(act_pool, key = paste0(row$site_name_short, "_", row$date, "_try"), period_seconds = 10)
    
    vs_lines <- Filter(Negate(is.null), c(clarity_line, oxygen_line, algae_line, temp_line))
    parts <- c(
      "<p><b>", opener, "</b></p>",
      "<p>📍 <b>", row$region, "</b></p>",
      "<p>👀 <span class='metric'>Clarity</span> ", fmt(row$Turb,"NTU"), " • ",
      switch(codes$c, green="Looks like clean glass", amber="A little cloudy like frosted glass", red="Very cloudy like stirred sand"), ".</p>",
      "<p>🫧 <span class='metric'>Oxygen</span> ", fmt(row$DO_mg,"mg/L"), " • ",
      switch(codes$o, green="Bubbles everywhere. Fish feel strong", amber="Fewer bubbles today", red="Low bubbles. Fish get tired"), ".</p>",
      "<p>🌱 <span class='metric'>Algae</span> ", fmt(row$CHL_A,"µg/L"), " • ", kidline("Algal Bloom", codes$a), ".</p>",
      "<p>🌡️ <span class='metric'>Temperature</span> ", fmt(row$Temperature,"°C"), " • ", kidline("Temperature", codes$t), ".</p>"
    )
    if (length(vs_lines)) parts <- c(parts, "<p><b>Vs nearby today</b><br/>", paste(vs_lines, collapse = " • "), "</p>")
    if (length(trend))   parts <- c(parts, "<p><b>Since last test</b><br/>", paste(trend,   collapse = " • "), "</p>")
    parts <- c(parts, "<p><b>Try this</b><br/>", act_pick, ".</p>")
    if (oc=="green") parts <- c(parts, "<p><b>Safe spot</b> \U0001F389 Confetti shows when you tap OK. Time to splash and play.</p>")
    HTML(do.call(paste0, as.list(parts)))
  }
  
  output$story_block <- renderUI({
    tick10()
    if (is.null(rv$site_sel) || rv$site_sel == "All sites") {
      mdf <- map_data()
      counts <- table(factor(mdf$overall, levels = c("green","amber","red"))); counts[is.na(counts)] <- 0
      reg_counts <- table(mdf$region)
      HTML(paste0(
        "<p>We checked <b>", nrow(mdf), "</b> beaches. ",
        "<span style='color:", code_to_color['green'], "'>", as.integer(counts[['green']]), "</span> safe ",
        "• <span style='color:", code_to_color['amber'], "'>", as.integer(counts[['amber']]), "</span> caution ",
        "• <span style='color:", code_to_color['red'], "'>", as.integer(counts[['red']]), "</span> rest.</p>",
        if (length(reg_counts)) paste0("<p><b>By region</b> - ",
                                       paste(paste0(names(reg_counts), ": ", as.integer(reg_counts)), collapse = " • "),
                                       "</p>") else ""
      ))
    } else {
      row <- current_row(); validate(need(!is.null(row) && nrow(row) == 1, "No data"))
      make_story(row, current_prev(), map_data())
    }
  })
  
  output$insights <- renderUI({
    tick10()
    mdf <- map_data()
    fact <- pick_rotating(FUN_FACTS, key=paste0(rv$region_sel, "_", rv$date_sel, "_fact"), period_seconds = 10)
    if (nrow(mdf) > 0){
      best <- mdf %>%
        arrange(match(overall, c("green","amber","red")), desc(sample_date)) %>%
        head(3)
      best_sites <- paste(best$site_name_short, collapse=" • ")
      regline <- if (!is.null(rv$region_sel) && rv$region_sel != "All regions") paste0("In ", rv$region_sel, ": ") else "All regions: "
      HTML(paste0(
        "<ul class='insights-list'>",
        "<li><span class='badge good'>🏆 Top</span> ", regline, ifelse(nchar(best_sites)>0, best_sites, "—"), "</li>",
        "<li><span class='badge fact'>🧠 Fun fact</span> ", fact, ".</li>",
        "<li><span class='badge tip'>🧭 Tip</span> Shade shows the region. Pins show each beach. Click a shaded area to zoom.</li>",
        "</ul>"
      ))
    } else {
      HTML(paste0(
        "<ul class='insights-list'>",
        "<li><span class='badge good'>🏆 Top</span> No map pins for this selection.</li>",
        "<li><span class='badge fact'>🧠 Fun fact</span> ", fact, ".</li>",
        "<li><span class='badge tip'>🧭 Tip</span> Try another date or region.</li>",
        "</ul>"
      ))
    }
  })
}

shinyApp(ui, server)
# ==================== end app.R ======================

