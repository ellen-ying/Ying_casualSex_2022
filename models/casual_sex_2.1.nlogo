;; Model 2: revised logic for mating, short-term and long-term parallel, with desirability modelled

turtles-own [
  desirability               ;; the turtles' mating desireability
  mating-standard            ;; the desireability standard for a short-term mate
  coupled?                   ;; boolean variable for the relaitonship status
  partner                    ;; the turtles long-term partner
  short-term-likelihood      ;; the likelihood of an agent engaging in short-term mating
  short-term-mate?           ;; whether the turtles decide to engage in short-term mating
  short-term-count           ;; count of short-term mating
  short-term-history         ;; a list of turtles' short-term mating partner
  number-of-partner-short    ;; number of turtles' short-term mating partner
  original-x                 ;; x coordinate when spawned
  original-y                 ;; y coordinate when spawned
]

;;;;;;;;;;;;;;;;;;;;;;;
;;; setup procedure ;;;
;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  create-turtles 300 [
    set shape "person"
    set size 1

    ;; set the desireability a random floating point from
    ;; a normal distribution with a mean of 5
    ;; and a standard deviation of 1.5
    set desirability random-normal 5 1.5

    set coupled? false ;; start without a partner
    set partner nobody
    set short-term-mate? false
    set short-term-history [] ;; set an empty list to start with
    set number-of-partner-short 0 ;; set the number to 0 to start with

    setxy random-xcor random-ycor
    ;; record the spawning point of a turtle
    set original-x xcor
    set original-y ycor
  ]
  set-sex ;; set the sex of turtles
  set-short-term-likelihood ;; set the likelihood of short-term mating
  set-standard ;; set the desirability standard for a short-term mate

  reset-ticks
end

to set-sex
  ;; read the number of males from the slider bar
  ;; two colors indicate different sexes
  ;; turqoise turtles are males, orange ones are females
  ask turtles [ set color orange ]
  ask n-of number-of-male turtles [ set color turquoise ]
end

to set-short-term-likelihood
  ;; read the likelihood setting from the slider bars
  ask turtles with [ color = turquoise ] [ set short-term-likelihood male-short-term-likelihood ]
  ask turtles with [ color = orange ] [ set short-term-likelihood female-short-term-likelihood ]
end

to set-standard
  ;; read the mating standard from the slider bars
  ask turtles with [ color = turquoise ] [ set mating-standard male-standard ]
  ask turtles with [ color = orange ] [ set mating-standard female-standard ]
end


;;;;;;;;;;;;;;;;;;;;
;;; go procedure ;;;
;;;;;;;;;;;;;;;;;;;;

to go
  ask turtles [
    ;; turtle randomly move around if not coupled
    if not coupled? [
      move
    ]
    ;; all turtles decide whether to have short-term mating
    decide-short-term
  ]

  ;; female turtles make decisions on mating-behaviors
  ask turtles with [ color = orange ] [
    mate
  ]

  ask turtles [
    update-sexual-partner  ;; turtles update their number of short-term mating partners
    update-likelihood ;; turtles updating the likelihood for short-term mating
  ]

  update-plot ;; plotting
  tick
end

to move ;; turtle procedure: to randomly move around the spawning point
  ;; check whether the turtle is away from the spawning point
  let out-range-x? (xcor > original-x + movement-range) or (xcor < original-x - movement-range)
  let out-range-y? (ycor > original-y + movement-range) or (ycor < original-y - movement-range)

  ;; if it is, facing the spawning point and move
  ;; if it's not, turn randomly and move
  ifelse out-range-x? or out-range-y? [
    facexy original-x original-y ][
    rt random-float 180 ]
  fd random-float movement-range / 2
end

to decide-short-term ;; turtle procedure: to decide on short-term mating
  ;; randomly generate a number less than 100
  ;; if it's lower than the likelihood we set, the turtle decide to have short-term mating
  if random 100 < short-term-likelihood [ set short-term-mate? true ]
end


to mate ;; turtle procedure: to decide on mating behaviors
  ;; regardless of being coupled or not, decide whether to have short-term mating
  short-term-mate

  ;; if a turtle is not coupled, decide whether to form long-term relationship
  if not coupled? [
    long-term-mate
  ]
end

to short-term-mate ;; turtle procedure: check to have short-term mating
  ;; to check if there someone else nearby with a different gender and who is not my partner
  let target one-of other turtles-here
    with [ color = turquoise and partner != myself ]

  ;; if there is someone nearby
  if (target != nobody) [

    ;; check if this person meets my standard
    let meet-standard? [ desirability ] of target > mating-standard and
                       [ desirability ] of self > [ mating-standard ] of target

    ;; if both of us feel like having sex and we meet each others' standards, we do it
    if (short-term-mate?) and ([short-term-mate?] of target) and meet-standard? [
      set short-term-count short-term-count + 1
      ask target [ set short-term-count short-term-count + 1 ]

       ;; if my partner is not in my list of sexual patners, I add him
      if not member? target short-term-history [
        set short-term-history fput target short-term-history
      ]
      ;; if I am not in my partner's list, he adds me
      if not member? self [short-term-history] of target [
        ask target [ set short-term-history fput myself short-term-history ]
      ]
    ]
  ]
end

to long-term-mate ;; turtle procedure: check to have long-term mating
  ;; check to see whether there is an uncoupled individual of
  ;; a different gender staying close to myself
  let potential-partner one-of other turtles-here
    with [ not coupled? and color = turquoise ]

  ;; if there is and the turtle feels like doing so, form a long-term relationship
  if (potential-partner != nobody) and (random-float 100 < long-term-likelihood) [
    set partner potential-partner ;; register the partner
    set coupled? true ;; change the coupling status
    move-to patch-here ;; keep the couple in the center of the patch
    set pcolor grey - 3 ;; color the patch to visually show the relationship status

    ask partner [
      set partner myself
      set coupled? true
      move-to patch-here
      setxy xcor - 1 ycor
      set pcolor grey - 3
    ]
  ]
end

to update-sexual-partner ;; turtle procedure: count the number of sexual partners
  set number-of-partner-short length short-term-history
end

to update-likelihood ;; turtle procedure: update the likelihood of shorting-term mating
  ;; decrease the short-terming likelihood to 1/3 if coupled
  ask turtles with [ color = turquoise and coupled?] [
    if short-term-likelihood = male-short-term-likelihood [
      set short-term-likelihood (short-term-likelihood / 3) ]
  ]
  ask turtles with [ color = orange and coupled?] [
    if short-term-likelihood = female-short-term-likelihood [
      set short-term-likelihood (short-term-likelihood / 3) ]
  ]
end

to update-plot ;; plotting procedure
  ;; plotting the relative frequency of coupled individuals
  set-current-plot "Coupled vs. time"
  set-current-plot-pen "Male"
  plot ((count turtles with [coupled?]) / 2) / number-of-male
  set-current-plot-pen "Female"
  plot ((count turtles with [coupled?]) / 2) / (300 - number-of-male)
  set-current-plot-pen "Total"
  plot (count turtles with [coupled?]) / 300

  ;; plotting the relative frequency of individuals who've ever had short-term mating
  set-current-plot "Had short-term"
  set-current-plot-pen "Male"
  plot count turtles with [ color = turquoise and short-term-count > 0 ] / number-of-male
  set-current-plot-pen "Female"
  plot count turtles with [ color = orange and short-term-count > 0 ] / (300 - number-of-male)
  set-current-plot-pen "Total"
  plot count turtles with [ short-term-count > 0 ] / 300

  ;; plotting the mean number of short-term sexual partners among all males and females
  set-current-plot "Sexual partner 1"
  set-current-plot-pen "Male"
  plot mean [number-of-partner-short] of turtles with [ color = turquoise ]
  set-current-plot-pen "Female"
  plot mean [number-of-partner-short] of turtles with [ color = orange ]

  ;; plotting the mean number of short-term sexual partners among males and females who've ever had short-term mating
  set-current-plot "Sexual partner 2"
  ifelse (count turtles with [ short-term-count > 0 ] != 0) [
    set-current-plot-pen "Male"
    plot (sum [number-of-partner-short] of turtles with [ color = turquoise ])
      / (count turtles with [ color = turquoise and short-term-count > 0 ])
    set-current-plot-pen "Female"
    plot (sum [number-of-partner-short] of turtles with [ color = orange ])
      / (count turtles with [ color = orange and short-term-count > 0 ])
  ] [
    set-current-plot-pen "Male"
    plot 0
    set-current-plot-pen "Female"
    plot 0
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
239
35
676
473
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
50
354
116
387
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
77
391
158
424
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
120
354
183
387
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
196
219
229
male-short-term-likelihood
male-short-term-likelihood
0
100
20.0
1
1
%
HORIZONTAL

SLIDER
14
237
220
270
female-short-term-likelihood
female-short-term-likelihood
0
100
8.0
1
1
%
HORIZONTAL

MONITOR
397
484
490
529
Male number
sum [short-term-count] of turtles with [color = turquoise]
17
1
11

MONITOR
509
484
617
529
Female number
sum [short-term-count] of turtles with [color = orange]
17
1
11

TEXTBOX
242
485
395
527
Number of short-term mating in each gender (for debugging purpose)
11
0.0
1

PLOT
687
251
893
429
Sexual partner 1
T
N
0.0
10.0
0.0
5.0
true
true
"" ""
PENS
"Male" 1.0 0 -14835848 true "" ""
"Female" 1.0 0 -955883 true "" ""

SLIDER
54
118
187
151
movement-range
movement-range
1
15
3.0
1
1
NIL
HORIZONTAL

TEXTBOX
688
435
895
477
The mean number of short-term sexual partners average over all males and females
11
0.0
1

SLIDER
45
81
196
114
number-of-male
number-of-male
0
300
150.0
1
1
NIL
HORIZONTAL

SLIDER
38
157
200
190
long-term-likelihood
long-term-likelihood
0
100
10.0
1
1
NIL
HORIZONTAL

PLOT
685
45
891
227
Coupled vs. time
T
Freq
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Male" 1.0 0 -14835848 true "" ""
"Female" 1.0 0 -955883 true "" ""
"Total" 1.0 0 -16777216 true "" ""

SLIDER
53
277
184
310
male-standard
male-standard
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
53
314
184
347
female-standard
female-standard
0
10
7.0
1
1
NIL
HORIZONTAL

PLOT
902
252
1115
429
Sexual partner 2
NIL
NIL
0.0
10.0
0.0
5.0
true
true
"" ""
PENS
"Male" 1.0 0 -14835848 true "" ""
"Female" 1.0 0 -955883 true "" ""

PLOT
904
46
1114
226
Had short-term
T
Freq
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Male" 1.0 0 -14835848 true "" ""
"Female" 1.0 0 -955883 true "" ""
"Total" 1.0 0 -16777216 true "" ""

TEXTBOX
913
435
1119
494
The mean number of short-term sexual partners average over males and females who've ever had short-term mating
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
