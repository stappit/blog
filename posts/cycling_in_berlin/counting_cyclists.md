---
always_allow_html: True
author: Brian Callander
date: '2018-11-29'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: 'berlin, cycling, open data, eda, timeseries, excel'
title: Counting cyclists in Berlin
tldr: |
    This is an exploratory data analysis of Berlin open data on bike
    counters around the city. There are strong commuter effects at hour of
    the day, also when looking at the differences of paired counters. There
    is yearly seasonality, with a peak in the summer and trough in the
    winter. There is no obvious change in traffic over the years.
---

I recently found out that berlin has a bunch of automatic bike-counters
around berlin...and the [data is
public](https://daten.berlin.de/datensaetze/radz%C3%A4hldaten-berlin)!
There's even an [interactive
map](https://www.berlin.de/senuvk/verkehr/lenkung/vlb/de/karte.shtml) of
the stations. This is all pretty awesome. Although the data is stored in
multiple sheets of an excel file (\#?&!!), I thought it'd be an
interesting exercise to clean it up and see how useful it could be for
other projects.

<!--more-->
![An induction-loop bike-counter](radzaehler_620.jpg)

<div style="display:none">

$\DeclareMathOperator{\dbinomial}{Binomial}  \DeclareMathOperator{\dbern}{Bernoulli}  \DeclareMathOperator{\dpois}{Poisson}  \DeclareMathOperator{\dnorm}{Normal}  \DeclareMathOperator{\dt}{t}  \DeclareMathOperator{\dcauchy}{Cauchy}  \DeclareMathOperator{\dexponential}{Exp}  \DeclareMathOperator{\duniform}{Uniform}  \DeclareMathOperator{\dgamma}{Gamma}  \DeclareMathOperator{\dinvgamma}{InvGamma}  \DeclareMathOperator{\invlogit}{InvLogit}  \DeclareMathOperator{\logit}{Logit}  \DeclareMathOperator{\ddirichlet}{Dirichlet}  \DeclareMathOperator{\dbeta}{Beta}$

</div>

Get the data
------------

Let's grab the data.

``` {.r}
filename <- 'cyclist_counts.xlsx'
url <- "https://www.berlin.de/senuvk/verkehr/lenkung/vlb/download/radzaehlung/Gesamtdatei_Stundenwerte_2014_2017.xlsx"

if (!file.exists(filename))
  download.file(url, filename, 'libcurl')
```

It's probably a good idea to [take a look at the excel
file](https://www.berlin.de/senuvk/verkehr/lenkung/vlb/download/radzaehlung/Gesamtdatei_Stundenwerte_2014_2017.xlsx)
so that it's easier to follow along with the code below. You can also
[open up the R markdown](./counting_cyclists.Rmd) in RStudio.

Unfortunately, there's no official checksum provided to guarantee the
data were downloaded correctly, but I can show you what my checksum is.

``` {.r}
digest::digest(filename, algo = 'md5', file = TRUE)
```

    [1] "e79c4ea5b5e1437d90a7d06f572f741e"

If you get a different md5 checksum, then you don't have the same file
as I do.

The counters
------------

The first sheet `Hinweise` (= advice) is mostly text describing some
general information about the data. The notable parts tell us that it is
the uneditted data from the counter systems and is published at the end
of the counting-year. What's a `counting-year`? Good question; no idea.
The excel file was last modified on the 20th of April 2018, so I guess
the next update will probably be around April 2019.

There are also some disclaimers basically telling us that the counters
don't necessarily give an exact count due to weather conditions,
maintainance, and other complications. This is described in more detail
on the [FAQ
page](https://www.berlin.de/senuvk/verkehr/lenkung/vlb/de/radzaehlungen_faq.shtml)
(in German). They work using an [induction
loop](https://en.wikipedia.org/wiki/Induction_loop), which detects a
metal object moving passed. Full carbon bikes are not countable but
there are likely so few that the difference is absorbed in the
measurement error anyway. Apparently bikes with more or less than two
wheels can also cause miscounts. However, groups of bikes can be counted
accurately so long as they don't ride too closely side-by-side.

The [FAQ
page](https://www.berlin.de/senuvk/verkehr/lenkung/vlb/de/radzaehlungen_faq.shtml)
also tells us that some counters are set up in pairs in order to count
the two directions of traffic separately. Well see how to detect these
pairs when we inspect the data.

The first data sheet, `Standortdaten` = location data, lists the
counters with a unique ID, a street name, lattitude-longitude (not shown
here), and installation date.

``` {.r}
counters <- filename %>% 
  readxl::read_excel(sheet = 'Standortdaten') %>% 
  transmute(
    id = `Zähler` %>% as_factor(),
    pair = str_replace(id, '-[NSOW]$', '') %>% as_factor(),
    location = `Beschreibung - Fahrtrichtung`,
    installation_date = as.Date(Installationsdatum)
  ) %>% 
  arrange(installation_date, location) %>% 
  write_csv('counters.csv')

n_counters <- counters %>% distinct(id) %>% nrow()
```

There are 26 counters listed in the sheet. I have seen it written that
there are only 17, but I this number doesn't count the paired counters
as separate. The pairs are listed as north/south or east/west (in
German), with the last letter of the ID indicating the direction. This
allows us to identify the pair by removing the last character of the ID.

<table class="table table-hover table-striped table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
The counter locations
</caption>
<thead>
<tr>
<th style="text-align:left;">
id
</th>
<th style="text-align:left;">
pair
</th>
<th style="text-align:left;">
location
</th>
<th style="text-align:left;">
installation\_date
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
12-PA-SCH
</td>
<td style="text-align:left;">
12-PA-SCH
</td>
<td style="text-align:left;">
Schwedter Steg
</td>
<td style="text-align:left;">
2012-03-01
</td>
</tr>
<tr>
<td style="text-align:left;">
02-MI-JAN-N
</td>
<td style="text-align:left;">
02-MI-JAN
</td>
<td style="text-align:left;">
Jannowitzbrücke Nord
</td>
<td style="text-align:left;">
2015-04-01
</td>
</tr>
<tr>
<td style="text-align:left;">
02-MI-JAN-S
</td>
<td style="text-align:left;">
02-MI-JAN
</td>
<td style="text-align:left;">
Jannowitzbrücke Süd
</td>
<td style="text-align:left;">
2015-04-01
</td>
</tr>
<tr>
<td style="text-align:left;">
13-CW-PRI
</td>
<td style="text-align:left;">
13-CW-PRI
</td>
<td style="text-align:left;">
Prinzregentenstraße
</td>
<td style="text-align:left;">
2015-04-01
</td>
</tr>
<tr>
<td style="text-align:left;">
18-TS-YOR-O
</td>
<td style="text-align:left;">
18-TS-YOR
</td>
<td style="text-align:left;">
Yorckstraße Ost
</td>
<td style="text-align:left;">
2015-04-01
</td>
</tr>
<tr>
<td style="text-align:left;">
18-TS-YOR-W
</td>
<td style="text-align:left;">
18-TS-YOR
</td>
<td style="text-align:left;">
Yorkstraße West
</td>
<td style="text-align:left;">
2015-04-01
</td>
</tr>
<tr>
<td style="text-align:left;">
27-RE-MAR
</td>
<td style="text-align:left;">
27-RE-MAR
</td>
<td style="text-align:left;">
Markstraße
</td>
<td style="text-align:left;">
2015-05-01
</td>
</tr>
<tr>
<td style="text-align:left;">
19-TS-MON
</td>
<td style="text-align:left;">
19-TS-MON
</td>
<td style="text-align:left;">
Monumentenstraße
</td>
<td style="text-align:left;">
2015-05-01
</td>
</tr>
<tr>
<td style="text-align:left;">
03-MI-SAN-O
</td>
<td style="text-align:left;">
03-MI-SAN
</td>
<td style="text-align:left;">
Invalidenstraße Ost
</td>
<td style="text-align:left;">
2015-06-01
</td>
</tr>
<tr>
<td style="text-align:left;">
03-MI-SAN-W
</td>
<td style="text-align:left;">
03-MI-SAN
</td>
<td style="text-align:left;">
Invalidenstraße West
</td>
<td style="text-align:left;">
2015-06-01
</td>
</tr>
<tr>
<td style="text-align:left;">
05-FK-OBB-O
</td>
<td style="text-align:left;">
05-FK-OBB
</td>
<td style="text-align:left;">
Oberbaumbrücke Ost
</td>
<td style="text-align:left;">
2015-06-01
</td>
</tr>
<tr>
<td style="text-align:left;">
05-FK-OBB-W
</td>
<td style="text-align:left;">
05-FK-OBB
</td>
<td style="text-align:left;">
Oberbaumbrücke West
</td>
<td style="text-align:left;">
2015-06-01
</td>
</tr>
<tr>
<td style="text-align:left;">
26-LI-PUP
</td>
<td style="text-align:left;">
26-LI-PUP
</td>
<td style="text-align:left;">
Paul-und-Paula-Uferweg
</td>
<td style="text-align:left;">
2015-06-01
</td>
</tr>
<tr>
<td style="text-align:left;">
24-MH-ALB
</td>
<td style="text-align:left;">
24-MH-ALB
</td>
<td style="text-align:left;">
Alberichstraße
</td>
<td style="text-align:left;">
2015-07-01
</td>
</tr>
<tr>
<td style="text-align:left;">
10-PA-BER-N
</td>
<td style="text-align:left;">
10-PA-BER
</td>
<td style="text-align:left;">
Berliner Straße Nord
</td>
<td style="text-align:left;">
2016-05-01
</td>
</tr>
<tr>
<td style="text-align:left;">
10-PA-BER-S
</td>
<td style="text-align:left;">
10-PA-BER
</td>
<td style="text-align:left;">
Berliner Straße Süd
</td>
<td style="text-align:left;">
2016-05-01
</td>
</tr>
<tr>
<td style="text-align:left;">
17-SK-BRE-O
</td>
<td style="text-align:left;">
17-SK-BRE
</td>
<td style="text-align:left;">
Breitenbachplatz Ost
</td>
<td style="text-align:left;">
2016-05-01
</td>
</tr>
<tr>
<td style="text-align:left;">
17-SK-BRE-W
</td>
<td style="text-align:left;">
17-SK-BRE
</td>
<td style="text-align:left;">
Breitenbachplatz West
</td>
<td style="text-align:left;">
2016-05-01
</td>
</tr>
<tr>
<td style="text-align:left;">
23-TK-KAI
</td>
<td style="text-align:left;">
23-TK-KAI
</td>
<td style="text-align:left;">
Kaisersteg
</td>
<td style="text-align:left;">
2016-05-01
</td>
</tr>
<tr>
<td style="text-align:left;">
15-SP-KLO-S
</td>
<td style="text-align:left;">
15-SP-KLO
</td>
<td style="text-align:left;">
Klosterstraße Süd
</td>
<td style="text-align:left;">
2016-05-01
</td>
</tr>
<tr>
<td style="text-align:left;">
20-TS-MAR-N
</td>
<td style="text-align:left;">
20-TS-MAR
</td>
<td style="text-align:left;">
Mariendorfer Damm Nord
</td>
<td style="text-align:left;">
2016-05-01
</td>
</tr>
<tr>
<td style="text-align:left;">
20-TS-MAR-S
</td>
<td style="text-align:left;">
20-TS-MAR
</td>
<td style="text-align:left;">
Mariendorfer Damm Süd
</td>
<td style="text-align:left;">
2016-05-01
</td>
</tr>
<tr>
<td style="text-align:left;">
21-NK-MAY
</td>
<td style="text-align:left;">
21-NK-MAY
</td>
<td style="text-align:left;">
Maybachufer
</td>
<td style="text-align:left;">
2016-05-01
</td>
</tr>
<tr>
<td style="text-align:left;">
06-FK-FRA-O
</td>
<td style="text-align:left;">
06-FK-FRA
</td>
<td style="text-align:left;">
Frankfurter Allee Ost
</td>
<td style="text-align:left;">
2016-06-01
</td>
</tr>
<tr>
<td style="text-align:left;">
06-FK-FRA-W
</td>
<td style="text-align:left;">
06-FK-FRA
</td>
<td style="text-align:left;">
Frankfurter Allee West
</td>
<td style="text-align:left;">
2016-06-01
</td>
</tr>
<tr>
<td style="text-align:left;">
15-SP-KLO-N
</td>
<td style="text-align:left;">
15-SP-KLO
</td>
<td style="text-align:left;">
Klosterstraße Nord
</td>
<td style="text-align:left;">
2016-06-01
</td>
</tr>
</tbody>
</table>
I'm not sure what the numbers in the ID are, but the first group of
letters is an abbreviation of the district (Mitte, Pankow, etc), the
second group is an abbreviation of the street name, and the third group
(where it exists) is the direction of traffic (north, south, east,
west).

Take a deep breath
------------------

Now for the data we came here for. As of this writing, there are 6
sheets, one for each year from 2012 to 2017.

``` {.r}
years <- 2012:2017
```

The corresponding sheets are called `Jahresdatei YYYY` (= year data).

``` {.r}
sheets0 <- years %>% 
  as.character() %>% 
  paste0('Jahresdatei ', .) 

sheets0
```

    [1] "Jahresdatei 2012" "Jahresdatei 2013" "Jahresdatei 2014"
    [4] "Jahresdatei 2015" "Jahresdatei 2016" "Jahresdatei 2017"

Let's turn that into a named list so that it works well with the
`map_dfr` function below.

``` {.r}
sheets <- sheets0 %>% 
  as.list() %>% 
  set_names(., .) 
```

The `read_excel` function isn't as flexible as its `read_csv` cousin so
we'll write a wrapper for loading the data from a particular sheet.

``` {.r}
read_excel <- function(sheet, .filename=filename, .n=n_counters) {
  readxl::read_excel(
    .filename, 
    sheet = sheet, 
    col_types = c('date', rep('numeric', .n))
  ) 
}
```

Now we can simply map that function over all of our sheet names to get a
dataframe from each sheet, then bind the rows of these dataframes
together so that we have all the data together. The columns also have
awkward headers, so we'll rename them to the counter ID.

``` {.r}
df_untidy <- sheets %>% 
  map_dfr(read_excel, .id = 'sheet') %>% 
  
  # get rid of redundant info in the col names
  # and use english names
  set_names(names(.) %>% str_replace_all(" .*", "")) %>% 
  rename(measured_at = Zählstelle)
```

<table class="table table-hover table-striped table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
Example of untidy output. Only the counters in Mitte are shown.
</caption>
<thead>
<tr>
<th style="text-align:left;">
sheet
</th>
<th style="text-align:left;">
measured\_at
</th>
<th style="text-align:right;">
02-MI-JAN-N
</th>
<th style="text-align:right;">
02-MI-JAN-S
</th>
<th style="text-align:right;">
03-MI-SAN-O
</th>
<th style="text-align:right;">
03-MI-SAN-W
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Jahresdatei 2017
</td>
<td style="text-align:left;">
2017-12-31 19:00:00
</td>
<td style="text-align:right;">
29
</td>
<td style="text-align:right;">
29
</td>
<td style="text-align:right;">
19
</td>
<td style="text-align:right;">
14
</td>
</tr>
<tr>
<td style="text-align:left;">
Jahresdatei 2017
</td>
<td style="text-align:left;">
2017-12-31 20:00:00
</td>
<td style="text-align:right;">
31
</td>
<td style="text-align:right;">
22
</td>
<td style="text-align:right;">
16
</td>
<td style="text-align:right;">
15
</td>
</tr>
<tr>
<td style="text-align:left;">
Jahresdatei 2017
</td>
<td style="text-align:left;">
2017-12-31 21:00:00
</td>
<td style="text-align:right;">
21
</td>
<td style="text-align:right;">
18
</td>
<td style="text-align:right;">
11
</td>
<td style="text-align:right;">
5
</td>
</tr>
<tr>
<td style="text-align:left;">
Jahresdatei 2017
</td>
<td style="text-align:left;">
2017-12-31 22:00:00
</td>
<td style="text-align:right;">
11
</td>
<td style="text-align:right;">
18
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
10
</td>
</tr>
<tr>
<td style="text-align:left;">
Jahresdatei 2017
</td>
<td style="text-align:left;">
2017-12-31 23:00:00
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
20
</td>
</tr>
</tbody>
</table>
All that remains is to [tidy up the
data](http://vita.had.co.nz/papers/tidy-data.html):

1.  Each variable forms a column: we have the ID of the counter, the
    hour of measurement, and the actual measurement.
2.  Each observation forms a row: every hourly measurement should have
    exactly one row.
3.  Each type of observational unit forms a table: there's only the
    hourly count.

The untidy data has a possible measurement for every counter, so we'll
need to gather those columns together. The nulls exists only because of
the untidy format used - we can simply drop them.

``` {.r}
df_tidy <- df_untidy %>% 
  gather(counter_id, total, -measured_at, -sheet) %>% 
  filter(!is.na(total)) %>% 
  mutate(counter_id = counter_id %>% factor(levels = levels(counters$id))) 
```

<table class="table table-hover table-striped table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
Example of tidy output.
</caption>
<thead>
<tr>
<th style="text-align:left;">
sheet
</th>
<th style="text-align:left;">
measured\_at
</th>
<th style="text-align:left;">
counter\_id
</th>
<th style="text-align:right;">
total
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Jahresdatei 2017
</td>
<td style="text-align:left;">
2017-12-31 18:00:00
</td>
<td style="text-align:left;">
27-RE-MAR
</td>
<td style="text-align:right;">
13
</td>
</tr>
<tr>
<td style="text-align:left;">
Jahresdatei 2017
</td>
<td style="text-align:left;">
2017-12-31 19:00:00
</td>
<td style="text-align:left;">
27-RE-MAR
</td>
<td style="text-align:right;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
Jahresdatei 2017
</td>
<td style="text-align:left;">
2017-12-31 20:00:00
</td>
<td style="text-align:left;">
27-RE-MAR
</td>
<td style="text-align:right;">
5
</td>
</tr>
<tr>
<td style="text-align:left;">
Jahresdatei 2017
</td>
<td style="text-align:left;">
2017-12-31 21:00:00
</td>
<td style="text-align:left;">
27-RE-MAR
</td>
<td style="text-align:right;">
2
</td>
</tr>
<tr>
<td style="text-align:left;">
Jahresdatei 2017
</td>
<td style="text-align:left;">
2017-12-31 22:00:00
</td>
<td style="text-align:left;">
27-RE-MAR
</td>
<td style="text-align:right;">
2
</td>
</tr>
<tr>
<td style="text-align:left;">
Jahresdatei 2017
</td>
<td style="text-align:left;">
2017-12-31 23:00:00
</td>
<td style="text-align:left;">
27-RE-MAR
</td>
<td style="text-align:right;">
4
</td>
</tr>
</tbody>
</table>
After performing some checks, I realised there are a lot of duplicated
data. In particular, `Jahresdatei 2012` also contains a complete copy of
`Jahresdatei 2013`. Let's get rid of the duplicates. Whilst we're at it,
we'll add in some extra info about each counter by joining on the
counter dataframe.

``` {.r}
df <- df_tidy %>% 
  distinct(counter_id, measured_at, .keep_all = TRUE) %>% 
  # add a unique row id
  ungroup() %>% 
  arrange(counter_id, measured_at) %>% 
  mutate(id = 1:n()) %>% 
  
  # other helpful stuff
  # reorder columns
  select(id, sheet, counter_id, measured_at, total) %>% 
  # save the data
  write_csv('counter_data.csv') %>% 
  # add counter info
  inner_join(counters, by = c('counter_id' = 'id')) %>% 
  arrange(id)
```

This leaves us with a total of 526,790 measurements.

I'll use the `stopifnot` function to list a bunch of properties that I
know the data must satisfy if it is correct. This prevents this notebook
from compiling if any of them have an entry that doesn't evaluate to
`TRUE`.

``` {.r}
stopifnot(
  # all counts non-negative
  df$total >= 0, 
  
  # measurments occur after installation
  df$measured_at >= df$installation_date, 
  
  # measurements occur within the time range
  year(df$measured_at) <= max(years),
  year(df$measured_at) >= min(years),
  
  # installations occur within the time range
  year(df$installation_date) <= max(years),
  year(df$installation_date) >= min(years),
  
  # there are as many row ids as rows
  max(df$id) == nrow(df),
  
  # at most as many measurements as hours in the year 
  df %>% 
    group_by(counter_id, year = year(measured_at)) %>% 
    count() %>% 
    transmute(8760 + if_else(year %% 4 == 0, 24, 0) - n >= 0) %>% 
    pull(),
  
  # exactly 26 counters
  n_counters == df %>% 
    distinct(counter_id) %>% 
    nrow()
)
```

Exploring the data
------------------

In principle there should be one measurement per counter per hour,
starting from when each counter is installed. Let's check how many gaps
appear in the data.

``` {.r}
gaps <- df %>% 
  group_by(counter_id) %>% 
  mutate(
    next_measurement = lead(measured_at),
    difference = next_measurement - measured_at
  ) %>% 
  filter(difference > 1) %>% 
  select(id, counter_id, difference, measured_at, next_measurement)
```

<table class="table table-hover table-striped table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
Gaps in measurment records.
</caption>
<thead>
<tr>
<th style="text-align:right;">
id
</th>
<th style="text-align:left;">
counter\_id
</th>
<th style="text-align:left;">
difference
</th>
<th style="text-align:left;">
measured\_at
</th>
<th style="text-align:left;">
next\_measurement
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
578
</td>
<td style="text-align:left;">
12-PA-SCH
</td>
<td style="text-align:left;">
2 hours
</td>
<td style="text-align:left;">
2012-03-25 01:00:00
</td>
<td style="text-align:left;">
2012-03-25 03:00:00
</td>
</tr>
<tr>
<td style="text-align:right;">
580
</td>
<td style="text-align:left;">
12-PA-SCH
</td>
<td style="text-align:left;">
2 hours
</td>
<td style="text-align:left;">
2012-03-25 04:00:00
</td>
<td style="text-align:left;">
2012-03-25 06:00:00
</td>
</tr>
<tr>
<td style="text-align:right;">
103630
</td>
<td style="text-align:left;">
13-CW-PRI
</td>
<td style="text-align:left;">
16 hours
</td>
<td style="text-align:left;">
2015-09-21 23:00:00
</td>
<td style="text-align:left;">
2015-09-22 15:00:00
</td>
</tr>
<tr>
<td style="text-align:right;">
146616
</td>
<td style="text-align:left;">
18-TS-YOR-O
</td>
<td style="text-align:left;">
13 hours
</td>
<td style="text-align:left;">
2017-11-15 16:00:00
</td>
<td style="text-align:left;">
2017-11-16 05:00:00
</td>
</tr>
<tr>
<td style="text-align:right;">
354380
</td>
<td style="text-align:left;">
10-PA-BER-N
</td>
<td style="text-align:left;">
4 hours
</td>
<td style="text-align:left;">
2016-05-14 00:00:00
</td>
<td style="text-align:left;">
2016-05-14 04:00:00
</td>
</tr>
<tr>
<td style="text-align:right;">
356679
</td>
<td style="text-align:left;">
10-PA-BER-N
</td>
<td style="text-align:left;">
6 hours
</td>
<td style="text-align:left;">
2016-08-17 22:00:00
</td>
<td style="text-align:left;">
2016-08-18 04:00:00
</td>
</tr>
<tr>
<td style="text-align:right;">
408515
</td>
<td style="text-align:left;">
15-SP-KLO-N
</td>
<td style="text-align:left;">
16 hours
</td>
<td style="text-align:left;">
2017-08-13 23:00:00
</td>
<td style="text-align:left;">
2017-08-14 15:00:00
</td>
</tr>
<tr>
<td style="text-align:right;">
414641
</td>
<td style="text-align:left;">
17-SK-BRE-O
</td>
<td style="text-align:left;">
8 hours
</td>
<td style="text-align:left;">
2016-08-24 20:00:00
</td>
<td style="text-align:left;">
2016-08-25 04:00:00
</td>
</tr>
<tr>
<td style="text-align:right;">
426976
</td>
<td style="text-align:left;">
17-SK-BRE-W
</td>
<td style="text-align:left;">
2 hours
</td>
<td style="text-align:left;">
2016-05-21 02:00:00
</td>
<td style="text-align:left;">
2016-05-21 04:00:00
</td>
</tr>
<tr>
<td style="text-align:right;">
466572
</td>
<td style="text-align:left;">
20-TS-MAR-S
</td>
<td style="text-align:left;">
485 hours
</td>
<td style="text-align:left;">
2017-07-24 23:00:00
</td>
<td style="text-align:left;">
2017-08-14 04:00:00
</td>
</tr>
<tr>
<td style="text-align:right;">
494816
</td>
<td style="text-align:left;">
23-TK-KAI
</td>
<td style="text-align:left;">
198 hours
</td>
<td style="text-align:left;">
2017-07-01 23:00:00
</td>
<td style="text-align:left;">
2017-07-10 05:00:00
</td>
</tr>
<tr>
<td style="text-align:right;">
494859
</td>
<td style="text-align:left;">
23-TK-KAI
</td>
<td style="text-align:left;">
14 hours
</td>
<td style="text-align:left;">
2017-07-11 23:00:00
</td>
<td style="text-align:left;">
2017-07-12 13:00:00
</td>
</tr>
</tbody>
</table>
There are only 12 gaps, and all but two are resolved fairly quickly. I'm
not sure what caused the two larger gaps.

Some counters are in higher traffic locations than others. Note that the
larger the median is, the larger the interquartile range is too. This
happens in almost all of the plots.

``` {.r}
by_counter <- df %>% 
  group_by(counter_id) %>% 
  summarise(
    q25 = quantile(total, 0.25),
    q50 = quantile(total, 0.50),
    q75 = quantile(total, 0.75)
  ) 
```

![Counts by
counter](counting_cyclists_files/figure-markdown/by_counter_plot-1..svg)

There is also a commuter-effect, with peaks showing at 08:00 and 17:00.
There is almost no traffic in the wee hours of the morning.

``` {.r}
by_hour <- df %>% 
  group_by(h = hour(measured_at)) %>% 
  summarise(
    q25 = quantile(total, 0.25),
    q50 = quantile(total, 0.50),
    q75 = quantile(total, 0.75)
  ) 
```

![Counts by hour of the
day](counting_cyclists_files/figure-markdown/by_hour_plot-1..svg)

Since there is a strong commuter-effect and some counters are paired to
count different directions, it makes sense to take a look at the
difference in traffic between the pairs during the day. We see that, for
example, in Jannowitzbrücke (`02-MI-JAN`) cyclists travel south-bound in
the morning and north-bound in the evening. Interestingly, traffic seems
to flow in mostly north-bound at Berlinerstraße (`10-PA-BER`) at almost
any time of the day. I'm not sure why this might be the case but it's
worth looking into later. The one exception is at 08:00, when many
cyclists are likely commuting to the centre of Berlin (south-bound).

``` {.r}
pairs_by_hour <- df %>% 
  filter(str_detect(location, 'Nord|Ost|Süd|West')) %>% 
  inner_join(df, by = c('pair', 'measured_at')) %>% 
  filter(as.numeric(counter_id.x) < as.numeric(counter_id.y)) %>% 
  select(measured_at, matches('id|total')) %>% 
  mutate(
    comparison = paste0(counter_id.x, ' - ', counter_id.y),
    difference = total.x - total.y
  ) %>% 
  group_by(g = hour(measured_at), comparison) %>% 
  summarise(difference = mean(difference)) 
```

![Difference in paired counts by hour of the
day](counting_cyclists_files/figure-markdown/pairs_by_hour_plot-1..svg)

In Klosterstraße (`15-SP-KLO`) and Mariendorfer Damm (`20-TS-MAR`) it
looks like traffic is roughly equal in both directions all day. The
former flows slightly more north-bound in evening, the latter more
north-bound in the morning. Given the positions of these two pairs of
counters, it is unlikely that they are part of a commuter-loop. The
overall counts for these four counters is fairly small on average, so
these apparent effects may just be noise.

The weekday counts seem fairly constant and fall by about a factor of a
third on the weekend. This is consistent with the commuter-effect seen
above.

``` {.r}
by_weekday <- df %>% 
  group_by(g = wday(measured_at, label = TRUE, week_start = 1)) %>% 
  summarise(
    q25 = quantile(total, 0.25),
    q50 = quantile(total, 0.50),
    q75 = quantile(total, 0.75)
  ) 
```

![Counts by
weekday](counting_cyclists_files/figure-markdown/by_weekday_plot-1..svg)

There is also a yearly seasonal pattern. Apart from berliners being more
willing to commute in summer, I'd be willing to bet that tourists are
also responsible for the summer peak in June/July. In winter, the roads
can become unsafe for cyclists due to the ice, snow, and lack of
maintenance.

``` {.r}
by_month <- df %>% 
  group_by(g = month(measured_at, label = TRUE)) %>% 
  summarise(
    q25 = quantile(total, 0.25),
    q50 = quantile(total, 0.50),
    q75 = quantile(total, 0.75)
  ) 
```

![Counts by
month](counting_cyclists_files/figure-markdown/by_month_plot-1..svg)

There is no clear yearly effect, as the median just ambles around 60
cyclist per hour.

``` {.r}
by_year <- df %>% 
  group_by(g = year(measured_at)) %>% 
  summarise(
    q25 = quantile(total, 0.25),
    q50 = quantile(total, 0.50),
    q75 = quantile(total, 0.75)
  ) 
```

![Counts by
year](counting_cyclists_files/figure-markdown/by_year_plot-1..svg)

What's next?
------------

So...that was all easier than expected. The weird north-bound pattern at
Berlinerstraße and the two large measurement gaps still need to be
looked into, but overall the data are in a good state. I'd like to be
able to combine this with data on bike-related traffic accidents, but
from what I can see, the Berlin police chose one of the few formats
worse than an excel sheet: [pdf
tables](https://www.berlin.de/polizei/aufgaben/verkehrssicherheit/verkehrsunfallstatistik/).

With 3D pie charts.

...
