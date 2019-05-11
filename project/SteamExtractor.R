library(XML)
library(httr)
library(rvest)
library(ggplot2)
library(stringr)
library(RSelenium)
library(dplyr)
library(wdman)
library(RSQLite)

#setwd("../../Documents/WebMiningProject/project")
#shell.exec(paste0("C:/Users/ozank/Documents/WebMiningProject/project/work.bat"))
driver <- rsDriver(version = "3.11.0", verbose = FALSE)
maindataframe <- data.frame()

page_number <- seq(0, 10, by=1)
for (i in page_number){
  print(i)


editedGames <- 1

url <- paste0("https://store.steampowered.com/search/?category1=998&page=",paste0(i))
webpage <- read_html(url)

games <- data.frame(matrix(ncol = 22, nrow = 1))
specs = c(
  "id",
  "title",
  "release_date",
  "developer",
  "publisher",
  "short_desc",
  "system_req",
  "description",
  "image",
  "genres",
  "similar_games",
  "base_price",
  "discount_ratio",
  "sale_price",
  "lowest_prize",
  "review_ratio",
  "windows_OS",
  "mac_OS",
  "linux_OS",
  "discount_bool",
  "specs",
  "metacritic_score"
)
colnames(games) <-  specs
emptyone <- games

gameurl <- webpage %>% html_nodes("*") %>%                        #getting gaem URLs
  html_nodes(xpath = "./a") %>%
  html_attr("href")
gameurl <- gameurl[132:156]
gameprice <- list()
gameprice <- webpage %>%
  html_nodes(".col, .search_price,  .responsive_secondrow") %>%
  html_text()

gameprice <- gsub('[\r\n\t]', '', gameprice)
gameprice <- gameprice[2:length(gameprice)]
gameprice[sapply(gameprice, is.null)] <- NULL

gamelist <- list()
tmp <-  1
index <-  1
for (i in gameprice) {
  if (tmp == 1 | tmp == 2 | tmp == 5 | tmp == 6) {
    gamelist[index] <- paste (gamelist[index], "£")
    gamelist[index] <- paste (gamelist[index] , i)
  }
  if (tmp == 7) {
    tmp <-  0
    index <- index + 1
  }
  tmp <- tmp + 1
}
gamelist[sapply(gamelist, is.null)] <- NULL

for (i in gamelist) {
  rown <- nrow(games) + 1
  line <- unlist(strsplit(i, '£'))
  emptyone$title <- line[2]
  emptyone$release_date <- line[3]
  emptyone$discount_ratio <- line[4]
  emptyone$discount_bool <- ifelse(nchar(line[4]) == 2 , FALSE ,TRUE)
  temp <- (unlist(strsplit(line[5], 'TL')))
  emptyone$base_price <- temp[1]
  emptyone$sale_price <- temp[2]
  games <- rbind(games, emptyone)
}
games <- games[2:nrow(games),]
rownames(games) <- c(1:nrow(games))


for (i in gameurl) {
  game_page <- read_html(i)
  splittedURL <- unlist(strsplit(i, '/'))
  games[editedGames, 1] <- splittedURL[5]
  game_title <- html_nodes(game_page, '.apphub_AppName') %>% html_text()
  
  
  remDr <- driver[["client"]]
  remDr$open()
  elem <- remDr$navigate(i) # open web browser
  if (length(game_title) == 0) {

    out <- tryCatch({
      remDr$findElement(using = "class", value = "btn_grey_white_innerfade")$clickElement()
      games[editedGames, 7] <- remDr$findElement(using = "class", value = 'sys_req')$getElementText()     #passing NSFW check
    },
    error = function(cond) {
      message(paste("Searched item is not exist in this url :", i))
      message("Here's the original error message:")
      message(cond)
      message("Trying a different method")
      
      elem <- remDr$findElement(using = "id", "ageYear")
      elem$sendKeysToElement(list("1940"))
      remDr$findElement(using = "class", value = "btnv6_blue_hoverfade")$clickElement()                   #passing age check
    })
  }
  else
  {
    games[editedGames, 7]<- html_nodes(game_page, '.sys_req') %>% html_text()
    games[editedGames, 8]<- html_nodes(game_page, '#game_area_description') %>% html_text()
    
  }
  
  URL4 <- GET(paste0("https://store.steampowered.com/recommended/morelike/app/",paste0(games[editedGames,1]), sep=""))
  recommend_page <- read_html(URL4)
  
  recommend <- recommend_page %>%
    html_nodes("*") %>% 
    html_nodes(xpath = "./a") %>%
    html_attr("href")
  recommend <- unlist(recommend[107:129])
  recommend <- unlist(strsplit(recommend,"/"))
  recommend <- paste(recommend[5],recommend[20],recommend[35],recommend[50],
                     recommend[65],recommend[80],recommend[95],recommend[110],
                     recommend[125],recommend[140],recommend[155],recommend[170])
  games[editedGames,11] <- recommend
  

  games[editedGames,7] <- remDr$findElement(using = "class", value = 'sys_req')$getElementText()
  games[editedGames,8] <- remDr$findElement(using = "id", value = 'game_area_description')$getElementText()
  
  URL2 <- GET(paste0("https://steamdb.info/app/",paste0(games[editedGames,1]), sep=""))
  temp <- readHTMLTable(rawToChar(URL2$content),which=2)
  temp <- (unlist(strsplit(paste(temp[14,6])," ")))
  temp <- substring(temp[[1]], 2)
  games[editedGames,15] <- ifelse(length(temp) < 1,"Free to Play", temp)
  
  URL2 <- GET(paste0("https://steamdb.info/app/",paste0(games[editedGames,1]), sep=""))
  temp <- readHTMLTable(rawToChar(URL2$content),which=1)
  dev <- unlist(temp[match("Developer",temp$V1),])
  pub <- unlist(temp[match("Publisher",temp$V1),])
  release_date <- unlist(temp[match("Release Date",temp$V1),])
  

  OS <- read_html(URL2)
  OSlist <- OS %>%
    html_nodes("*") %>% 
    html_nodes(xpath = "./i") %>%
    html_attr("aria-label")
  
  OSlist <- (strsplit(unique(OSlist), "\t"))
  OSlist <- OSlist[2:length(OSlist)]
  
  URL3 <- GET(paste0("https://steamdb.info/app/",paste0(games[editedGames,1]), sep=""))
  spec <- read_html(URL2)
  speclist <- spec %>%
    html_nodes("*") %>% 
    html_nodes(xpath = "./a") %>%
    html_attr("aria-label")
  
  
  speclist <- (strsplit(unique(speclist), "\t"))
  speclist <- speclist[9:length(speclist)]
  templist <- ""
  for (i in speclist){
    if (i == "Permanent link"){
      break
    }
    templist <- paste(templist,i,",")
  }
  templist <- substr(templist,1,nchar(templist)-1)
  paste0(templist)

  rew_ratio <- read_html(URL2)
  rew_ratio_text <- rew_ratio %>%
    html_nodes("*") %>% 
    html_nodes(xpath = "./span") %>%
    html_attr("aria-label")
  
  img <- read_html(URL2)
  img_url <- img %>%
    html_nodes("*") %>% 
    html_nodes(xpath = "./img") %>%
    html_attr("src")
  img_url <- img_url[4]
  
  URL3 <- GET(paste0("https://steamdb.info/app/", paste0(games[editedGames,1]),"/info"))
  

  infos <- read_html(URL3)
  info_table <- html_nodes(infos, '#info') %>% html_text()
  info_table <- unlist(strsplit(info_table, "\n"))
  
  games[editedGames,22] <- ifelse( length(which(info_table == "metacritic_score")) < 1, "No Metacritic Score", info_table[which(info_table == "metacritic_score")+ 1])
  games[editedGames,10] <-  info_table[which(info_table == "Genres")+ 1]
  
  
  rew_ratio_text <- (strsplit(unique(rew_ratio_text), "\t"))
  games[editedGames,16] <- paste(rew_ratio_text[2])
  
  short_des<- read_html(URL2)
  short_des_temp <- html_nodes(short_des, '.header-description') %>% html_text()
  games[editedGames,6] <- ifelse(length(short_des_temp) == 0,NA,short_des_temp)
  
  
  
  games[editedGames,4] <- paste(dev[2])
  games[editedGames,5] <- paste(pub[2])
  games[editedGames,9] <- paste(img_url)
  games[editedGames,17] <- ifelse(OSlist[1] == "Windows",TRUE,FALSE)
  games[editedGames,18] <- ifelse(OSlist[2] == "macOS",TRUE,FALSE)
  games[editedGames,19] <- ifelse(OSlist[3] == "Linux",TRUE,FALSE)
  games[editedGames,21] <- paste(templist)
  
  
  
  
  remDr$close()
  editedGames <- editedGames + 1
}
maindataframe <- rbind(maindataframe , games)
}
yedek <- maindataframe
maindataframe[,8] <- gsub("\r?\n|\r", " ", maindataframe[,8])
maindataframe[,7] <- gsub("\r?\n|\r", " ", maindataframe[,7])
write.csv2(maindataframe,'gamedata.csv')

#plotting

library(plotly)


countsWin <- table(maindataframe$windows_OS)            # # of playable on windows
barplot(counts, main="Playable games on Windows ")  
dev.copy(png,'windows.png')
dev.off()

countsLinux <- table(maindataframe$linux_OS)            # # of playable on linux
barplot(countsLinux, main="Playable games on Linux ") 
dev.copy(png,'linux.png')
dev.off()

countsMac <- table(maindataframe$mac_OS)                # # of playable on mac
barplot(countsMac, main = "Playable games on MacOS")
dev.copy(png,'mac.png')
dev.off()

countDiscount <- table(maindataframe$discount_bool)     # # of discounted games
barplot(countDiscount, main = "Is it on Sale?")
dev.copy(png,'sale.png')
dev.off()

countsCritic <- table(maindataframe$metacritic_score == "No Metacritic Score") # # of games without metacritic value
a <- barplot(countsCritic, main="Games without a metacritic rating")
dev.copy(png,'metacritic.png')
dev.off()

countsCritic <- table(maindataframe$base_price == " Free to Play") # # of games without metacritic value
a <- barplot(countsCritic, main="Free to Play games")
dev.copy(png,'freegames.png')
dev.off()
