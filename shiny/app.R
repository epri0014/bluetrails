# ---------- paths ----------
suppressWarnings({
  app_dir <- tryCatch({
    if (requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable())
      dirname(rstudioapi::getActiveDocumentContext()$path) else getwd()
  }, error=function(e) getwd())
})
excel_path <- file.path(app_dir, "1984_07-2024_06_Port_Phillip_Bay_Water_quality_data.xlsx")
if (!file.exists(excel_path)) stop("File not found: ", excel_path)

# ---------- packages ----------
library(shiny)
pkgs <- c("bslib","leaflet","dplyr","readxl","lubridate","stringr","tidyr","purrr","tibble","htmltools")
need <- setdiff(pkgs, rownames(installed.packages()))
if (length(need)) install.packages(need)
invisible(lapply(pkgs, library, character.only=TRUE))

# ---------- helpers ----------
numify <- function(x){ suppressWarnings(as.numeric(gsub("[^0-9.\\-]", "", as.character(x)))) }
parse_date_any <- function(x){
  if (inherits(x, "Date")) return(as.Date(x))
  if (is.numeric(x)) return(as.Date(x, origin = "1899-12-30"))
  suppressWarnings(lubridate::as_date(x))
}
clip_invalid <- function(x, lo, hi){ ifelse(x < lo | x > hi, NA_real_, x) }

# ---------- read & clean ----------
raw_data <- readxl::read_excel(excel_path, sheet="Data")
raw_meta <- readxl::read_excel(excel_path, sheet="Site Metadata")

need_cols_data <- c("site_id","site_name_short","date","CHL_A","Turb","DO_mg","Temperature","N_TOTAL")
need_cols_meta <- c("site_id","site_name_short","latitude","longitude")
stopifnot(all(need_cols_data %in% names(raw_data)))
stopifnot(all(need_cols_meta %in% names(raw_meta)))

data <- raw_data %>%
  dplyr::select(all_of(need_cols_data)) %>%
  mutate(
    site_name_short = stringr::str_squish(as.character(site_name_short)),
    date        = parse_date_any(date),
    CHL_A       = numify(CHL_A),
    Turb        = numify(Turb),
    DO_mg       = numify(DO_mg),
    Temperature = numify(Temperature),
    N_TOTAL     = numify(N_TOTAL)
  ) %>%
  mutate(
    CHL_A       = clip_invalid(CHL_A, 0, 1000),
    Turb        = clip_invalid(Turb, 0, 1000),
    DO_mg       = clip_invalid(DO_mg, 0, 20),
    Temperature = clip_invalid(Temperature, 0, 40),
    N_TOTAL     = clip_invalid(N_TOTAL, 0, 5000)
  ) %>%
  filter(!(is.na(CHL_A) & is.na(Turb) & is.na(DO_mg) & is.na(Temperature) & is.na(N_TOTAL))) %>%
  filter(!is.na(site_id), !is.na(site_name_short), !is.na(date)) %>%
  distinct(site_name_short, date, .keep_all = TRUE)

meta <- raw_meta %>%
  dplyr::select(all_of(need_cols_meta)) %>%
  distinct(site_id, .keep_all=TRUE) %>%
  mutate(
    site_name_short = stringr::str_squish(as.character(site_name_short)),
    latitude  = numify(latitude),
    longitude = numify(longitude)
  )

df <- data %>%
  left_join(meta, by=c("site_id","site_name_short")) %>%
  filter(!is.na(latitude), !is.na(longitude)) %>%
  arrange(site_name_short, date)

validate(need(nrow(df) > 0, "No rows after cleaning & joining data with coordinates."))

all_sites <- sort(unique(df$site_name_short))
min_d <- min(df$date, na.rm=TRUE)
max_d <- max(df$date, na.rm=TRUE)

# ---------- rating logic ----------
code_to_color <- c(green="#24c38b", amber="#ffb000", red="#e74a5f")  # strict R-A-G
code_to_label <- c(green="Safe", amber="Caution", red="Unsafe")

code_algae   <- function(x) ifelse(is.na(x),"amber", ifelse(x < 2,"green", ifelse(x <= 5,"amber","red")))
code_clarity <- function(x) ifelse(is.na(x),"amber", ifelse(x <= 2,"green", ifelse(x <= 5,"amber","red")))
code_oxygen  <- function(x) ifelse(is.na(x),"amber", ifelse(x >= 6,"green", ifelse(x >= 4,"amber","red")))
code_nutr    <- function(x) ifelse(is.na(x),"amber", ifelse(x < 250,"green", ifelse(x <= 600,"amber","red")))
code_temp    <- function(x) ifelse(is.na(x),"amber", ifelse(x < 24,"green", ifelse(x <= 27,"amber","red")))
overall_code <- function(a,c,o,n,t){
  red_any <- (a=="red") | (c=="red") | (o=="red") | (n=="red") | (t=="red")
  amb_any <- (a=="amber") | (c=="amber") | (o=="amber") | (n=="amber") | (t=="amber")
  ifelse(red_any, "red", ifelse(amb_any, "amber", "green"))
}

# ---------- kid text ----------
kidline <- function(metric, code) switch(metric,
                                         "Algal Bloom"=switch(code, green="Algae are quiet - fish can breathe easily.",
                                                              amber="Some algae - keep an eye on the water.",
                                                              red="Algae are booming - sea life finds it hard to breathe."),
                                         "Clarity"    =switch(code, green="Water looks clear - easy to spot shells and fish.",
                                                              amber="A little cloudy - look carefully before you splash.",
                                                              red="Very cloudy - hard to see what’s under the waves."),
                                         "Oxygen"     =switch(code, green="Plenty of tiny bubbles - sea animals feel strong.",
                                                              amber="Fewer bubbles - they get tired faster.",
                                                              red="Low bubbles - sea life may struggle to breathe."),
                                         "Nutrients"  =switch(code, green="Just enough ‘food’ in the water - algae stays calm.",
                                                              amber="Extra food - algae could grow quickly.",
                                                              red="Too much food - algae can take over the bay."),
                                         "Temperature"=switch(code, green="Comfy and cool water.",
                                                              amber="Getting warm - take short dips.",
                                                              red="Very warm - stressful for wildlife."),
                                         "")

# ---------- icons & AVATARS ----------
icon_svg <- function(name, size=16){
  if (name=="fish") return(HTML(sprintf(
    "<svg width='%d' height='%d' viewBox='0 0 24 24' fill='currentColor' aria-hidden='true'><path d='M3 12c3-3 8-5 13-5 0 0-1 2-1 5s1 5 1 5c-5 0-10-2-13-5zM20 7l-2 2 2 2 2-2-2-2z'/></svg>", size, size)))
  if (name=="wave") return(HTML(sprintf(
    "<svg width='%d' height='%d' viewBox='0 0 24 24' fill='currentColor' aria-hidden='true'><path d='M3 16s1.5-2 4-2 4 2 6 2 4-2 6-2 4 2 4 2v2H3v-2z'/></svg>", size, size)))
  if (name=="leaf") return(HTML(sprintf(
    "<svg width='%d' height='%d' viewBox='0 0 24 24' fill='currentColor' aria-hidden='true'><path d='M21 3S9 4 6 7s-3 8 3 10 11-3 11-14zM8 13c2 0 5-1 7-3'/></svg>", size, size)))
  if (name=="thermo") return(HTML(sprintf(
    "<svg width='%d' height='%d' viewBox='0 0 24 24' fill='currentColor' aria-hidden='true'><path d='M10 14V6a2 2 0 114 0v8a4 4 0 11-4 0z'/></svg>", size, size)))
  if (name=="drop") return(HTML(sprintf(
    "<svg width='%d' height='%d' viewBox='0 0 24 24' fill='currentColor' aria-hidden='true'><path d='M12 2s7 7 7 12a7 7 0 11-14 0C5 9 12 2 12 2z'/></svg>", size, size)))
  HTML("")
}

avatar <- function(kind="turtle", size=56){
  if (kind=="turtle")   return(HTML(sprintf("<div class='ava ava-turtle' style='width:%dpx;height:%dpx'></div>", size,size)))
  if (kind=="dolphin")  return(HTML(sprintf("<div class='ava ava-dolphin' style='width:%dpx;height:%dpx'></div>", size,size)))
  if (kind=="crab")     return(HTML(sprintf("<div class='ava ava-crab' style='width:%dpx;height:%dpx'></div>", size,size)))
  HTML("")
}

# ---------- theme ----------
theme <- bslib::bs_theme(
  version = 5,
  bootswatch = "minty",
  primary = "#1a7bd6",
  bg = "#f3f8ff",
  fg = "#202022",
  base_font = bslib::font_google("Nunito")
)

chip <- function(id, title, content){
  tags$span(
    id = id, class="chip", `data-bs-toggle`="popover", `data-bs-trigger`="hover focus",
    `data-bs-placement`="top", `data-bs-html`="true", `data-bs-content`=content,
    icon_svg("wave"), HTML(paste0("<b>", title, "</b>"))
  )
}

ui <- bslib::page_navbar(
  title = "Ocean Heroes - Kids’ Water Guide",
  theme = theme,
  
  # Put CSS/JS + bubbles in header to avoid navbar warnings
  header = tagList(
    tags$head(
      tags$style(HTML("
        :root{
          --sea1:#8fd3ff; --sea2:#a4ffd8; --sea3:#ffe6a3; --sea4:#b7f2ff;
          --card:#fff;
        }
        body{
          background:
            radial-gradient(1200px 700px at -10% 0%, var(--sea1), transparent 60%),
            radial-gradient(1200px 800px at 110% 10%, var(--sea2), transparent 60%),
            radial-gradient(900px 700px at 50% 120%, var(--sea3), transparent 60%),
            radial-gradient(800px 500px at 20% 100%, var(--sea4), transparent 60%);
        }
        .container-lg{ max-width:1140px; }
        .grid-2{ display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:20px; }
        .grid-3{ display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:20px; }
        @media (max-width: 992px){ .grid-2, .grid-3{ grid-template-columns:1fr; } }
        .no-overlap .form-select, .no-overlap .form-control, .no-overlap .btn { width:100% }
        .leaflet-top.leaflet-right { top: 74px; }

        /* fun patterned cards */
        .card-cute{
          background:
            linear-gradient(135deg, rgba(255,255,255,.98), rgba(255,255,255,.98)),
            radial-gradient(12px 12px at 8px 8px, #e9f7ff 30%, transparent 31%) 0 0 / 28px 28px,
            radial-gradient(12px 12px at 22px 22px, #fffbe6 30%, transparent 31%) 0 0 / 28px 28px;
          border:2px solid #000; border-radius:22px; padding:16px;
          box-shadow:6px 6px 0 #00000018; transition:transform .2s;
        }
        .card-cute:hover{ transform:translateY(-2px) }

        .chip{
          display:inline-flex; align-items:center; gap:8px; margin:6px 6px 0 0;
          padding:10px 12px; border:2px solid #000; border-radius:999px; background:#ffffffee;
        }
        .badge-dot{ width:12px; height:12px; border-radius:50%; border:2px solid #000; display:inline-block; }
        .dot-green{ background:#24c38b } .dot-amber{ background:#ffb000 } .dot-red{ background:#e74a5f }
        .section-title{ font-weight:800; letter-spacing:.3px; }

        .btn-ghost{ background:#1a7bd6; color:#fff; border:2px solid #0f5ca5; box-shadow:0 4px 0 #0f5ca5; }
        .btn-ghost:hover{ filter:brightness(.95); }
        .btn-warning{ font-weight:700; }

        /* animated bubbles */
        .ocean-bubbles{ position:fixed; inset:0; pointer-events:none; z-index:0; }
        .ocean-bubbles span{
          position:absolute; border-radius:50%; opacity:.9;
          background:radial-gradient(circle at 30% 30%, #fff, rgba(255,255,255,.25));
          animation: rise 10s linear infinite;
          filter: drop-shadow(0 0 8px rgba(255,255,255,.7));
        }
        @keyframes rise{ from{ transform:translateY(30px) scale(.9) } to{ transform:translateY(-120vh) scale(1.1) } }

        /* colourful gradient wash over the map */
        .map-wash{
          position:absolute; inset:0; pointer-events:none; z-index:400;
          background: linear-gradient(120deg, rgba(0,191,255,.12), rgba(0,220,180,.10), rgba(255,196,0,.12));
          mix-blend-mode: multiply; animation: waveShift 12s ease-in-out infinite alternate;
          display:none;
        }
        @keyframes waveShift{ from{filter:saturate(1)} to{filter:saturate(1.5)} }

        /* avatars (turtle, dolphin, crab only) */
        .ava{ border:2px solid #000; border-radius:50%; background:#fff; position:relative; overflow:hidden;
              box-shadow:4px 4px 0 #00000018; animation:bob 3.6s ease-in-out infinite }
        @keyframes bob{ 0%,100%{ transform:translateY(0) } 50%{ transform:translateY(-4px) } }
        .ava-turtle::before{ content:''; position:absolute; inset:10% 15%;
          background:radial-gradient(circle at 30% 50%, #2ecc71 40%, #116e36 41%); border-radius:50% }
        .ava-dolphin::before{ content:''; position:absolute; inset:10% 12%;
          background:radial-gradient(circle at 50% 50%, #5dade2 45%, #1a7bd6 46%); border-radius:50% }
        .ava-crab::before{ content:''; position:absolute; inset:14% 18%;
          background:radial-gradient(circle at 50% 50%, #e74a5f 45%, #a92434 46%); border-radius:50% }

        /* HARD REMOVE any 'egg' or 'oval' shapes, whatever they're called */
        .egg, .eggs, .egg-stack, .traffic-eggs, .traffic-ovals, .status-egg,
        .oval, .ovals, .status-oval,
        [class*='egg' i], [class*='oval' i] {
          display: none !important;
          visibility: hidden !important;
          width: 0 !important; height: 0 !important; padding: 0 !important; margin: 0 !important;
          overflow: hidden !important; opacity: 0 !important;
        }

        /* confetti */
        .confetti{position:fixed;left:0;top:0;pointer-events:none;z-index:9999}
        .cf-piece{position:absolute;width:8px;height:12px;opacity:.95;border-radius:2px}
      ")),
      tags$script(HTML("
        (function(){
          // init popovers
          function initPopovers(){
            var els = document.querySelectorAll('[data-bs-toggle=\"popover\"]');
            Array.prototype.forEach.call(els, function(el){
              try { new bootstrap.Popover(el); } catch(e){}
            });
          }
          document.addEventListener('DOMContentLoaded', initPopovers);
          document.addEventListener('shiny:value', initPopovers, true);

          // confetti
          function rand(a,b){return Math.random()*(b-a)+a}
          function dropOne(cnv,w,h,clr){
            var d=document.createElement('div'); d.className='cf-piece'; d.style.background=clr;
            d.style.left=rand(0,w)+'px'; d.style.top='-20px'; d.style.transform='rotate('+rand(0,360)+'deg)';
            cnv.appendChild(d);
            var y=-20,x=parseFloat(d.style.left),vy=rand(2,4),vx=rand(-1,1),rot=rand(-2,2);
            var t=setInterval(function(){
              y+=vy;x+=vx;d.style.top=y+'px';d.style.left=x+'px';
              d.style.transform='rotate('+(rot+=rand(-6,6))+'deg)';
              if(y>h+30){clearInterval(t);d.remove();}
            },16);
          }
          Shiny.addCustomMessageHandler('confetti', function(opts){
            var n=opts&&opts.n||160, colors=opts&&opts.colors||['#24c38b','#ffb000','#e74a5f','#1a7bd6','#5dade2'];
            var cnv=document.querySelector('.confetti'); if(!cnv){cnv=document.createElement('div'); cnv.className='confetti'; document.body.appendChild(cnv);}
            var w=window.innerWidth||800,h=window.innerHeight||600;
            for(var i=0;i<n;i++) dropOne(cnv,w,h,colors[Math.floor(Math.random()*colors.length)]);
            setTimeout(function(){ if(cnv) cnv.innerHTML=''; }, 2500);
          });

          // toggle map wash
          Shiny.addCustomMessageHandler('toggleMapWash', function(x){
            var el=document.getElementById('mapwash');
            if(el) el.style.display = (x && x.show) ? 'block' : 'none';
          });

          // Nuke any 'egg/oval' nodes that appear later
          function nukeEggs(root){
            try{
              var nodes = root.querySelectorAll(\".egg, .eggs, .egg-stack, .traffic-eggs, .traffic-ovals, .status-egg, .oval, .ovals, .status-oval, [class*='egg' i], [class*='oval' i]\");
              nodes.forEach(function(n){ n.remove(); });
            }catch(e){}
          }
          document.addEventListener('DOMContentLoaded', function(){ nukeEggs(document); });
          new MutationObserver(function(muts){
            muts.forEach(function(m){
              if(m.addedNodes && m.addedNodes.length){
                m.addedNodes.forEach(function(n){
                  if(n.nodeType===1){ nukeEggs(n); }
                });
              }
            });
          }).observe(document.body, {childList:true, subtree:true});

          // fun facts rotator
          var facts = [
            'Seahorses are fish that swim upright!',
            'After rain, water can be cloudy - best to wait a day.',
            'Tiny plants (algae) need light and nutrients to grow.',
            'Fish use oxygen in water - just like we use air!',
            'Clear water helps you spot shells and crabs!'
          ];
          var idx = 0;
          function rotateFacts(){
            var el = document.getElementById('funfacts');
            if(!el) return;
            idx = (idx + 1) % facts.length;
            el.innerText = facts[idx];
          }
          setInterval(rotateFacts, 4500);
        })();
      "))
    ),
    # bubbles layer
    tags$div(class="ocean-bubbles",
             lapply(1:48, function(i){
               left <- sample(2:98,1); delay <- runif(1,0,10); size <- sample(12:26,1)
               tags$span(style=sprintf("left:%d%%; bottom:-20px; width:%dpx; height:%dpx; animation-delay:%.2fs;", left,size,size,delay))
             })
    )
  ),
  
  # ------------ CONTENT ------------
  bslib::nav_panel(
    "Explore",
    div(class="container-lg py-3 no-overlap",
        
        # HERO + controls + Confetti note
        div(class="card-cute mb-3",
            div(class="grid-3",
                div(
                  div(class="section-title h4 mb-2","What this page is"),
                  p("A bright, simple guide that shows if today’s beach water is safe and explains ",
                    "why the colour is green, amber, or red using real measurements from the bay.")
                ),
                div(
                  div(class="section-title h4 mb-2","What you’ll see"),
                  tags$ul(
                    tags$li(tags$b("Traffic-light badges"), " for each beach"),
                    tags$li("A colorful map you can tap to zoom"),
                    tags$li("Short reasons in kid-friendly words")
                  )
                ),
                div(
                  div(class="section-title h4 mb-2","How to use it"),
                  tags$ol(
                    tags$li("Pick a beach and date."),
                    tags$li("Read the badge and the short reasons."),
                    tags$li("Hover Quick Help to learn what each measure means.")
                  )
                )
            ),
            tags$div(class="mt-2 p-3 rounded d-flex align-items-center gap-2",
                     style="background:#fff4db;border:2px dashed #ffb000;",
                     HTML("<b>Confetti note:</b> you’ll see confetti when a beach turns <b>Safe</b> or improves"),
                     HTML("&nbsp;"), tags$span(style="display:inline-block;", avatar('dolphin', 36)),
                     HTML("&nbsp;"), tags$span(style="display:inline-block;", avatar('turtle', 36))
            ),
            tags$hr(),
            div(class="grid-2",
                div(
                  div(class="section-title h5 mt-1","Pick a place & day"),
                  selectInput("site","Beach / Site", choices=c("All sites", all_sites), selected="All sites"),
                  dateInput("date","Date", value=max_d, min=min_d, max=max_d),
                  checkboxInput("funmap", "Fun Map Mode", value = TRUE),
                  fluidRow(
                    column(6, actionButton("resetView","Reset View", class="btn btn-ghost w-100")),
                    column(6, actionButton("showDisc","Show Disclaimer", class="btn btn-warning w-100"))
                  )
                ),
                div(
                  div(class="section-title h5 mt-1","Quick Help (hover)"),
                  chip("qh1","Algal Bloom (Chl-a)",
                       "When there’s <b>a lot of algae</b>, water can turn green and fish find it harder to breathe."),
                  chip("qh2","Clarity (NTU)",
                       "Tells how <b>clear or cloudy</b> the water is. Cloudy water makes it hard to spot hazards."),
                  chip("qh3","Oxygen (mg/L)",
                       "Shows the <b>bubbles</b> sea animals need to breathe. More oxygen = happier fish."),
                  chip("qh4","Nutrients (µg/L)",
                       "Food for algae. <b>Too much</b> from drains can cause algae to grow quickly."),
                  chip("qh5","Temperature (°C)",
                       "<b>Very warm</b> water can stress wildlife and increase algae growth.")
                )
            )
        ),
        
        # MAP
        bslib::card(
          full_screen = TRUE,
          class="card-cute mb-3 position-relative",
          card_header = tagList("Map - coloured pins show ocean health",
                                span(class="ms-2 small text-muted", "(toggle Fun Map above)")),
          div(id="mapwrap", style="position:relative;",
              leafletOutput("map", height = 560),
              div(class="map-wash", id="mapwash")
          )
        ),
        
        # LOWER PANELS (story + avatars rail + badges + insights)
        div(class="grid-3",
            
            # Story card and avatar rail (NO EGGS)
            bslib::card(class="card-cute position-relative",
                        card_header=uiOutput("panel_title"),
                        div(class="d-flex align-items-start gap-3",
                            div(style="flex:1;", uiOutput("story_block")),
                            div(style="width:96px; display:flex; flex-direction:column; gap:10px;",
                                actionLink("meet_turtle",  label = avatar("turtle", 72),  icon = NULL),
                                actionLink("meet_dolphin", label = avatar("dolphin", 72), icon = NULL),
                                actionLink("meet_crab",    label = avatar("crab", 72),    icon = NULL)
                            )
                        )
            ),
            
            bslib::card(class="card-cute", card_header=uiOutput("badges_title"), uiOutput("badges")),
            
            bslib::card(class="card-cute", card_header="Short Reasons, Tips and Fun Fact", uiOutput("insights"))
        )
    )
  )
)

# ---------- server ----------
server <- function(input, output, session){
  
  # Disclaimer
  observeEvent(input$showDisc, {
    showModal(modalDialog(
      title = "Data and Safety",
      HTML("This page simplifies water-quality information for children and families. ",
           "Always follow local council and life-saving advice. Rain can change conditions quickly."),
      easyClose = TRUE, footer = modalButton("Close")
    ))
  })
  
  # latest-on/before-date per site (prefer Temperature present)
  pick_latest_with_temp <- function(tbl){
    tbl <- tbl[order(tbl$date, decreasing=TRUE),]
    idx <- which(!is.na(tbl$Temperature))
    if (length(idx)) tbl[idx[1], , drop=FALSE] else tbl[1, , drop=FALSE]
  }
  
  map_data <- reactive({
    req(input$date)
    sub <- df[df$date <= as.Date(input$date), ]
    if (nrow(sub) == 0) return(df[0,])
    split_df <- split(sub, sub$site_name_short)
    purrr::list_rbind(purrr::map(split_df, pick_latest_with_temp)) %>%
      mutate(
        a = code_algae(CHL_A),
        c = code_clarity(Turb),
        o = code_oxygen(DO_mg),
        n = code_nutr(N_TOTAL),
        t = code_temp(Temperature),
        overall   = overall_code(a,c,o,n,t),
        color     = unname(code_to_color[overall]),
        label_txt = paste0(site_name_short, " - ", unname(code_to_label[overall]))
      )
  })
  
  prev_row <- function(site, date_cut){
    prev <- df %>% filter(site_name_short==site, date < as.Date(date_cut))
    if (nrow(prev)==0) return(df[0,])
    pick_latest_with_temp(prev)
  }
  
  current_row <- reactive({
    if (is.null(input$site) || input$site=="All sites") return(NULL)
    sub <- df %>% filter(site_name_short==input$site, date <= as.Date(input$date))
    if (nrow(sub)==0) return(NULL)
    pick_latest_with_temp(sub)
  })
  
  # MAP (with basemap toggle)
  output$map <- renderLeaflet({
    mdf <- map_data()
    validate(need(nrow(mdf) > 0, "No samples available on/before this date."))
    
    center_lat <- median(mdf$latitude)
    center_lon <- median(mdf$longitude)
    provider <- if (isTRUE(input$funmap)) providers$Esri.OceanBasemap else providers$Stamen.Watercolor
    
    leaflet(mdf, options = leafletOptions(minZoom = 8, maxZoom = 16)) %>%
      addProviderTiles(provider) %>%
      setView(lng = center_lon, lat = center_lat, zoom = 10) %>%
      addScaleBar(position = "bottomleft") %>%
      addCircleMarkers(
        lng=~longitude, lat=~latitude, radius=11,
        color="#222", weight=2, fillOpacity=0.95, fillColor=~color,
        label=~label_txt, layerId=~site_name_short,
        popup=~paste0(
          "<b>", site_name_short, "</b><br/>", format(date, "%d %b %Y"), "<br/>",
          "<span style='color:", color, "'>Overall: ", code_to_label[overall], "</span><br/>",
          "<div style='opacity:.9'>",
          "Chl-a: ", ifelse(is.na(CHL_A),"–",sprintf('%.1f µg/L', CHL_A)), " · ",
          "NTU: ", ifelse(is.na(Turb),"–",sprintf('%.2f', Turb)), " · ",
          "DO: ", ifelse(is.na(DO_mg),"–",sprintf('%.1f mg/L', DO_mg)), "<br/>",
          "Total N: ", ifelse(is.na(N_TOTAL),"–",sprintf('%.0f µg/L', N_TOTAL)), " · ",
          "Temp: ", ifelse(is.na(Temperature),"–",sprintf('%.1f °C', Temperature)),
          "</div>"
        )
      )
  })
  
  # toggle map wash overlay
  observe({
    session$sendCustomMessage('toggleMapWash', list(show = isTRUE(input$funmap)))
  })
  session$onFlushed(function() {
    session$sendCustomMessage('toggleMapWash', list(show = TRUE))
  }, once = TRUE)
  
  # click marker selects site
  observeEvent(input$map_marker_click, ignoreInit=TRUE, {
    id <- input$map_marker_click$id
    if (!is.null(id) && id %in% all_sites) updateSelectInput(session, "site", selected=id)
  })
  
  # auto-fit / auto-zoom
  observeEvent(list(input$site, input$date), {
    mdf <- map_data(); req(nrow(mdf) > 0)
    proxy <- leafletProxy("map", data = mdf)
    if (!is.null(input$site) && input$site != "All sites" && any(mdf$site_name_short == input$site)) {
      r <- mdf %>% dplyr::filter(site_name_short == input$site) %>% dplyr::slice(1)
      proxy %>% setView(lng = r$longitude[1], lat = r$latitude[1], zoom = 12)
    } else {
      proxy %>% fitBounds(
        lng1 = min(mdf$longitude, na.rm=TRUE), lat1 = min(mdf$latitude, na.rm=TRUE),
        lng2 = max(mdf$longitude, na.rm=TRUE), lat2 = max(mdf$latitude, na.rm=TRUE)
      )
    }
  }, ignoreInit = TRUE)
  
  # reset
  observeEvent(input$resetView, {
    updateSelectInput(session, "site", selected = "All sites")
    updateDateInput(session, "date", value = max_d)
  })
  
  # TITLES
  output$panel_title <- renderUI({
    if (is.null(input$site) || input$site=="All sites")
      HTML(paste0("<b>All sites</b> - ", format(as.Date(input$date), "%d %B %Y")))
    else {
      row <- current_row(); validate(need(!is.null(row) && nrow(row)==1, "No data for this site/date."))
      oc <- overall_code(code_algae(row$CHL_A), code_clarity(row$Turb),
                         code_oxygen(row$DO_mg), code_nutr(row$N_TOTAL), code_temp(row$Temperature))
      HTML(paste0("<b>", row$site_name_short, "</b> - ", format(row$date, "%d %B %Y"),
                  " &nbsp;<span style='color:", code_to_color[oc], "'>", code_to_label[oc], "</span>"))
    }
  })
  
  # STORY BLOCK
  make_story <- function(row){
    oc <- overall_code(code_algae(row$CHL_A), code_clarity(row$Turb),
                       code_oxygen(row$DO_mg), code_nutr(row$N_TOTAL), code_temp(row$Temperature))
    opener <- if (oc=="green") "Splash-tastic today!"
    else if (oc=="amber") "Look closely today - pick the clearest patch to paddle."
    else "Better for sandcastles today - let the waves rest."
    
    p1 <- paste0(
      "<b>Today’s Story:</b> ", opener, " The water here is checked with real tests. ",
      "We look at how clear it is, how many bubbles help fish breathe, how much algae there is, ",
      "and how warm the water feels."
    )
    p2 <- paste0(
      "<b>What it means right now:</b> ",
      "Clarity - ", kidline("Clarity", code_clarity(row$Turb)), " ",
      "Oxygen - ", kidline("Oxygen", code_oxygen(row$DO_mg)), " ",
      "Algae - ",  kidline("Algal Bloom", code_algae(row$CHL_A)), " ",
      "Temperature - ", kidline("Temperature", code_temp(row$Temperature)), "."
    )
    p3 <- paste0(
      "<b>Try this here:</b> bring a small clear jar and scoop some water. ",
      "Can you spot tiny bits or sand? If it looks cloudy, wait for a clearer day or walk the shore and count shells."
    )
    p4 <- "<b>Be a Bay Helper:</b> use bins, keep soaps out of drains, and teach a friend one water fact today."
    
    HTML(paste(p1, p2, p3, p4, sep = "<br/><br/>"))
  }
  
  output$story_block <- renderUI({
    if (is.null(input$site) || input$site=="All sites") {
      mdf <- map_data()
      counts <- table(factor(mdf$overall, levels=c("green","amber","red")))
      best <- mdf %>% arrange(match(overall, c("green","amber","red")), desc(date)) %>% slice_head(n=3)
      HTML(paste0(
        "<b>Across the bay today</b> - ",
        "<span style='color:",code_to_color['green'],"'>",counts[['green']],"</span> green, ",
        "<span style='color:",code_to_color['amber'],"'>",counts[['amber']],"</span> amber, ",
        "<span style='color:",code_to_color['red'],"'>",counts[['red']],"</span> red.<br/><br/>",
        "<b>Where to explore:</b> ", paste(best$site_name_short, collapse=' • '), "<br/><br/>",
        "<b>Idea:</b> pick a beach and compare its story with yesterday. What changed?"
      ))
    } else {
      row <- current_row(); validate(need(!is.null(row) && nrow(row)==1, "No data."))
      make_story(row)
    }
  })
  
  # BADGES
  badge_chip <- function(title, code, value_text=NULL, icon=NULL){
    div(class="d-flex align-items-center gap-2 my-1",
        span(class=paste("badge-dot", switch(code, green="dot-green", amber="dot-amber", red="dot-red"))),
        if (!is.null(icon)) span(style="color:#333;", icon_svg(icon)),
        HTML(paste0("<b>",title,":</b> ",
                    "<span style='color:",code_to_color[code],"'>",code_to_label[code],"</span>",
                    if (!is.null(value_text)) paste0(" <span style='opacity:.7'>", value_text, "</span>") else "")))
  }
  
  output$badges_title <- renderUI({
    if (is.null(input$site) || input$site=="All sites") "Legend - what colours mean"
    else "Today’s traffic-light reasons"
  })
  
  output$badges <- renderUI({
    if (is.null(input$site) || input$site=="All sites") {
      div(
        badge_chip("Overall","green","Good for a splash", "wave"),
        badge_chip("Overall","amber","Take care", "wave"),
        badge_chip("Overall","red","Try another day", "wave")
      )
    } else {
      row <- current_row(); validate(need(!is.null(row) && nrow(row)==1, "No data."))
      tagList(
        badge_chip("Algal Bloom", code_algae(row$CHL_A),
                   paste0("Chl-a: ", ifelse(is.na(row$CHL_A),"–", sprintf('%.1f µg/L', row$CHL_A))), "wave"),
        badge_chip("Clarity", code_clarity(row$Turb),
                   paste0("Turbidity: ", ifelse(is.na(row$Turb),"–", sprintf('%.2f NTU', row$Turb))), "drop"),
        badge_chip("Oxygen", code_oxygen(row$DO_mg),
                   paste0("DO: ", ifelse(is.na(row$DO_mg),"–", sprintf('%.1f mg/L', row$DO_mg))), "fish"),
        badge_chip("Nutrients", code_nutr(row$N_TOTAL),
                   paste0("Total N: ", ifelse(is.na(row$N_TOTAL),"–", sprintf('%.0f µg/L', row$N_TOTAL))), "leaf"),
        badge_chip("Temperature", code_temp(row$Temperature),
                   paste0("Temp: ", ifelse(is.na(row$Temperature),"–", sprintf('%.1f °C', row$Temperature))), "thermo")
      )
    }
  })
  
  # INSIGHTS
  insight_line <- function(icon_name, title, text){
    div(class="my-1",
        span(style="margin-right:6px;vertical-align:middle;", icon_svg(icon_name, 18)),
        HTML(paste0("<b>", title, ":</b> ", text)))
  }
  
  make_insights_single <- function(row, prev){
    codes <- list(
      algae = code_algae(row$CHL_A), clar  = code_clarity(row$Turb),
      oxy   = code_oxygen(row$DO_mg), nutr  = code_nutr(row$N_TOTAL),
      temp  = code_temp(row$Temperature)
    )
    tagList(
      insight_line("drop",  "Can we see clearly?", kidline("Clarity", codes$clar)),
      insight_line("fish",  "Can fish breathe well?", kidline("Oxygen",  codes$oxy)),
      insight_line("leaf",  "Is there too much 'food' for algae?", kidline("Nutrients", codes$nutr)),
      insight_line("wave",  "Are algae quiet or busy?", kidline("Algal Bloom", codes$algae)),
      insight_line("thermo","How warm is the water?", kidline("Temperature", codes$temp)),
      tags$hr(),
      HTML("<b>Be a Bay Helper:</b> use bins, keep soaps out of drains, and share one new water fact today."),
      div(class="mt-2 p-2 rounded", style="background:#f2f8ff;border:2px dashed #1a7bd6;",
          HTML("<b>Fun fact:</b> <span id='funfacts'>Seahorses are fish that swim upright!</span>"))
    )
  }
  
  make_insights_all <- function(mdf){
    counts <- table(factor(mdf$overall, levels=c("green","amber","red")))
    best <- mdf %>% arrange(match(overall, c("green","amber","red")), desc(date)) %>% slice_head(n=3)
    tagList(
      insight_line("wave","What we checked", paste0(nrow(mdf), " beaches today.")),
      insight_line("fish","Great right now", paste0(counts[["green"]], " beaches look friendly.")),
      insight_line("leaf","Needs care",       paste0(counts[["amber"]], " beaches need careful choices.")),
      insight_line("drop","Try later",        paste0(counts[["red"]], " beaches might be better another day.")),
      tags$hr(),
      HTML("<b>After rain:</b> wait a day before swimming - drains can carry dirty water into the bay."),
      div(class="mt-2 p-2 rounded", style="background:#f2f8ff;border:2px dashed #1a7bd6;",
          HTML("<b>Fun fact:</b> <span id='funfacts'>Clear water helps you spot shells and crabs!</span>"))
    )
  }
  
  output$insights <- renderUI({
    if (is.null(input$site) || input$site=="All sites") make_insights_all(map_data())
    else {
      row  <- current_row(); validate(need(!is.null(row) && nrow(row)==1, "No data."))
      prev <- prev_row(row$site_name_short[1], row$date[1])
      make_insights_single(row, prev)
    }
  })
  
  # 🎉 CONFETTI on improvement or Safe status
  observe({
    if (is.null(input$site) || input$site=="All sites") return()
    row  <- current_row(); if (is.null(row) || nrow(row)!=1) return()
    prev <- prev_row(row$site_name_short[1], row$date[1]); if (nrow(prev)!=1) return()
    
    score <- c(green=3, amber=2, red=1)
    now_code  <- overall_code(code_algae(row$CHL_A), code_clarity(row$Turb),
                              code_oxygen(row$DO_mg), code_nutr(row$N_TOTAL), code_temp(row$Temperature))
    prev_code <- overall_code(code_algae(prev$CHL_A), code_clarity(prev$Turb),
                              code_oxygen(prev$DO_mg), code_nutr(prev$N_TOTAL), code_temp(prev$Temperature))
    if (score[[now_code]] > score[[prev_code]] || now_code=="green")
      session$sendCustomMessage("confetti", list(n = if (now_code=="green") 170 else 130))
  })
  
  # Avatar fun-fact modals (status-neutral)
  observeEvent(input$meet_turtle, {
    showModal(modalDialog(title="Turtle says",
                          "I love clear water - it helps me find jellyfish snacks!",
                          easyClose=TRUE, footer = modalButton("Close")))
  })
  observeEvent(input$meet_dolphin, {
    showModal(modalDialog(title="Dolphin says",
                          "We breathe air like you - clean water makes hunting easier!",
                          easyClose=TRUE, footer = modalButton("Close")))
  })
  observeEvent(input$meet_crab, {
    showModal(modalDialog(title="Crab says",
                          "Cloudy water makes me hide - I like sandy spots!",
                          easyClose=TRUE, footer = modalButton("Close")))
  })
}

shinyApp(ui, server)
