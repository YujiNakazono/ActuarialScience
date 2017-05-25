# Travelling data
# Source:

# Packages

require(openxlsx)
require(dplyr)
extrafont::loadfonts(device="win")
require(ggplot2)
require(reshape2)
require(ggthemes)

# ColorPaletter
colors <- c("#6ec5e5", "#DA5724", "#74D944", "#CE50CA", "#3F4921", "#C0717C", "#CBD588", "#5F7FC7", 
            "#673770", "#D3D93E", "#38333E", "#508578", "#D7C1B1", "#689030", "#AD6F3B", "#CD9BCD", 
            "#D14285", "#6DDE88", "#652926", "#7FDCC0", "#C84248", "#8569D5", "#5E738F", "#D1A33D", 
            "#8A7C64", "#599861")


# Read in the travel data
fromCanada <- read.xlsx("Travel.xlsx", sheet = "TravelData")

# Clean Up countries
fromCanada <- fromCanada %>%
  mutate(Country = ifelse(Country == "Republic of Ireland" | Country == "Republic Of Ireland" | Country ==  "Ireland, Republic Of", "Ireland",
                          ifelse(Country == "Mainland China", "China", Country)))

# Assign ranking within year
filter(fromCanada, Year == 2002) 

order(x$Visits, x$Country, decreasing = TRUE)

z <- NULL

for (i in c(2001:2015)){
  x <- filter(fromCanada, Year == i) 
  z <- c(z, order(x$Visits, x$Country, decreasing = TRUE))
}

fromCanada$YearRank <- z

# ranking bump chart
ggplot(fromCanada, aes(Year,YearRank, group = Country, color = Country, label = Country)) +
  geom_line(size=1) +
  scale_y_continuous(breaks = c(1:15), trans = "reverse") +
  scale_x_continuous(breaks = c(2001:2015)) +
  theme(legend.position="none") +
  ggtitle("Top 15 Travel Destinations by Canadians") +
  geom_text(data = subset(fromCanada, Year == "2015"), aes(label = Country, x = Year +1.2),
            size =3.5, hjust = 0.60 ) +
  scale_color_manual(values=colors) 

# Look for the most common countries
common <- fromCanada %>%
  group_by(Country) %>% 
  summarize(frequency = n())

# Reorder and change to factor to preseve order
common <- common[order(common$frequency, decreasing = TRUE),]
common$Country <- factor(common$Country, levels = common$Country)

# How often does a country appear
ggplot(common, mapping = aes(Country,frequency)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  theme_hc()


# Visits analysis

# Add missing values to make plot nicer
Visitsnew <-xtabs(Visits~Country+Year, fromCanada) %>%
  as.data.frame() %>%
  transmute(Country, Year, Visits = Freq)

# Raw data analysis, no adjustments
ggplot(Visitsnew, aes(x = Year, y = Visits,group=Country,fill=Country)) +
  geom_area(stat="identity",position = "stack") +
  geom_line(aes(y = Visits),position="stack") +
  scale_fill_manual(values=colors)

# Same plot, filled
ggplot(Visitsnew, aes(x = Year, y = Visits,group=Country,fill=Country)) +
  geom_area(stat="identity",position = "fill") +
  geom_line(aes(y = Visits),position="fill") +
  scale_fill_manual(values=colors)

# Nights analysis

# Add missing values to make plot nicer
Nightsnew <-xtabs(Nights~Country+Year, fromCanada) %>%
  as.data.frame() %>%
  transmute(Country, Year, Nights = Freq)

# Raw data analysis, no adjustments
ggplot(Nightsnew, aes(x = Year, y = Nights,group=Country,fill=Country)) +
  geom_area(stat="identity",position = "stack") +
  geom_line(aes(y = Nights),position="stack") +
  scale_fill_manual(values=colors)

# Same plot, filled
ggplot(Nightsnew, aes(x = Year, y = Nights,group=Country,fill=Country)) +
  geom_area(stat="identity",position = "fill") +
  geom_line(aes(y = Nights),position="fill") +
  scale_fill_manual(values=colors)

# Spent analysis

# Add missing values to make plot nicer
Spent_CDNnew <-xtabs(Spent_CDN~Country+Year, fromCanada) %>%
  as.data.frame() %>%
  transmute(Country, Year, Spent_CDN = Freq)

# Raw data analysis, no adjustments
ggplot(Spent_CDNnew, aes(x = Year, y = Spent_CDN,group=Country,fill=Country)) +
  geom_area(stat="identity",position = "stack") +
  geom_line(aes(y = Spent_CDN),position="stack") +
  scale_fill_manual(values=colors) +
  theme_hc()

# Same plot, filled
ggplot(Spent_CDNnew, aes(x = Year, y = Spent_CDN,group=Country,fill=Country)) +
  geom_area(stat="identity",position = "fill") +
  geom_line(aes(y = Spent_CDN),position="fill") +
  scale_fill_manual(values=colors) +
  theme_hc() +
  ggtitle("test")

# Specific dive into the United States data

US_data <- fromCanada[fromCanada$Country == "United States",]


# Pull in population data to normalize
population <- read.xlsx("Travel.xlsx", sheet = "Population")

latest_pop <- population$Population[population$Year == 2015]

population <- population %>%
  mutate(pop_index = latest_pop/Population)

US_data <- US_data %>%
  left_join(select(population,c(Year,pop_index)), by = "Year") 
  
US_data <- mutate(US_data,Visits_level = Visits * pop_index)


# Plot of Canadians Visits to US
ggplot(US_data,aes(x = Year, y = Visits)) +
  ggtitle("Visits to the United States by Canadians, with Population Adjustment") +
  geom_text(data = subset(US_data, Year == "2007"), aes(label = "Unadjusted", x = Year, y = 16000),fontface = "bold") +
  geom_line(color = "blue",size = 1) +
  geom_line(aes(y = Visits_level, color = "red"),size=1) +
  theme_hc() +
  geom_text(data = subset(US_data, Year == "2004"), aes(label = "Adjusted", x = Year, y = 16500),fontface = "bold") +
  geom_vline(xintercept = 2008.75, linetype = 2) +
  geom_vline(xintercept = 2013.25, linetype = 2) +
  geom_vline(xintercept = 2015, linetype = 2) +
  geom_text(aes(label = "Start of Recession ➡", x = 2007.7, y = 23000), family = "serif",color = "purple", size = 5) +
  geom_text(aes(label = "Last Point CDN at\n Par with USD ➡", x = 2012.2, y = 16500), family = "serif",color = "purple", size = 5) +
  geom_text(aes(label = "$1.00 USD = \n $0.75 CDN ➡", x = 2014.2 ,y = 14000), family = "serif",color = "purple", size = 5,) +
    scale_x_continuous(breaks = c(2001:2015)) +
  theme(legend.position="none") 
  
