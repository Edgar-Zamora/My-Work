What the f%&gt;% is Moore’s Law?
================================

Moore’s Law refers to a perception that was first formulated by Gordon
Moore who believed that “the number of transistors on a microchip
doubles every two years, though the cost of computers is halved”[1].
With that in mind, there were a multitude of different ways one could
analyze this perception to decide whether it was true or if it was
lacking in credibility.

Keys Visualization takeaways
============================

Creating the visualization
==========================

As is customary when discussing R analysis, I have provided the
necessary packages to replicate my visualization.

The data for Moore’s Law can be found on the tidytuesday
[GitHub](https://github.com/rfordatascience/tidytuesday/tree/master/data/2019/2019-09-03).

Fonts in R
==========

You should know that I used a **MacBook Pro** to laod fonts. I am unsure
about how this would work on machines but I assume it would work in a
similar fashion. To view and load different fonts into R, you will need
to install and load the `extrafont` package. The primary function within
this package that you will be using is the `font_import()` function.
Running this function will import all fonts that are currently avaiable
on your machine. In addition to the defualt fonts on your machine, you
are also able to bring in additional fonts. If you have added a font
manually, you can bring load it by using the `font_import()` with the
specific font name as an argument like so: `font_import("my_new_font")`.
For more detail regarding the package I encourage you to check out the
GitHub [documentation](https://github.com/wch/extrafont).

    ## Importing fonts may take a few minutes, depending on the number of fonts and the speed of the system.
    ## Continue? [y/n]

    ##     package                              afmfile
    ## 1        NA                      Keyboard.afm.gz
    ## 2        NA                   SFNSDisplay.afm.gz
    ## 3        NA                   SFNSRounded.afm.gz
    ## 4        NA                      SFNSText.afm.gz
    ## 5        NA                SFNSTextItalic.afm.gz
    ## 6        NA                   Andale Mono.afm.gz
    ## 7        NA                 Apple Braille.afm.gz
    ## 8        NA   Apple Braille Outline 6 Dot.afm.gz
    ## 9        NA   Apple Braille Outline 8 Dot.afm.gz
    ## 10       NA  Apple Braille Pinpoint 6 Dot.afm.gz
    ## 11       NA  Apple Braille Pinpoint 8 Dot.afm.gz
    ## 12       NA                  AppleMyungjo.afm.gz
    ## 13       NA                   Arial Black.afm.gz
    ## 14       NA             Arial Bold Italic.afm.gz
    ## 15       NA             Arial Bold Italic.afm.gz
    ## 16       NA                    Arial Bold.afm.gz
    ## 17       NA                    Arial Bold.afm.gz
    ## 18       NA                  Arial Italic.afm.gz
    ## 19       NA                  Arial Italic.afm.gz
    ## 20       NA                         Arial.afm.gz
    ## 21       NA                         Arial.afm.gz
    ## 22       NA                  Arial Narrow.afm.gz
    ## 23       NA             Arial Narrow Bold.afm.gz
    ## 24       NA      Arial Narrow Bold Italic.afm.gz
    ## 25       NA           Arial Narrow Italic.afm.gz
    ## 26       NA            Arial Rounded Bold.afm.gz
    ## 27       NA                 Arial Unicode.afm.gz
    ## 28       NA                        Batang.afm.gz
    ## 29       NA              Bodoni Ornaments.afm.gz
    ## 30       NA      Bodoni 72 Smallcaps Book.afm.gz
    ## 31       NA            Bookshelf Symbol 7.afm.gz
    ## 32       NA             Bradley Hand Bold.afm.gz
    ## 33       NA                  Brush Script.afm.gz
    ## 34       NA                  Brush Script.afm.gz
    ## 35       NA                       Calibri.afm.gz
    ## 36       NA                  Calibri Bold.afm.gz
    ## 37       NA           Calibri Bold Italic.afm.gz
    ## 38       NA                Calibri Italic.afm.gz
    ## 39       NA                      Calibril.afm.gz
    ## 40       NA                       Cambria.afm.gz
    ## 41       NA                  Cambria Bold.afm.gz
    ## 42       NA           Cambria Bold Italic.afm.gz
    ## 43       NA                Cambria Italic.afm.gz
    ## 44       NA                  Cambria Math.afm.gz
    ## 45       NA                       Candara.afm.gz
    ## 46       NA                  Candara Bold.afm.gz
    ## 47       NA           Candara Bold Italic.afm.gz
    ## 48       NA                Candara Italic.afm.gz
    ## 49       NA                 Comic Sans MS.afm.gz
    ## 50       NA            Comic Sans MS Bold.afm.gz
    ## 51       NA                      Consolas.afm.gz
    ## 52       NA                 Consolas Bold.afm.gz
    ## 53       NA          Consolas Bold Italic.afm.gz
    ## 54       NA               Consolas Italic.afm.gz
    ## 55       NA                    Constantia.afm.gz
    ## 56       NA               Constantia Bold.afm.gz
    ## 57       NA        Constantia Bold Italic.afm.gz
    ## 58       NA             Constantia Italic.afm.gz
    ## 59       NA                        Corbel.afm.gz
    ## 60       NA                   Corbel Bold.afm.gz
    ## 61       NA            Corbel Bold Italic.afm.gz
    ## 62       NA                 Corbel Italic.afm.gz
    ## 63       NA       Courier New Bold Italic.afm.gz
    ## 64       NA              Courier New Bold.afm.gz
    ## 65       NA            Courier New Italic.afm.gz
    ## 66       NA                   Courier New.afm.gz
    ## 67       NA            DIN Alternate Bold.afm.gz
    ## 68       NA            DIN Condensed Bold.afm.gz
    ## 69       NA          Franklin Gothic Book.afm.gz
    ## 70       NA   Franklin Gothic Book Italic.afm.gz
    ## 71       NA        Franklin Gothic Medium.afm.gz
    ## 72       NA Franklin Gothic Medium Italic.afm.gz
    ## 73       NA                      Gabriola.afm.gz
    ## 74       NA                       Georgia.afm.gz
    ## 75       NA                  Georgia Bold.afm.gz
    ## 76       NA           Georgia Bold Italic.afm.gz
    ## 77       NA                Georgia Italic.afm.gz
    ## 78       NA                  Gill Sans MT.afm.gz
    ## 79       NA             Gill Sans MT Bold.afm.gz
    ## 80       NA      Gill Sans MT Bold Italic.afm.gz
    ## 81       NA           Gill Sans MT Italic.afm.gz
    ## 82       NA                         Gulim.afm.gz
    ## 83       NA                        Impact.afm.gz
    ## 84       NA               Khmer Sangam MN.afm.gz
    ## 85       NA                 Lao Sangam MN.afm.gz
    ## 86       NA                Lucida Console.afm.gz
    ## 87       NA           Lucida Sans Unicode.afm.gz
    ## 88       NA                      Luminari.afm.gz
    ## 89       NA                       Marlett.afm.gz
    ## 90       NA                        Meiryo.afm.gz
    ## 91       NA                   Meiryo Bold.afm.gz
    ## 92       NA            Meiryo Bold Italic.afm.gz
    ## 93       NA                 Meiryo Italic.afm.gz
    ## 94       NA                          msyi.afm.gz
    ## 95       NA                      himalaya.afm.gz
    ## 96       NA          Microsoft Sans Serif.afm.gz
    ## 97       NA                         taile.afm.gz
    ## 98       NA                        TaiLeb.afm.gz
    ## 99       NA            MingLiU_HKSCS-ExtB.afm.gz
    ## 100      NA                 mingliu_hkscs.afm.gz
    ## 101      NA                       MingLiU.afm.gz
    ## 102      NA                  MingLiU-ExtB.afm.gz
    ## 103      NA                      monbaiti.afm.gz
    ## 104      NA                     MS Gothic.afm.gz
    ## 105      NA                     MS Mincho.afm.gz
    ## 106      NA                    MS PGothic.afm.gz
    ## 107      NA                    MS PMincho.afm.gz
    ## 108      NA       MS Reference Sans Serif.afm.gz
    ## 109      NA        MS Reference Specialty.afm.gz
    ## 110      NA                      ODALISQU.afm.gz
    ## 111      NA        Palatino Linotype Bold.afm.gz
    ## 112      NA Palatino Linotype Bold Italic.afm.gz
    ## 113      NA      Palatino Linotype Italic.afm.gz
    ## 114      NA             Palatino Linotype.afm.gz
    ## 115      NA                      Perpetua.afm.gz
    ## 116      NA                 Perpetua Bold.afm.gz
    ## 117      NA          Perpetua Bold Italic.afm.gz
    ## 118      NA               Perpetua Italic.afm.gz
    ## 119      NA                      PMingLiU.afm.gz
    ## 120      NA                 PMingLiU-ExtB.afm.gz
    ## 121      NA                        SimHei.afm.gz
    ## 122      NA                        SimSun.afm.gz
    ## 123      NA                   SimSun-ExtB.afm.gz
    ## 124      NA                        Tahoma.afm.gz
    ## 125      NA                   Tahoma Bold.afm.gz
    ## 126      NA   Times New Roman Bold Italic.afm.gz
    ## 127      NA   Times New Roman Bold Italic.afm.gz
    ## 128      NA          Times New Roman Bold.afm.gz
    ## 129      NA          Times New Roman Bold.afm.gz
    ## 130      NA        Times New Roman Italic.afm.gz
    ## 131      NA        Times New Roman Italic.afm.gz
    ## 132      NA               Times New Roman.afm.gz
    ## 133      NA               Times New Roman.afm.gz
    ## 134      NA                   Trattatello.afm.gz
    ## 135      NA      Trebuchet MS Bold Italic.afm.gz
    ## 136      NA                  Trebuchet MS.afm.gz
    ## 137      NA             Trebuchet MS Bold.afm.gz
    ## 138      NA           Trebuchet MS Italic.afm.gz
    ## 139      NA                Tw Cen MT Bold.afm.gz
    ## 140      NA         Tw Cen MT Bold Italic.afm.gz
    ## 141      NA              Tw Cen MT Italic.afm.gz
    ## 142      NA                     Tw Cen MT.afm.gz
    ## 143      NA                       Verdana.afm.gz
    ## 144      NA                       Verdana.afm.gz
    ## 145      NA                  Verdana Bold.afm.gz
    ## 146      NA                  Verdana Bold.afm.gz
    ## 147      NA           Verdana Bold Italic.afm.gz
    ## 148      NA           Verdana Bold Italic.afm.gz
    ## 149      NA                Verdana Italic.afm.gz
    ## 150      NA                Verdana Italic.afm.gz
    ## 151      NA                      Webdings.afm.gz
    ## 152      NA                     Wingdings.afm.gz
    ## 153      NA                     Wingdings.afm.gz
    ## 154      NA                   Wingdings 2.afm.gz
    ## 155      NA                   Wingdings 2.afm.gz
    ## 156      NA                   Wingdings 3.afm.gz
    ## 157      NA                   Wingdings 3.afm.gz
    ## 158      NA                           NHL.afm.gz
    ##                                                       fontfile
    ## 1                           /System/Library/Fonts/Keyboard.ttf
    ## 2                        /System/Library/Fonts/SFNSDisplay.ttf
    ## 3                        /System/Library/Fonts/SFNSRounded.ttf
    ## 4                           /System/Library/Fonts/SFNSText.ttf
    ## 5                     /System/Library/Fonts/SFNSTextItalic.ttf
    ## 6                               /Library/Fonts/Andale Mono.ttf
    ## 7                      /System/Library/Fonts/Apple Braille.ttf
    ## 8        /System/Library/Fonts/Apple Braille Outline 6 Dot.ttf
    ## 9        /System/Library/Fonts/Apple Braille Outline 8 Dot.ttf
    ## 10      /System/Library/Fonts/Apple Braille Pinpoint 6 Dot.ttf
    ## 11      /System/Library/Fonts/Apple Braille Pinpoint 8 Dot.ttf
    ## 12                             /Library/Fonts/AppleMyungjo.ttf
    ## 13                              /Library/Fonts/Arial Black.ttf
    ## 14                        /Library/Fonts/Arial Bold Italic.ttf
    ## 15              /Library/Fonts/Microsoft/Arial Bold Italic.ttf
    ## 16                     /Library/Fonts/Microsoft/Arial Bold.ttf
    ## 17                               /Library/Fonts/Arial Bold.ttf
    ## 18                   /Library/Fonts/Microsoft/Arial Italic.ttf
    ## 19                             /Library/Fonts/Arial Italic.ttf
    ## 20                                    /Library/Fonts/Arial.ttf
    ## 21                          /Library/Fonts/Microsoft/Arial.ttf
    ## 22                             /Library/Fonts/Arial Narrow.ttf
    ## 23                        /Library/Fonts/Arial Narrow Bold.ttf
    ## 24                 /Library/Fonts/Arial Narrow Bold Italic.ttf
    ## 25                      /Library/Fonts/Arial Narrow Italic.ttf
    ## 26                       /Library/Fonts/Arial Rounded Bold.ttf
    ## 27                            /Library/Fonts/Arial Unicode.ttf
    ## 28                         /Library/Fonts/Microsoft/Batang.ttf
    ## 29                         /Library/Fonts/Bodoni Ornaments.ttf
    ## 30                 /Library/Fonts/Bodoni 72 Smallcaps Book.ttf
    ## 31             /Library/Fonts/Microsoft/Bookshelf Symbol 7.ttf
    ## 32                        /Library/Fonts/Bradley Hand Bold.ttf
    ## 33                             /Library/Fonts/Brush Script.ttf
    ## 34                   /Library/Fonts/Microsoft/Brush Script.ttf
    ## 35                        /Library/Fonts/Microsoft/Calibri.ttf
    ## 36                   /Library/Fonts/Microsoft/Calibri Bold.ttf
    ## 37            /Library/Fonts/Microsoft/Calibri Bold Italic.ttf
    ## 38                 /Library/Fonts/Microsoft/Calibri Italic.ttf
    ## 39                       /Library/Fonts/Microsoft/Calibril.ttf
    ## 40                        /Library/Fonts/Microsoft/Cambria.ttf
    ## 41                   /Library/Fonts/Microsoft/Cambria Bold.ttf
    ## 42            /Library/Fonts/Microsoft/Cambria Bold Italic.ttf
    ## 43                 /Library/Fonts/Microsoft/Cambria Italic.ttf
    ## 44                   /Library/Fonts/Microsoft/Cambria Math.ttf
    ## 45                        /Library/Fonts/Microsoft/Candara.ttf
    ## 46                   /Library/Fonts/Microsoft/Candara Bold.ttf
    ## 47            /Library/Fonts/Microsoft/Candara Bold Italic.ttf
    ## 48                 /Library/Fonts/Microsoft/Candara Italic.ttf
    ## 49                            /Library/Fonts/Comic Sans MS.ttf
    ## 50                       /Library/Fonts/Comic Sans MS Bold.ttf
    ## 51                       /Library/Fonts/Microsoft/Consolas.ttf
    ## 52                  /Library/Fonts/Microsoft/Consolas Bold.ttf
    ## 53           /Library/Fonts/Microsoft/Consolas Bold Italic.ttf
    ## 54                /Library/Fonts/Microsoft/Consolas Italic.ttf
    ## 55                     /Library/Fonts/Microsoft/Constantia.ttf
    ## 56                /Library/Fonts/Microsoft/Constantia Bold.ttf
    ## 57         /Library/Fonts/Microsoft/Constantia Bold Italic.ttf
    ## 58              /Library/Fonts/Microsoft/Constantia Italic.ttf
    ## 59                         /Library/Fonts/Microsoft/Corbel.ttf
    ## 60                    /Library/Fonts/Microsoft/Corbel Bold.ttf
    ## 61             /Library/Fonts/Microsoft/Corbel Bold Italic.ttf
    ## 62                  /Library/Fonts/Microsoft/Corbel Italic.ttf
    ## 63                  /Library/Fonts/Courier New Bold Italic.ttf
    ## 64                         /Library/Fonts/Courier New Bold.ttf
    ## 65                       /Library/Fonts/Courier New Italic.ttf
    ## 66                              /Library/Fonts/Courier New.ttf
    ## 67                       /Library/Fonts/DIN Alternate Bold.ttf
    ## 68                       /Library/Fonts/DIN Condensed Bold.ttf
    ## 69           /Library/Fonts/Microsoft/Franklin Gothic Book.ttf
    ## 70    /Library/Fonts/Microsoft/Franklin Gothic Book Italic.ttf
    ## 71         /Library/Fonts/Microsoft/Franklin Gothic Medium.ttf
    ## 72  /Library/Fonts/Microsoft/Franklin Gothic Medium Italic.ttf
    ## 73                       /Library/Fonts/Microsoft/Gabriola.ttf
    ## 74                                  /Library/Fonts/Georgia.ttf
    ## 75                             /Library/Fonts/Georgia Bold.ttf
    ## 76                      /Library/Fonts/Georgia Bold Italic.ttf
    ## 77                           /Library/Fonts/Georgia Italic.ttf
    ## 78                   /Library/Fonts/Microsoft/Gill Sans MT.ttf
    ## 79              /Library/Fonts/Microsoft/Gill Sans MT Bold.ttf
    ## 80       /Library/Fonts/Microsoft/Gill Sans MT Bold Italic.ttf
    ## 81            /Library/Fonts/Microsoft/Gill Sans MT Italic.ttf
    ## 82                          /Library/Fonts/Microsoft/Gulim.ttf
    ## 83                                   /Library/Fonts/Impact.ttf
    ## 84                          /Library/Fonts/Khmer Sangam MN.ttf
    ## 85                            /Library/Fonts/Lao Sangam MN.ttf
    ## 86                 /Library/Fonts/Microsoft/Lucida Console.ttf
    ## 87            /Library/Fonts/Microsoft/Lucida Sans Unicode.ttf
    ## 88                                 /Library/Fonts/Luminari.ttf
    ## 89                        /Library/Fonts/Microsoft/Marlett.ttf
    ## 90                         /Library/Fonts/Microsoft/Meiryo.ttf
    ## 91                    /Library/Fonts/Microsoft/Meiryo Bold.ttf
    ## 92             /Library/Fonts/Microsoft/Meiryo Bold Italic.ttf
    ## 93                  /Library/Fonts/Microsoft/Meiryo Italic.ttf
    ## 94                           /Library/Fonts/Microsoft/msyi.ttf
    ## 95                       /Library/Fonts/Microsoft/himalaya.ttf
    ## 96                     /Library/Fonts/Microsoft Sans Serif.ttf
    ## 97                          /Library/Fonts/Microsoft/taile.ttf
    ## 98                         /Library/Fonts/Microsoft/TaiLeb.ttf
    ## 99             /Library/Fonts/Microsoft/MingLiU_HKSCS-ExtB.ttf
    ## 100                 /Library/Fonts/Microsoft/mingliu_hkscs.ttf
    ## 101                       /Library/Fonts/Microsoft/MingLiU.ttf
    ## 102                  /Library/Fonts/Microsoft/MingLiU-ExtB.ttf
    ## 103                      /Library/Fonts/Microsoft/monbaiti.ttf
    ## 104                     /Library/Fonts/Microsoft/MS Gothic.ttf
    ## 105                     /Library/Fonts/Microsoft/MS Mincho.ttf
    ## 106                    /Library/Fonts/Microsoft/MS PGothic.ttf
    ## 107                    /Library/Fonts/Microsoft/MS PMincho.ttf
    ## 108       /Library/Fonts/Microsoft/MS Reference Sans Serif.ttf
    ## 109        /Library/Fonts/Microsoft/MS Reference Specialty.ttf
    ## 110              /Users/edgarzamora/Library/Fonts/ODALISQU.TTF
    ## 111        /Library/Fonts/Microsoft/Palatino Linotype Bold.ttf
    ## 112 /Library/Fonts/Microsoft/Palatino Linotype Bold Italic.ttf
    ## 113      /Library/Fonts/Microsoft/Palatino Linotype Italic.ttf
    ## 114             /Library/Fonts/Microsoft/Palatino Linotype.ttf
    ## 115                      /Library/Fonts/Microsoft/Perpetua.ttf
    ## 116                 /Library/Fonts/Microsoft/Perpetua Bold.ttf
    ## 117          /Library/Fonts/Microsoft/Perpetua Bold Italic.ttf
    ## 118               /Library/Fonts/Microsoft/Perpetua Italic.ttf
    ## 119                      /Library/Fonts/Microsoft/PMingLiU.ttf
    ## 120                 /Library/Fonts/Microsoft/PMingLiU-ExtB.ttf
    ## 121                        /Library/Fonts/Microsoft/SimHei.ttf
    ## 122                        /Library/Fonts/Microsoft/SimSun.ttf
    ## 123                   /Library/Fonts/Microsoft/SimSun-ExtB.ttf
    ## 124                                  /Library/Fonts/Tahoma.ttf
    ## 125                             /Library/Fonts/Tahoma Bold.ttf
    ## 126   /Library/Fonts/Microsoft/Times New Roman Bold Italic.ttf
    ## 127             /Library/Fonts/Times New Roman Bold Italic.ttf
    ## 128          /Library/Fonts/Microsoft/Times New Roman Bold.ttf
    ## 129                    /Library/Fonts/Times New Roman Bold.ttf
    ## 130        /Library/Fonts/Microsoft/Times New Roman Italic.ttf
    ## 131                  /Library/Fonts/Times New Roman Italic.ttf
    ## 132               /Library/Fonts/Microsoft/Times New Roman.ttf
    ## 133                         /Library/Fonts/Times New Roman.ttf
    ## 134                             /Library/Fonts/Trattatello.ttf
    ## 135                /Library/Fonts/Trebuchet MS Bold Italic.ttf
    ## 136                            /Library/Fonts/Trebuchet MS.ttf
    ## 137                       /Library/Fonts/Trebuchet MS Bold.ttf
    ## 138                     /Library/Fonts/Trebuchet MS Italic.ttf
    ## 139                /Library/Fonts/Microsoft/Tw Cen MT Bold.ttf
    ## 140         /Library/Fonts/Microsoft/Tw Cen MT Bold Italic.ttf
    ## 141              /Library/Fonts/Microsoft/Tw Cen MT Italic.ttf
    ## 142                     /Library/Fonts/Microsoft/Tw Cen MT.ttf
    ## 143                                 /Library/Fonts/Verdana.ttf
    ## 144                       /Library/Fonts/Microsoft/Verdana.ttf
    ## 145                            /Library/Fonts/Verdana Bold.ttf
    ## 146                  /Library/Fonts/Microsoft/Verdana Bold.ttf
    ## 147           /Library/Fonts/Microsoft/Verdana Bold Italic.ttf
    ## 148                     /Library/Fonts/Verdana Bold Italic.ttf
    ## 149                          /Library/Fonts/Verdana Italic.ttf
    ## 150                /Library/Fonts/Microsoft/Verdana Italic.ttf
    ## 151                                /Library/Fonts/Webdings.ttf
    ## 152                               /Library/Fonts/Wingdings.ttf
    ## 153                     /Library/Fonts/Microsoft/Wingdings.ttf
    ## 154                   /Library/Fonts/Microsoft/Wingdings 2.ttf
    ## 155                             /Library/Fonts/Wingdings 2.ttf
    ## 156                   /Library/Fonts/Microsoft/Wingdings 3.ttf
    ## 157                             /Library/Fonts/Wingdings 3.ttf
    ## 158                   /Users/edgarzamora/Library/Fonts/NHL.ttf
    ##                          FullName              FamilyName
    ## 1                       .Keyboard               .Keyboard
    ## 2                     System Font             System Font
    ## 3                  .SF NS Rounded          .SF NS Rounded
    ## 4                     System Font             System Font
    ## 5              System Font Italic             System Font
    ## 6                     Andale Mono             Andale Mono
    ## 7                   Apple Braille           Apple Braille
    ## 8     Apple Braille Outline 6 Dot           Apple Braille
    ## 9     Apple Braille Outline 8 Dot           Apple Braille
    ## 10   Apple Braille Pinpoint 6 Dot           Apple Braille
    ## 11   Apple Braille Pinpoint 8 Dot           Apple Braille
    ## 12           AppleMyungjo Regular            AppleMyungjo
    ## 13                    Arial Black             Arial Black
    ## 14              Arial Bold Italic                   Arial
    ## 15              Arial Bold Italic                   Arial
    ## 16                     Arial Bold                   Arial
    ## 17                     Arial Bold                   Arial
    ## 18                   Arial Italic                   Arial
    ## 19                   Arial Italic                   Arial
    ## 20                          Arial                   Arial
    ## 21                          Arial                   Arial
    ## 22                   Arial Narrow            Arial Narrow
    ## 23              Arial Narrow Bold            Arial Narrow
    ## 24       Arial Narrow Bold Italic            Arial Narrow
    ## 25            Arial Narrow Italic            Arial Narrow
    ## 26          Arial Rounded MT Bold   Arial Rounded MT Bold
    ## 27               Arial Unicode MS        Arial Unicode MS
    ## 28                         Batang                  Batang
    ## 29               Bodoni Ornaments        Bodoni Ornaments
    ## 30       Bodoni 72 Smallcaps Book     Bodoni 72 Smallcaps
    ## 31             Bookshelf Symbol 7      Bookshelf Symbol 7
    ## 32              Bradley-Hand-Bold                        
    ## 33         Brush Script MT Italic         Brush Script MT
    ## 34         Brush Script MT Italic         Brush Script MT
    ## 35                        Calibri                 Calibri
    ## 36                   Calibri Bold                 Calibri
    ## 37            Calibri Bold Italic                 Calibri
    ## 38                 Calibri Italic                 Calibri
    ## 39                  Calibri Light           Calibri Light
    ## 40                        Cambria                 Cambria
    ## 41                   Cambria Bold                 Cambria
    ## 42            Cambria Bold Italic                 Cambria
    ## 43                 Cambria Italic                 Cambria
    ## 44                   Cambria Math            Cambria Math
    ## 45                        Candara                 Candara
    ## 46                   Candara Bold                 Candara
    ## 47            Candara Bold Italic                 Candara
    ## 48                 Candara Italic                 Candara
    ## 49                  Comic Sans MS           Comic Sans MS
    ## 50             Comic Sans MS Bold           Comic Sans MS
    ## 51                       Consolas                Consolas
    ## 52                  Consolas Bold                Consolas
    ## 53           Consolas Bold Italic                Consolas
    ## 54                Consolas Italic                Consolas
    ## 55                     Constantia              Constantia
    ## 56                Constantia Bold              Constantia
    ## 57         Constantia Bold Italic              Constantia
    ## 58              Constantia Italic              Constantia
    ## 59                         Corbel                  Corbel
    ## 60                    Corbel Bold                  Corbel
    ## 61             Corbel Bold Italic                  Corbel
    ## 62                  Corbel Italic                  Corbel
    ## 63        Courier New Bold Italic             Courier New
    ## 64               Courier New Bold             Courier New
    ## 65             Courier New Italic             Courier New
    ## 66                    Courier New             Courier New
    ## 67             DIN Alternate Bold           DIN Alternate
    ## 68             DIN Condensed Bold           DIN Condensed
    ## 69           Franklin Gothic Book    Franklin Gothic Book
    ## 70    Franklin Gothic Book Italic    Franklin Gothic Book
    ## 71         Franklin Gothic Medium  Franklin Gothic Medium
    ## 72  Franklin Gothic Medium Italic  Franklin Gothic Medium
    ## 73                       Gabriola                Gabriola
    ## 74                        Georgia                 Georgia
    ## 75                   Georgia Bold                 Georgia
    ## 76            Georgia Bold Italic                 Georgia
    ## 77                 Georgia Italic                 Georgia
    ## 78                   Gill Sans MT            Gill Sans MT
    ## 79              Gill Sans MT Bold            Gill Sans MT
    ## 80       Gill Sans MT Bold Italic            Gill Sans MT
    ## 81            Gill Sans MT Italic            Gill Sans MT
    ## 82                          Gulim                   Gulim
    ## 83                         Impact                  Impact
    ## 84                Khmer Sangam MN         Khmer Sangam MN
    ## 85                  Lao Sangam MN           Lao Sangam MN
    ## 86                 Lucida Console          Lucida Console
    ## 87            Lucida Sans Unicode     Lucida Sans Unicode
    ## 88                       Luminari                Luminari
    ## 89                        Marlett                 Marlett
    ## 90                         Meiryo                  Meiryo
    ## 91                    Meiryo Bold                  Meiryo
    ## 92             Meiryo Bold Italic                  Meiryo
    ## 93                  Meiryo Italic                  Meiryo
    ## 94             Microsoft Yi Baiti      Microsoft Yi Baiti
    ## 95             Microsoft Himalaya      Microsoft Himalaya
    ## 96           Microsoft Sans Serif    Microsoft Sans Serif
    ## 97               Microsoft Tai Le        Microsoft Tai Le
    ## 98          Microsoft Tai Le Bold        Microsoft Tai Le
    ## 99             MingLiU_HKSCS-ExtB      MingLiU_HKSCS-ExtB
    ## 100                 MingLiU_HKSCS           MingLiU_HKSCS
    ## 101                       MingLiU                 MingLiU
    ## 102                  MingLiU-ExtB            MingLiU-ExtB
    ## 103               Mongolian Baiti         Mongolian Baiti
    ## 104                     MS Gothic               MS Gothic
    ## 105                     MS Mincho               MS Mincho
    ## 106                    MS PGothic              MS PGothic
    ## 107                    MS PMincho              MS PMincho
    ## 108       MS Reference Sans Serif MS Reference Sans Serif
    ## 109        MS Reference Specialty  MS Reference Specialty
    ## 110                     Odalisque               Odalisque
    ## 111        Palatino Linotype Bold       Palatino Linotype
    ## 112 Palatino Linotype Bold Italic       Palatino Linotype
    ## 113      Palatino Linotype Italic       Palatino Linotype
    ## 114             Palatino Linotype       Palatino Linotype
    ## 115                      Perpetua                Perpetua
    ## 116                 Perpetua Bold                Perpetua
    ## 117          Perpetua Bold Italic                Perpetua
    ## 118               Perpetua Italic                Perpetua
    ## 119                      PMingLiU                PMingLiU
    ## 120                 PMingLiU-ExtB           PMingLiU-ExtB
    ## 121                        SimHei                  SimHei
    ## 122                        SimSun                  SimSun
    ## 123                   SimSun-ExtB             SimSun-ExtB
    ## 124                        Tahoma                  Tahoma
    ## 125                   Tahoma Bold                  Tahoma
    ## 126   Times New Roman Bold Italic         Times New Roman
    ## 127   Times New Roman Bold Italic         Times New Roman
    ## 128          Times New Roman Bold         Times New Roman
    ## 129          Times New Roman Bold         Times New Roman
    ## 130        Times New Roman Italic         Times New Roman
    ## 131        Times New Roman Italic         Times New Roman
    ## 132               Times New Roman         Times New Roman
    ## 133               Times New Roman         Times New Roman
    ## 134                   Trattatello             Trattatello
    ## 135      Trebuchet MS Bold Italic            Trebuchet MS
    ## 136                  Trebuchet MS            Trebuchet MS
    ## 137             Trebuchet MS Bold            Trebuchet MS
    ## 138           Trebuchet MS Italic            Trebuchet MS
    ## 139                Tw Cen MT Bold               Tw Cen MT
    ## 140         Tw Cen MT Bold Italic               Tw Cen MT
    ## 141              Tw Cen MT Italic               Tw Cen MT
    ## 142                     Tw Cen MT               Tw Cen MT
    ## 143                       Verdana                 Verdana
    ## 144                       Verdana                 Verdana
    ## 145                  Verdana Bold                 Verdana
    ## 146                  Verdana Bold                 Verdana
    ## 147           Verdana Bold Italic                 Verdana
    ## 148           Verdana Bold Italic                 Verdana
    ## 149                Verdana Italic                 Verdana
    ## 150                Verdana Italic                 Verdana
    ## 151                      Webdings                Webdings
    ## 152                     Wingdings               Wingdings
    ## 153                     Wingdings               Wingdings
    ## 154                   Wingdings 2             Wingdings 2
    ## 155                   Wingdings 2             Wingdings 2
    ## 156                   Wingdings 3             Wingdings 3
    ## 157                   Wingdings 3             Wingdings 3
    ## 158                           NHL                     NHL
    ##                         FontName  Bold Italic Symbol afmsymfile
    ## 1                      -Keyboard FALSE  FALSE  FALSE         NA
    ## 2                   -SFNSDisplay FALSE  FALSE  FALSE         NA
    ## 3           -SFNSRounded-Regular FALSE  FALSE  FALSE         NA
    ## 4                      -SFNSText FALSE  FALSE  FALSE         NA
    ## 5               -SFNSText-Italic FALSE   TRUE  FALSE         NA
    ## 6                     AndaleMono FALSE  FALSE  FALSE         NA
    ## 7                   AppleBraille FALSE  FALSE  FALSE         NA
    ## 8       AppleBraille-Outline6Dot FALSE  FALSE  FALSE         NA
    ## 9       AppleBraille-Outline8Dot FALSE  FALSE  FALSE         NA
    ## 10     AppleBraille-Pinpoint6Dot FALSE  FALSE  FALSE         NA
    ## 11     AppleBraille-Pinpoint8Dot FALSE  FALSE  FALSE         NA
    ## 12                  AppleMyungjo FALSE  FALSE  FALSE         NA
    ## 13                   Arial-Black FALSE  FALSE  FALSE         NA
    ## 14            Arial-BoldItalicMT  TRUE   TRUE  FALSE         NA
    ## 15            Arial-BoldItalicMT  TRUE   TRUE  FALSE         NA
    ## 16                  Arial-BoldMT  TRUE  FALSE  FALSE         NA
    ## 17                  Arial-BoldMT  TRUE  FALSE  FALSE         NA
    ## 18                Arial-ItalicMT FALSE   TRUE  FALSE         NA
    ## 19                Arial-ItalicMT FALSE   TRUE  FALSE         NA
    ## 20                       ArialMT FALSE  FALSE  FALSE         NA
    ## 21                       ArialMT FALSE  FALSE  FALSE         NA
    ## 22                   ArialNarrow FALSE  FALSE  FALSE         NA
    ## 23              ArialNarrow-Bold  TRUE  FALSE  FALSE         NA
    ## 24        ArialNarrow-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 25            ArialNarrow-Italic FALSE   TRUE  FALSE         NA
    ## 26            ArialRoundedMTBold FALSE  FALSE  FALSE         NA
    ## 27                ArialUnicodeMS FALSE  FALSE  FALSE         NA
    ## 28                        Batang FALSE  FALSE  FALSE         NA
    ## 29          BodoniOrnamentsITCTT FALSE  FALSE  FALSE         NA
    ## 30     BodoniSvtyTwoSCITCTT-Book FALSE  FALSE  FALSE         NA
    ## 31          BookshelfSymbolSeven FALSE  FALSE   TRUE         NA
    ## 32             Bradley-Hand-Bold  TRUE  FALSE  FALSE         NA
    ## 33                 BrushScriptMT FALSE   TRUE  FALSE         NA
    ## 34                 BrushScriptMT FALSE   TRUE  FALSE         NA
    ## 35                       Calibri FALSE  FALSE  FALSE         NA
    ## 36                  Calibri-Bold  TRUE  FALSE  FALSE         NA
    ## 37            Calibri-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 38                Calibri-Italic FALSE   TRUE  FALSE         NA
    ## 39                 Calibri-Light FALSE  FALSE  FALSE         NA
    ## 40                       Cambria FALSE  FALSE  FALSE         NA
    ## 41                  Cambria-Bold  TRUE  FALSE  FALSE         NA
    ## 42            Cambria-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 43                Cambria-Italic FALSE   TRUE  FALSE         NA
    ## 44                   CambriaMath FALSE  FALSE  FALSE         NA
    ## 45                       Candara FALSE  FALSE  FALSE         NA
    ## 46                  Candara-Bold  TRUE  FALSE  FALSE         NA
    ## 47            Candara-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 48                Candara-Italic FALSE   TRUE  FALSE         NA
    ## 49                   ComicSansMS FALSE  FALSE  FALSE         NA
    ## 50              ComicSansMS-Bold  TRUE  FALSE  FALSE         NA
    ## 51                      Consolas FALSE  FALSE  FALSE         NA
    ## 52                 Consolas-Bold  TRUE  FALSE  FALSE         NA
    ## 53           Consolas-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 54               Consolas-Italic FALSE   TRUE  FALSE         NA
    ## 55                    Constantia FALSE  FALSE  FALSE         NA
    ## 56               Constantia-Bold  TRUE  FALSE  FALSE         NA
    ## 57         Constantia-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 58             Constantia-Italic FALSE   TRUE  FALSE         NA
    ## 59                        Corbel FALSE  FALSE  FALSE         NA
    ## 60                   Corbel-Bold  TRUE  FALSE  FALSE         NA
    ## 61             Corbel-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 62                 Corbel-Italic FALSE   TRUE  FALSE         NA
    ## 63     CourierNewPS-BoldItalicMT  TRUE   TRUE  FALSE         NA
    ## 64           CourierNewPS-BoldMT  TRUE  FALSE  FALSE         NA
    ## 65         CourierNewPS-ItalicMT FALSE   TRUE  FALSE         NA
    ## 66                CourierNewPSMT FALSE  FALSE  FALSE         NA
    ## 67             DINAlternate-Bold  TRUE  FALSE  FALSE         NA
    ## 68             DINCondensed-Bold  TRUE  FALSE  FALSE         NA
    ## 69           FranklinGothic-Book FALSE  FALSE  FALSE         NA
    ## 70     FranklinGothic-BookItalic FALSE   TRUE  FALSE         NA
    ## 71         FranklinGothic-Medium FALSE  FALSE  FALSE         NA
    ## 72   FranklinGothic-MediumItalic FALSE   TRUE  FALSE         NA
    ## 73                      Gabriola FALSE  FALSE  FALSE         NA
    ## 74                       Georgia FALSE  FALSE  FALSE         NA
    ## 75                  Georgia-Bold  TRUE  FALSE  FALSE         NA
    ## 76            Georgia-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 77                Georgia-Italic FALSE   TRUE  FALSE         NA
    ## 78                    GillSansMT FALSE  FALSE  FALSE         NA
    ## 79               GillSansMT-Bold  TRUE  FALSE  FALSE         NA
    ## 80         GillSansMT-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 81             GillSansMT-Italic FALSE   TRUE  FALSE         NA
    ## 82                         Gulim FALSE  FALSE  FALSE         NA
    ## 83                        Impact FALSE  FALSE  FALSE         NA
    ## 84                 KhmerSangamMN FALSE  FALSE  FALSE         NA
    ## 85                   LaoSangamMN FALSE  FALSE  FALSE         NA
    ## 86                 LucidaConsole FALSE  FALSE  FALSE         NA
    ## 87             LucidaSansUnicode FALSE  FALSE  FALSE         NA
    ## 88              Luminari-Regular FALSE  FALSE  FALSE         NA
    ## 89                       Marlett FALSE  FALSE  FALSE         NA
    ## 90                        Meiryo FALSE  FALSE  FALSE         NA
    ## 91                   Meiryo-Bold  TRUE  FALSE  FALSE         NA
    ## 92             Meiryo-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 93                 Meiryo-Italic FALSE   TRUE  FALSE         NA
    ## 94            Microsoft-Yi-Baiti FALSE  FALSE  FALSE         NA
    ## 95             MicrosoftHimalaya FALSE  FALSE  FALSE         NA
    ## 96            MicrosoftSansSerif FALSE  FALSE  FALSE         NA
    ## 97                MicrosoftTaiLe FALSE  FALSE  FALSE         NA
    ## 98           MicrosoftTaiLe-Bold  TRUE  FALSE  FALSE         NA
    ## 99            Ming-Lt-HKSCS-ExtB FALSE  FALSE  FALSE         NA
    ## 100          Ming-Lt-HKSCS-UNI-H FALSE  FALSE  FALSE         NA
    ## 101                      MingLiU FALSE  FALSE  FALSE         NA
    ## 102                 MingLiU-ExtB FALSE  FALSE  FALSE         NA
    ## 103               MongolianBaiti FALSE  FALSE  FALSE         NA
    ## 104                    MS-Gothic FALSE  FALSE  FALSE         NA
    ## 105                    MS-Mincho FALSE  FALSE  FALSE         NA
    ## 106                   MS-PGothic FALSE  FALSE  FALSE         NA
    ## 107                   MS-PMincho FALSE  FALSE  FALSE         NA
    ## 108         MSReferenceSansSerif FALSE  FALSE  FALSE         NA
    ## 109         MSReferenceSpecialty FALSE  FALSE  FALSE         NA
    ## 110                    Odalisque FALSE  FALSE  FALSE         NA
    ## 111        PalatinoLinotype-Bold  TRUE  FALSE  FALSE         NA
    ## 112  PalatinoLinotype-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 113      PalatinoLinotype-Italic FALSE   TRUE  FALSE         NA
    ## 114       PalatinoLinotype-Roman FALSE  FALSE  FALSE         NA
    ## 115                     Perpetua FALSE  FALSE  FALSE         NA
    ## 116                Perpetua-Bold  TRUE  FALSE  FALSE         NA
    ## 117          Perpetua-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 118              Perpetua-Italic FALSE   TRUE  FALSE         NA
    ## 119                     PMingLiU FALSE  FALSE  FALSE         NA
    ## 120                PMingLiU-ExtB FALSE  FALSE  FALSE         NA
    ## 121                       SimHei FALSE  FALSE  FALSE         NA
    ## 122                       SimSun FALSE  FALSE  FALSE         NA
    ## 123                  SimSun-ExtB FALSE  FALSE  FALSE         NA
    ## 124                       Tahoma FALSE  FALSE  FALSE         NA
    ## 125                  Tahoma-Bold  TRUE  FALSE  FALSE         NA
    ## 126 TimesNewRomanPS-BoldItalicMT  TRUE   TRUE  FALSE         NA
    ## 127 TimesNewRomanPS-BoldItalicMT  TRUE   TRUE  FALSE         NA
    ## 128       TimesNewRomanPS-BoldMT  TRUE  FALSE  FALSE         NA
    ## 129       TimesNewRomanPS-BoldMT  TRUE  FALSE  FALSE         NA
    ## 130     TimesNewRomanPS-ItalicMT FALSE   TRUE  FALSE         NA
    ## 131     TimesNewRomanPS-ItalicMT FALSE   TRUE  FALSE         NA
    ## 132            TimesNewRomanPSMT FALSE  FALSE  FALSE         NA
    ## 133            TimesNewRomanPSMT FALSE  FALSE  FALSE         NA
    ## 134                  Trattatello FALSE  FALSE  FALSE         NA
    ## 135         Trebuchet-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 136                  TrebuchetMS FALSE  FALSE  FALSE         NA
    ## 137             TrebuchetMS-Bold  TRUE  FALSE  FALSE         NA
    ## 138           TrebuchetMS-Italic FALSE   TRUE  FALSE         NA
    ## 139                 TwCenMT-Bold  TRUE  FALSE  FALSE         NA
    ## 140           TwCenMT-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 141               TwCenMT-Italic FALSE   TRUE  FALSE         NA
    ## 142              TwCenMT-Regular FALSE  FALSE  FALSE         NA
    ## 143                      Verdana FALSE  FALSE  FALSE         NA
    ## 144                      Verdana FALSE  FALSE  FALSE         NA
    ## 145                 Verdana-Bold  TRUE  FALSE  FALSE         NA
    ## 146                 Verdana-Bold  TRUE  FALSE  FALSE         NA
    ## 147           Verdana-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 148           Verdana-BoldItalic  TRUE   TRUE  FALSE         NA
    ## 149               Verdana-Italic FALSE   TRUE  FALSE         NA
    ## 150               Verdana-Italic FALSE   TRUE  FALSE         NA
    ## 151                     Webdings FALSE  FALSE  FALSE         NA
    ## 152            Wingdings-Regular FALSE  FALSE  FALSE         NA
    ## 153            Wingdings-Regular FALSE  FALSE  FALSE         NA
    ## 154                   Wingdings2 FALSE  FALSE  FALSE         NA
    ## 155                   Wingdings2 FALSE  FALSE  FALSE         NA
    ## 156                   Wingdings3 FALSE  FALSE  FALSE         NA
    ## 157                   Wingdings3 FALSE  FALSE  FALSE         NA
    ## 158                          NHL FALSE  FALSE  FALSE         NA

Background Image
================

[1] <a href="https://www.investopedia.com/terms/m/mooreslaw.asp" class="uri">https://www.investopedia.com/terms/m/mooreslaw.asp</a>
