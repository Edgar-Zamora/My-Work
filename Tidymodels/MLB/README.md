Predicting MLB Attendance with `{tidymodels}`
================

![Seattle Mariners Game \| Sung Shin @ironstagram](img/sea_mariners.jpg)

Living in the Seattle metro there has been a constant pattern that the
Seattle Mariners are bound not to draw large crowds. The first
inclination may be to attributed to the Mariners poor regular and
postseason record[^1]. There are certainly other reasons for poor
attendance which may include the opponent, starting pitcher, day of the
week, weather, and many other factors than just their record. If I where
an executive for a Major League Baseball (MLB) team, I would like to
know which games were likely to have lower attendance so that corrective
measures like giveaways, special nights or other promotions could help
attract larger crowds.

The rest of this post will attempt to create a model that will help
predict MLB attendance for home games. I strictly focus on home games
because I believe looking at away games is not necessary since MLB teams
may not have any interest in those games since they do not get revenue,
at least that is what I believe. I am writing this as the restrictions
for the COVID-19 pandemic are being lifted so some caution should be
taken applying a model trained on pre-COVID data to post-COVID games but
I think it is worth trying out.

# MLB Schedule Structure

The MLB consists of 30 teams split into the American League (AL) and the
National League (NL). Within each league there are 3 divisions that
further split the teams into an east, central, and western division.
Teams traditionally most play most of their games against division
rivals followed by league games and finally interleague games.
Ultimately what that results in is a total of 164 games per team or
2,430 total games that span from late March/early April to late
September/early October.

# Data

The majority of the game, outcome, pitcher, and standing data comes from
[Baseball Reference](https://www.baseball-reference.com/teams/). Using
the `{revest}` package, I build a scrapper the pulls data and separates
it into relevant tables. For now, I will not be going in depth about the
script that scrapped the data, but if you are interested you can see the
[GitHub
Repo](https://github.com/Edgar-Zamora/My-Work/blob/master/Tidymodels/MLB/get_data.R).

I also us the `{mlbstatsR}` package by
[IvoVillanueva](https://github.com/IvoVillanueva) to get information
about a MLBs league, division, full name and other attributes.

Of the many possible features to include in a model that helps predict
attendance, I consider the following to be the most import.

<ol type="A">
<li>
Outcome
</li>
<li>
Game
</li>
<li>
Standing
</li>
<ul>
<li>
Current Win Streak
</li>
<li>
Team Win %
</li>
<li>
Games back
</li>
</ul>
</ol>

# Building Models

# Evualting Model

# Final Thought

[^1]: The Seattle Mariners have not made the playoffs since 2001, which
    is the longest current streak of any North American pro sports team.
