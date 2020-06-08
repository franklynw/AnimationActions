# Animation Actions

An extension to CAAnimation which gives you animation start & finish actions

## Compatibility
 - iOS 12.4 (though easily adaptable for earlier versions)

## Features

 - Have 'animation began' closures:

       myAnimation.began = {
          // do something now the animation is starting
       })
 
 - Have 'animation finished' closures:

       myAnimation.finished = { animation, finished in
          // do something now the animation has finished
       })
       
NB - currently, adding either of these will remove any delegate which has already been set for the animation, so don't use if you're also using CAAnimationDelegate functions. Conversely, if you add an action and then set the animation delegate to something else, the action won't be triggered.


## Licence

MIT
