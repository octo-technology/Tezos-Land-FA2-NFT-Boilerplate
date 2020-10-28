import { DAppProvider } from 'dapp/dapp'
import { APP_NAME } from 'dapp/defaults'
import { Admin } from 'pages/Admin/Admin.controller'
import { Buy } from 'pages/Buy/Buy.controller'
import { Home } from 'pages/Home/Home.controller'
import { Sell } from 'pages/Sell/Sell.controller'
import React from 'react'
import { Route, BrowserRouter as Router, Switch } from 'react-router-dom'

import { Header } from './App.components/Header/Header.controller'
import { AppBg, AppContainer } from './App.style'

export const App = () => {
  return (
    <Router>
      <DAppProvider appName={APP_NAME}>
        <React.Suspense fallback={null}>
          <AppContainer>
            <AppBg />
            <Header />
            <Switch>
              <Route exact path="/">
                <Home />
              </Route>
              <Route exact path="/admin">
                <Admin />
              </Route>
              <Route exact path="/buy">
                <Buy />
              </Route>
              <Route exact path="/sell">
                <Sell />
              </Route>
            </Switch>
          </AppContainer>
        </React.Suspense>
      </DAppProvider>
    </Router>
  )
}