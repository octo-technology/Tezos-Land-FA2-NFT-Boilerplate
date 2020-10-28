import * as React from 'react'
import ReactDOM from 'react-dom'

import { App } from './app/App.controller'
import { unregister } from './serviceWorker'
import { GlobalStyle } from './styles'

import './styles/fonts.css'

export const Root = () => {
  return (
    <div>
      <GlobalStyle />
      <App />
    </div>
  )
}

const rootElement = document.getElementById('root')
ReactDOM.render(<Root />, rootElement)

unregister()
