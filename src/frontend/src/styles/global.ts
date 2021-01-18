import { createGlobalStyle } from 'styled-components/macro'

import { placeholderColor, textColor } from './colors'

export const GlobalStyle = createGlobalStyle`
* {
  box-sizing: border-box;
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
`
