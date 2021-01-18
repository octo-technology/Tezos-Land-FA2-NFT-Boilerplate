import * as React from 'react'
import { Link } from 'react-router-dom'

//prettier-ignore
import { HomeButton, HomeButtonBorder, HomeButtonText, HomeHeader, HomeHeaderButtons, HomeHeaderGrid, HomeHeaderLeft, HomeHeaderRight, HomeStyled } from './Home.style'

export const HomeView = () => {
  return (
    <HomeStyled>
      <HomeHeader>
        <HomeHeaderGrid>
          <HomeHeaderLeft>
            <h1>Tezos NFT Boilerplate</h1>
            <p>
              Fork this repo, change the FA2 tokens properties to your liking and start your own NFT markeplace on
              Tezos!
            </p>
            <HomeHeaderButtons>
            <Link to="/buy">
              <HomeButton>
                <HomeButtonBorder />
                <HomeButtonText onClick={() => {}}>
                  <svg>
                    <use xlinkHref="/icons/sprites.svg#buy" />
                  </svg>
                  DEMO
                </HomeButtonText>
              </HomeButton>
            </Link>
            <a href="https://github.com/octo-technology/Tezos-Land-FA2-NFT-Boilerplate" target="_blank" rel="noreferrer">
              <HomeButton>
                <HomeButtonBorder />
                <HomeButtonText onClick={() => {}}>
                  <svg>
                    <use xlinkHref="/icons/sprites.svg#github" />
                  </svg>
                  GITHUB
                </HomeButtonText>
              </HomeButton>
            </a>
            </HomeHeaderButtons>
          </HomeHeaderLeft>
          <HomeHeaderRight>
            <img src="/images/land.svg" alt="land" />
          </HomeHeaderRight>
        </HomeHeaderGrid>
      </HomeHeader>
    </HomeStyled>
  )
}
