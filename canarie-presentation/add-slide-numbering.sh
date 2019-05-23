#!/bin/sh -x
# Add automatic slide numbering to reveal.js html slides.

# Usage: add-slide-numbering.sh presentation.slides.html

# https://github.com/hakimel/reveal.js/#slide-number
vim '+/Reveal.initialize/' '+s@Reveal.initialize({@\0\rslideNumber: "c/t",@' '+:wq' "$@"
