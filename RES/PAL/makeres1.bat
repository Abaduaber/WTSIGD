copy /b backs\st1\*.bmp %CD%
copy /b backs\st2\*.bmp %CD%
copy /b backs\st3\*.bmp %CD%
copy /b backs\st4\*.bmp %CD%
copy /b backs\st5\*.bmp %CD%
copy /b backs\st6\*.bmp %CD%
copy /b backs\st7\*.bmp %CD%
copy /b backs\st8\*.bmp %CD%
copy /b pinkiepie\bpp\*.bmp %CD%
copy /b pinkiepie\fpp\*.bmp %CD%
copy /b pinkiepie\spp\*.bmp %CD%
copy /b pinkiepie\cpp\*.bmp %CD%
copy /b psp\*.bmp %CD%
copy /b gts\*.bmp %CD%
copy /b ajd\*.bmp %CD%
copy /b ajs\*.bmp %CD%
copy /b misc\st01\*.bmp %CD%
copy /b misc\st04\*.bmp %CD%
copy /b misc\st05\*.bmp %CD%
copy /b misc\st06\*.bmp %CD%
copy /b misc\st07\*.bmp %CD%
copy /b rds\*.bmp %CD%
copy /b disc\*.bmp %CD%
copy /b discw\*.bmp %CD%
copy /b bnbnt\*.bmp %CD%
copy /b lyrat\*.bmp %CD%
copy /b thief\*.bmp %CD%
copy /b quie\*.bmp %CD%
copy /b ccher\*.bmp %CD%
copy /b drfly\*.bmp %CD%
copy /b wins\*.bmp %CD%
copy /b octavia\s\*.bmp %CD%
copy /b octavia\w\*.bmp %CD%
copy /b octavia\p\*.bmp %CD%
copy /b spike\*.bmp %CD%
copy /b luna\*.bmp %CD%
copy /b djpon\*.bmp %CD%
copy /b bdance\*.bmp %CD%
copy /b drunk\*.bmp %CD%
copy /b smoke\*.bmp %CD%
copy /b derpy\*.bmp %CD%
copy /b subwa\*.bmp %CD%
copy /b fs\*.bmp %CD%
copy /b expl\*.bmp %CD%
del *.lrf
del *.lpf
BRIGHT *.bmp -o -8 -common -bmp -colors 256
lgfc ep bpp1.bmp
rename bpp1.lpf pal.lpf
lgfc cm rlespr np bpp??.bmp
lgfc cm rlespr np fpp??.bmp
lgfc cm rlespr np spp?.bmp
lgfc cm rlespr np cpp??.bmp
lgfc cm rlespr np psp??.bmp
lgfc cm rlespr np gts??.bmp
lgfc cm rlespr np rds?.bmp
lgfc cm rlespr np ajd??.bmp
lgfc cm rlespr np ajs?.bmp
lgfc cm rlespr np sspike?.bmp
lgfc cm rlespr np disc?.bmp
lgfc cm rlespr np flower.bmp
lgfc cm rlespr np cloud_?.bmp
lgfc cm rlespr np duck.bmp
lgfc cm rlespr np octs?.bmp
lgfc cm rlespr np octw??.bmp
lgfc cm rlespr np octp?.bmp
lgfc cm rlespr np bnbnw??.bmp
lgfc cm rlespr np lyraw??.bmp
lgfc cm rlespr np lyras??.bmp
lgfc cm rlespr np derpy??.bmp
lgfc cm rlespr np discw??.bmp
lgfc cm rlespr np swpb1.bmp
lgfc cm rlespr np swpa??.bmp
lgfc cm rlespr np lunaf??.bmp
lgfc cm spr np pacman?.bmp
lgfc cm rlespr np suhov.bmp
lgfc cm img np mlamp?.bmp
lgfc cm img np st1_0?.bmp
lgfc cm img np st2_0?.bmp
lgfc cm img np st3_0?.bmp
lgfc cm rlespr np st4_?b.bmp
lgfc cm rlespr np st4_?f.bmp
lgfc cm rlespr np st5_?b.bmp
lgfc cm rlespr np st5_?f.bmp
lgfc cm rlespr np st6_?b.bmp
lgfc cm rlespr np st6_?f.bmp
lgfc cm spr np st7_?b.bmp
lgfc cm rlespr np st8_?b.bmp
lgfc cm rlespr np st8_?f.bmp
lgfc cm img np st9_?b.bmp
lgfc cm spr np mouse.bmp
lgfc cm rlespr np trainv.bmp
lgfc cm rlespr np light?.bmp
lgfc cm rlespr np lamp.bmp
lgfc cm rlespr np neuro.bmp
lgfc cm rlespr np bus.bmp
lgfc cm img np bar.bmp
lgfc cm rlespr np sma1.bmp
lgfc cm img np needjob.bmp
lgfc cm rlespr np cintab?.bmp
lgfc cm rlespr np thief??.bmp
lgfc cm rlespr np ccher??.bmp
lgfc cm rlespr np drfly?.bmp
lgfc cm rlespr np fsr??.bmp
lgfc cm rlespr np ques?.bmp
lgfc cm rlespr np sun.bmp
lgfc cm rlespr np djpon?.bmp
lgfc cm rlespr np dra?.bmp
lgfc cm rlespr np drb?.bmp
lgfc cm rlespr np smoke??.bmp
lgfc cm spr np spire?.bmp
lgfc cm spr np cgr?.bmp
lgfc cm rlespr np decks?.bmp
lgfc cm rlespr np bdance??.bmp
lgfc cm rlespr np sdance??.bmp
lgfc cm rlespr np fence.bmp
lgfc cm rlespr np table.bmp
lgfc cm img np djlogo.bmp
lgfc cm rlespr np subway.bmp
lgfc cm rlespr np damned.bmp
lgfc cm rlespr np dts.bmp
lgfc cm img np dtf.bmp
lgfc cm spr np gses.bmp
lgfc cm rlespr np throne.bmp
lgfc cm rlespr np celest.bmp
lgfc cm img np win???.bmp
lgfc cm img np robtab1.bmp
lgfc cm img np dtof.bmp
lgfc cm rlespr np woohoo.bmp
lgfc cm rlespr np expl??.bmp
lgfc cm img np sky?.bmp
lrfp am ST1.LRF *.LGF
lrfp am ST1.LRF TIMING.TXT
del *.bmp
del *.lgf