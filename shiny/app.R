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
pkgs <- c("bslib","leaflet","dplyr","readxl","lubridate","stringr","tidyr","purrr","tibble")
#need <- setdiff(pkgs, rownames(installed.packages()))
#if (length(need)) install.packages(need)
#invisible(lapply(pkgs, library, character.only=TRUE))
pkgs <- c("bslib","leaflet","dplyr","readxl","lubridate","stringr","tidyr","purrr","tibble")
lapply(pkgs, library, character.only=TRUE)

# ---------- helpers (robust parsing & cleaning) ----------
numify <- function(x){ as.numeric(gsub("[^0-9.\\-]", "", as.character(x))) }
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
  # remove impossible values (set to NA)
  mutate(
    CHL_A       = clip_invalid(CHL_A, 0, 1000),
    Turb        = clip_invalid(Turb, 0, 1000),
    DO_mg       = clip_invalid(DO_mg, 0, 20),
    Temperature = clip_invalid(Temperature, 0, 40),
    N_TOTAL     = clip_invalid(N_TOTAL, 0, 5000)
  ) %>%
  # drop rows with no metrics at all
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
code_to_color <- c(green="#1db954", amber="#ffb000", red="#e63946")
code_to_emoji <- c(green="🟢", amber="🟡", red="🔴")
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

# ---------- kid text & trends ----------
kidline <- function(metric, code) switch(metric,
                                         "Algal Bloom"=switch(code, green="Algae are sleepy - fish can feast! 🐟",
                                                              amber="Some algae around - keep an eye out. 👀",
                                                              red="Algae party! Fish find it hard to breathe. 😮‍💨"),
                                         "Clarity"    =switch(code, green="Crystal clear - I can see my lunch! 👓",
                                                              amber="A bit murky - look before you splash. 🌊",
                                                              red="Very murky - not much to see. 🙈"),
                                         "Oxygen"     =switch(code, green="Bubbly water - fish are happy! 💨🐠",
                                                              amber="Fewer bubbles - fish get a little tired. 😴",
                                                              red="Low oxygen - fish struggle to breathe. 😵"),
                                         "Nutrients"  =switch(code, green="Just right - not too much food for algae. ✅",
                                                              amber="Extra nutrients - algae may grow. 🌱",
                                                              red="Too many nutrients - algae can take over. 🚨"),
                                         "Temperature"=switch(code, green="Cool & comfy - splash time! ❄️",
                                                              amber="A bit warm - take care. 🌤️",
                                                              red="Very warm - wildlife can get stressed. 🥵"),
                                         "")

trend_arrow <- function(curr, prev, good_when_low = NA) {
  if (is.na(curr) || is.na(prev)) return("")
  ch <- curr - prev
  if (abs(ch) < 1e-6) return("⟷")
  if (isTRUE(good_when_low)) { if (ch > 0) "⬆️" else "⬇️" }
  else if (identical(good_when_low, FALSE)) { if (ch > 0) "⬆️" else "⬇️" }
  else if (is.na(good_when_low)) { if (ch > 0) "⬆️" else "⬇️" }
}

# ---------- UI (animations + confetti) ----------
theme <- bslib::bs_theme(version=5, bootswatch="minty", base_font=bslib::font_google("Nunito"))

ui <- bslib::page_navbar(
  title="Ocean Heroes - Kids’ Water Guide",
  theme=theme,
  tags$head(
    tags$style(HTML("
      :root{ --chip:#222; }
      .card-header{background:linear-gradient(90deg,#b3e5fc,#e8f5e9,#b3e5fc);
        background-size:300% 100%;animation:hdr 5s ease-in-out infinite;border-bottom:2px solid rgba(0,0,0,.06)}
      @keyframes hdr{0%{background-position:0% 50%}50%{background-position:100% 50%}100%{background-position:0% 50%}}
      .container-fluid{animation:pageIn .45s ease}
      @keyframes pageIn{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:none}}
      .speech-bubble{animation:pop .45s ease;box-shadow:0 8px 24px rgba(0,0,0,.08)}
      @keyframes pop{0%{transform:scale(.94);opacity:0}100%{transform:scale(1);opacity:1}}
      .badge-chip{display:flex;align-items:center;gap:10px;margin:8px 0;padding:12px 14px;border-radius:16px;border:2px solid var(--chip);background:#fff;transition:transform .15s, box-shadow .15s}
      .badge-chip:hover{transform:translateY(-2px) scale(1.02); box-shadow:0 10px 24px rgba(30,144,255,.16)}
      .pulse-green{animation:pulseG 1.6s ease-in-out infinite}
      .pulse-amber{animation:pulseA 1.6s ease-in-out infinite}
      .pulse-red{animation:pulseR 1.6s ease-in-out infinite}
      @keyframes pulseG{0%,100%{transform:scale(1)}50%{transform:scale(1.12)}}
      @keyframes pulseA{0%,100%{transform:scale(1)}50%{transform:scale(1.10)}}
      @keyframes pulseR{0%,100%{transform:scale(1)}50%{transform:scale(1.08)}}
      .insight-line{background:linear-gradient(90deg,rgba(255,255,255,0) 0%, rgba(255,255,0,.14) 50%, rgba(255,255,255,0) 100%);
        background-size:300% 100%; animation:shim 3s ease infinite; border-radius:8px; padding:6px 8px}
      @keyframes shim{0%{background-position:0% 0%}50%{background-position:100% 0%}100%{background-position:0% 0%}}
      .leaflet-container::after{content:'';position:absolute;left:10%;bottom:8%;width:6px;height:6px;border-radius:50%;background:rgba(135,206,250,.7);
        box-shadow:40px 20px 0 0 rgba(135,206,250,.6),80px -10px 0 0 rgba(135,206,250,.5),120px 10px 0 0 rgba(135,206,250,.4),160px -15px 0 0 rgba(135,206,250,.35),200px 5px 0 0 rgba(135,206,250,.3);
        animation:bubbles 7s linear infinite; pointer-events:none}
      @keyframes bubbles{0%{transform:translateY(0)}100%{transform:translateY(-120px)}}
      .confetti{position:fixed;left:0;top:0;pointer-events:none;z-index:9999}
      .cf-piece{position:absolute;width:8px;height:12px;opacity:.9;border-radius:2px}
    ")),
    tags$script(HTML("
      (function(){
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
          var n=opts&&opts.n||120, colors=opts&&opts.colors||['#1db954','#ffb000','#e63946','#43a5f5','#ff66c4'];
          var cnv=document.querySelector('.confetti'); if(!cnv){cnv=document.createElement('div'); cnv.className='confetti'; document.body.appendChild(cnv);}
          var w=window.innerWidth||800,h=window.innerHeight||600;
          for(var i=0;i<n;i++) dropOne(cnv,w,h,colors[Math.floor(Math.random()*colors.length)]);
          setTimeout(function(){ if(cnv) cnv.innerHTML=''; }, 2500);
        });
      })();
    "))
  ),
  bslib::nav_panel(
    "Explore",
    bslib::layout_sidebar(
      sidebar = bslib::sidebar(
        width=360,
        h4("Pick a place & day"),
        selectInput("site","Beach / Site", choices=c("All sites", all_sites), selected="All sites"),
        dateInput("date","Date", value=max_d, min=min_d, max=max_d),
        div(class="mt-3 p-3 rounded", style="background:#eefcf3;border:2px dashed #1db954;",
            HTML("<b>Tip:</b> Choose a date to colour every beach. Pick a beach to read fun insights! 🐧"))
      ),
      bslib::card(full_screen=TRUE,
                  card_header="Map — Coloured pins show ocean health today",
                  leafletOutput("map", height=460)
      ),
      bslib::layout_columns(
        col_widths=c(5,7),
        bslib::card(class="mb-3", card_header=uiOutput("panel_title"), uiOutput("speech_or_summary")),
        bslib::card(class="mb-3", card_header=uiOutput("badges_title"), uiOutput("badges")),
        bslib::card(class="mb-3", card_header=HTML("✨ Auto Insights for Kids"), uiOutput("insights"))
      )
    )
  )
) # no footer

# ---------- server ----------
server <- function(input, output, session){
  
  # pick latest-on/before-date per site, preferring rows with Temperature
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
        emoji     = unname(code_to_emoji[overall]),
        label_txt = paste0(emoji, " ", site_name_short, " — ", unname(code_to_label[overall]))
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
  
  # map (click pin => select site)
  output$map <- renderLeaflet({
    mdf <- map_data()
    validate(need(nrow(mdf) > 0, "No samples available on/before this date."))
    
    if (!is.null(input$site) && input$site != "All sites" &&
        nrow(mdf %>% filter(site_name_short == input$site)) == 1) {
      r <- mdf %>% filter(site_name_short == input$site)
      center_lat <- r$latitude[1]; center_lon <- r$longitude[1]; z <- 11
    } else {
      center_lat <- median(mdf$latitude); center_lon <- median(mdf$longitude); z <- 10
    }
    
    leaflet(mdf) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = center_lon, lat = center_lat, zoom = z) %>%
      addCircleMarkers(
        lng=~longitude, lat=~latitude, radius=11,
        color="#333333", weight=2, fillOpacity=0.95,
        fillColor=~color, label=~label_txt, layerId=~site_name_short,
        popup=~paste0(
          "<b>", site_name_short, "</b><br/>", format(date, "%d %b %Y"), "<br/>",
          "<span style='color:", color, "'>", emoji, " Overall: ", code_to_label[overall], "</span><br/>",
          "<div style='opacity:.8'>",
          "Chl-a: ", ifelse(is.na(CHL_A),"–",sprintf('%.1f µg/L', CHL_A)), " · ",
          "NTU: ", ifelse(is.na(Turb),"–",sprintf('%.2f', Turb)), " · ",
          "DO: ", ifelse(is.na(DO_mg),"–",sprintf('%.1f mg/L', DO_mg)), "<br/>",
          "Total N: ", ifelse(is.na(N_TOTAL),"–",sprintf('%.0f µg/L', N_TOTAL)), " · ",
          "Temp: ", ifelse(is.na(Temperature),"–",sprintf('%.1f °C', Temperature)),
          "</div>"
        )
      )
  })
  observeEvent(input$map_marker_click, ignoreInit=TRUE, {
    id <- input$map_marker_click$id
    if (!is.null(id) && id %in% all_sites) updateSelectInput(session, "site", selected=id)
  })
  
  # titles
  output$panel_title <- renderUI({
    if (is.null(input$site) || input$site=="All sites")
      HTML(paste0("<b>All sites</b> — ", format(as.Date(input$date), "%d %B %Y")))
    else {
      row <- current_row(); validate(need(!is.null(row) && nrow(row)==1, "No data for this site/date."))
      oc <- overall_code(code_algae(row$CHL_A), code_clarity(row$Turb),
                         code_oxygen(row$DO_mg), code_nutr(row$N_TOTAL), code_temp(row$Temperature))
      HTML(paste0("<b>", row$site_name_short, "</b> — ", format(row$date, "%d %B %Y"),
                  " &nbsp;&nbsp;<span style='color:", code_to_color[oc], "'>",
                  code_to_emoji[oc], " ", code_to_label[oc], "</span>"))
    }
  })
  
  # speech/summary
  speech_text <- function(oc){
    if (oc=="green") "“Yippee! The water looks great today — let’s go find fish!” 🐟"
    else if (oc=="amber") "“Hmm… today needs a little care. Let’s choose a safe spot and be ocean kind.” 🌊"
    else "“Uh-oh! Not the best for a splash — let’s help by keeping rubbish out of drains.” 🐧"
  }
  output$speech_or_summary <- renderUI({
    if (is.null(input$site) || input$site=="All sites") {
      mdf <- map_data()
      counts <- table(factor(mdf$overall, levels=c("green","amber","red")))
      best <- mdf %>% arrange(match(overall, c("green","amber","red")), desc(date)) %>% slice_head(n=3)
      div(class="speech-bubble",
          style="background:#fff;border:3px solid #333;border-radius:18px;padding:14px 16px;font-size:1.05rem;",
          HTML(paste0(
            "Today’s tally: ",
            "<span style='color:",code_to_color['green'],"'>",code_to_emoji['green']," ",counts[['green']],"</span> · ",
            "<span style='color:",code_to_color['amber'],"'>",code_to_emoji['amber']," ",counts[['amber']],"</span> · ",
            "<span style='color:",code_to_color['red'],"'>",code_to_emoji['red']," ",counts[['red']],"</span><br/>",
            "🏆 <b>Top spots:</b> ", paste(best$site_name_short, collapse=" • ")
          )))
    } else {
      row <- current_row(); validate(need(!is.null(row) && nrow(row)==1, "No data for this site/date."))
      oc <- overall_code(code_algae(row$CHL_A), code_clarity(row$Turb),
                         code_oxygen(row$DO_mg), code_nutr(row$N_TOTAL), code_temp(row$Temperature))
      div(class="speech-bubble",
          style="position:relative;background:#fff;border:3px solid #333;border-radius:18px;padding:14px 16px;font-size:1.05rem;",
          speech_text(oc),
          tags$div(style="position:absolute; left:15px; bottom:-18px; width:0; height:0;
                        border-left:12px solid transparent;border-right:12px solid transparent;border-top:18px solid #333;"),
          tags$div(style="position:absolute; left:15px; bottom:-14px; width:0; height:0;
                        border-left:10px solid transparent;border-right:10px solid transparent;border-top:14px solid #fff;")
      )
    }
  })
  
  # badges
  output$badges_title <- renderUI({
    if (is.null(input$site) || input$site=="All sites") "Legend — What the colours mean"
    else "Today’s Ocean Health — Traffic Lights"
  })
  
  badge_chip <- function(title, code, value_text=NULL){
    pulse <- switch(code, green="pulse-green", amber="pulse-amber", red="pulse-red", "")
    div(class="badge-chip",
        div(style="font-size:1.6rem;line-height:1;", span(class=pulse, code_to_emoji[code])),
        div(HTML(paste0("<b>",title,":</b> ",
                        "<span style='color:",code_to_color[code],"'>",code_to_label[code],"</span>",
                        if (!is.null(value_text)) paste0(" &nbsp;<span style='opacity:.6'>", value_text, "</span>") else ""))))
  }
  
  output$badges <- renderUI({
    if (is.null(input$site) || input$site=="All sites") {
      div(
        badge_chip("Overall","green","Great for a splash!"),
        badge_chip("Overall","amber","Take care, choose a clear spot."),
        badge_chip("Overall","red","Better to wait for a clearer day.")
      )
    } else {
      row <- current_row(); validate(need(!is.null(row) && nrow(row)==1, "No data."))
      tagList(
        badge_chip("Algal Bloom", code_algae(row$CHL_A),
                   paste0("Chl-a: ", ifelse(is.na(row$CHL_A),"–", sprintf('%.1f µg/L', row$CHL_A)))),
        badge_chip("Clarity", code_clarity(row$Turb),
                   paste0("Turbidity: ", ifelse(is.na(row$Turb),"–", sprintf('%.2f NTU', row$Turb)))),
        badge_chip("Oxygen", code_oxygen(row$DO_mg),
                   paste0("DO: ", ifelse(is.na(row$DO_mg),"–", sprintf('%.1f mg/L', row$DO_mg)))),
        badge_chip("Nutrients", code_nutr(row$N_TOTAL),
                   paste0("Total N: ", ifelse(is.na(row$N_TOTAL),"–", sprintf('%.0f µg/L', row$N_TOTAL)))),
        badge_chip("Temperature", code_temp(row$Temperature),
                   paste0("Temp: ", ifelse(is.na(row$Temperature),"–", sprintf('%.1f °C', row$Temperature))))
      )
    }
  })
  
  # insights
  insight_bullet <- function(emoji, text) {
    div(style="margin:6px 0; display:flex; gap:10px; align-items:flex-start;",
        div(style="font-size:1.2rem; width:1.6rem; text-align:center;", emoji),
        div(class="insight-line", text))
  }
  
  make_insights_single <- function(row, prev){
    codes <- list(
      algae = code_algae(row$CHL_A),
      clar  = code_clarity(row$Turb),
      oxy   = code_oxygen(row$DO_mg),
      nutr  = code_nutr(row$N_TOTAL),
      temp  = code_temp(row$Temperature)
    )
    bullets <- list(
      insight_bullet("👁️",  kidline("Clarity", codes$clar)),
      insight_bullet("🫧",  kidline("Oxygen",  codes$oxy)),
      insight_bullet("🌱",  kidline("Nutrients", codes$nutr)),
      insight_bullet("🧪",  kidline("Algal Bloom", codes$algae)),
      insight_bullet("🌡️", kidline("Temperature", codes$temp))
    )
    if (nrow(prev)==1) {
      t_ntu <- trend_arrow(row$Turb, prev$Turb, TRUE)
      t_chl <- trend_arrow(row$CHL_A, prev$CHL_A, TRUE)
      t_do  <- trend_arrow(row$DO_mg, prev$DO_mg, FALSE)
      t_tn  <- trend_arrow(row$N_TOTAL, prev$N_TOTAL, TRUE)
      t_tc  <- trend_arrow(row$Temperature, prev$Temperature, NA)
      trends <- c(
        if(nchar(t_ntu)) paste0("Clarity: ", t_ntu),
        if(nchar(t_chl)) paste0("Algae: ",   t_chl),
        if(nchar(t_do))  paste0("Oxygen: ",  t_do),
        if(nchar(t_tn))  paste0("Nutrients: ", t_tn),
        if(nchar(t_tc))  paste0("Temp: ",    t_tc)
      )
      if (length(trends)) bullets <- append(bullets, list(
        insight_bullet("📈", paste(trends, collapse = "  •  "))
      ))
    }
    tagList(bullets)
  }
  
  make_insights_all <- function(mdf){
    counts <- table(factor(mdf$overall, levels=c("green","amber","red")))
    best <- mdf %>% arrange(match(overall, c("green","amber","red")), desc(date)) %>% slice_head(n=3)
    tagList(
      insight_bullet("🗺️", paste0("We checked ", nrow(mdf), " beaches today.")),
      insight_bullet("🏅", paste0("Top spots: ", paste(best$site_name_short, collapse=" • "), ".")),
      insight_bullet(code_to_emoji["green"], paste0(counts[["green"]], " places look great for a splash!")),
      insight_bullet(code_to_emoji["amber"], paste0(counts[["amber"]], " places need a little care.")),
      insight_bullet(code_to_emoji["red"],   paste0(counts[["red"]],   " places might be better another day."))
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
  
  # 🎉 CONFETTI when overall rating improves vs previous sample
  observe({
    if (is.null(input$site) || input$site=="All sites") return()
    row  <- current_row(); if (is.null(row) || nrow(row)!=1) return()
    prev <- prev_row(row$site_name_short[1], row$date[1]); if (nrow(prev)!=1) return()
    
    score <- c(green=3, amber=2, red=1)
    now_code  <- overall_code(code_algae(row$CHL_A), code_clarity(row$Turb),
                              code_oxygen(row$DO_mg), code_nutr(row$N_TOTAL), code_temp(row$Temperature))
    prev_code <- overall_code(code_algae(prev$CHL_A), code_clarity(prev$Turb),
                              code_oxygen(prev$DO_mg), code_nutr(prev$N_TOTAL), code_temp(prev$Temperature))
    if (score[[now_code]] > score[[prev_code]]) session$sendCustomMessage("confetti", list(n=140))
  })
}

shinyApp(ui, server)