import { createGlobalStyle } from 'styled-components/macro'

import { fadeInFromLeft, slideLeftEnter, slideLeftExit, slideRightEnter, slideRightExit } from './animations'
import { backgroundColorDark, placeholderColor, textColor, primaryColor } from './colors'

export const GlobalStyle = createGlobalStyle`
* {
  box-sizing: border-box;
}

:root {
  --glitch-height: 100vh;
  --gap-horizontal: 10px;
  --gap-vertical: 5px;
  --time-anim: 6s;
  --delay-anim: 0s;
  --blend-mode-1: none;
  --blend-mode-2: none;
  --blend-mode-3: none;
  --blend-mode-4: none;
  --blend-mode-5: overlay;
  --blend-color-1: transparent;
  --blend-color-2: transparent;
  --blend-color-3: transparent;
  --blend-color-4: transparent;
  --blend-color-5: #af4949;
}

body {
  font-family: 'Proxima Nova', Helvetica, Arial, sans-serif;
  font-display: optional;
  margin: 0;
  padding: 0;
  background-color: #000;
  color: ${textColor};
  font-size: 14px;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

h1 {
  font-size: 40px;
  font-weight: 700;
  display: inline-block;
  margin: 20px 0px;
}

h2 {
  font-size: 20px;
  font-weight: normal;
  display: block;
  margin: 0;
}

h3 {
  font-size: 30px;
  font-weight: normal;
  display: block;
  margin: 0;
}

input {
  color: ${textColor};
  font-size: 14px;
}

::placeholder {
  color: ${placeholderColor};
  font-size: 14px;
}

*:focus {
  outline: none;
}

a {
  color: ${textColor};
  text-decoration: none;
  opacity: 1;
  transition: opacity 0.15s ease-in-out-out;
  will-change: opacity;
}

a:hover {
  opacity: 0.9;
}

p {
    font-family: "Proxima Nova", sans-serif;
    display: block;
    margin-block-start: 10px;
    margin-block-end: 10px;
    margin-inline-start: 0px;
    margin-inline-end: 0px;
}


code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New', monospace;
}

@keyframes autofill {
    0%,100% {
        color: ${textColor};
        background: ${backgroundColorDark};
    }
}

/* Change Autocomplete styles in Chrome*/
input:-webkit-autofill,
input:-webkit-autofill:hover, 
input:-webkit-autofill:focus,
textarea:-webkit-autofill,
textarea:-webkit-autofill:hover,
textarea:-webkit-autofill:focus,
select:-webkit-autofill,
select:-webkit-autofill:hover,
select:-webkit-autofill:focus {
    animation-delay: 300ms;
    animation-name: autofill;
    animation-fill-mode: both;
}

.appear {
  opacity: 0;
  will-change: transform, opacity;
  animation: ${fadeInFromLeft} ease-in-out 1;
  animation-fill-mode: forwards;
  animation-duration: 0.3s;
}

.slide-right-enter {
  opacity: 0;
}
.slide-right-enter-active {
  opacity: 1;
  transition: opacity 200ms;
}
.slide-right-exit {
  opacity: 1;
}
.slide-right-exit-active {
  opacity: 0;
  transition: opacity 200ms;
}

.slide-left-enter {
  opacity: 0;
}
.slide-left-enter-active {
  opacity: 1;
  transition: opacity 200ms;
}
.slide-left-exit {
  opacity: 1;
}
.slide-left-exit-active {
  opacity: 0;
  transition: opacity 200ms;
}

/* .slide-right-enter-active {
  animation-name: ${slideRightEnter};
  animation-duration: 300ms;
  animation-fill-mode: forwards;
  animation-timing-function: ease-in-out;
}

.slide-right-exit-active {
  animation-name: ${slideRightExit};
  animation-duration: 300ms;
  animation-fill-mode: forwards;
  animation-timing-function: ease-in-out;
}

.slide-left-enter-active {
  animation-name: ${slideLeftEnter};
  animation-duration: 300ms;
  animation-fill-mode: forwards;
  animation-timing-function: ease-in-out;
}

.slide-left-exit-active {
  animation-name: ${slideLeftExit};
  animation-duration: 300ms;
  animation-fill-mode: forwards;
  animation-timing-function: ease-in-out;
} */

.grecaptcha-badge {
  visibility: hidden;
}


*::-webkit-scrollbar {
  display: none;
  width: 0;
  height: 0;
  background: transparent;
}

*::-webkit-scrollbar-track, ::-webkit-scrollbar-corner, ::-webkit-scrollbar-track-piece {
  background: #00000000;
}

*::-webkit-scrollbar-thumb {
  background: ${primaryColor}80;
}

*::-webkit-scrollbar-thumb:hover {
  background: ${primaryColor}80;
}

.rc-slider {
  margin: 10px 0 23px 5px;
}

.rc-slider-handle {
  background-color: ${primaryColor}80 !important;
  border: solid 2px ${primaryColor}80 !important;
}

.rc-slider-handle:active {
    border-color: ${primaryColor}80 !important;
    box-shadow: 0 0 5px ${primaryColor}80 !important;
    cursor: grabbing;
}

.rc-slider-handle:hover {
    border-color: ${primaryColor}80 !important;
}

.rc-slider-rail {
  background-color: ${primaryColor}80 !important;
}

.rc-slider-track {
  background-color: ${primaryColor} !important;
  box-shadow: 0px 0px 25px ${primaryColor}80, 0px 0px 15px ${primaryColor}80;
}

.rc-slider-dot {
  background-color: ${primaryColor}30 !important;
  border: 2px solid ${primaryColor}30 !important;
}

.rc-slider-dot-active {
  background-color: ${primaryColor} !important;
  border-color: ${primaryColor} !important;
  drop-shadow: 0px 0px 25px ${primaryColor}80, 0px 0px 15px ${primaryColor}80;
}

.rc-slider-mark-text {
  display: none !important;
}

`
