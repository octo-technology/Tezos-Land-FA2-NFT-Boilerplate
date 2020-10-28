import * as React from 'react'
import { Link } from 'react-router-dom'

//prettier-ignore
import { HomeButton, HomeButtonBorder, HomeButtonText, HomeHeader, HomeHeaderGrid, HomeHeaderLeft, HomeHeaderRight, HomeStyled } from './Home.style'

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
            <Link to="/buy">
              <HomeButton>
                <HomeButtonBorder />
                <HomeButtonText onClick={() => {}}>
                  <svg>
                    <use xlinkHref="/icons/sprites.svg#buy" />
                  </svg>
                  MARKETPLACE
                </HomeButtonText>
              </HomeButton>
            </Link>
          </HomeHeaderLeft>
          <HomeHeaderRight>
            <img src="/images/land.svg" alt="land" />
          </HomeHeaderRight>
        </HomeHeaderGrid>
      </HomeHeader>
    </HomeStyled>
  )
}
