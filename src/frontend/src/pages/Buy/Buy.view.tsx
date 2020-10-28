import { HomeButton, HomeButtonBorder, HomeButtonText } from 'pages/Home/Home.style'
import * as React from 'react'
import { TokenOnSale } from './Buy.controller'
import { BuyToken, BuyTokenGrid } from './Buy.style'

type BuyViewProps = {
  buyToken: ({}: any) => void
  tokensOnSale: TokenOnSale[]
}

export const BuyView = ({ buyToken, tokensOnSale }: BuyViewProps) => {
  return (
    <>
      {tokensOnSale.map((myToken) => (
        <BuyLand key={myToken.token_id} buyToken={buyToken} myToken={myToken} />
      ))}
    </>
  )
}

const BuyLand = ({ buyToken, myToken }: any) => {
  return (
    <BuyToken key={myToken.token_id}>
      {myToken.name}
      <BuyTokenGrid>
        <div>{`${myToken.price / 1000000} ꜩ`}</div>
        <HomeButton>
          <HomeButtonBorder />
          <HomeButtonText
            onClick={() =>
              buyToken({
                token_id: myToken.token_id,
                price: myToken.price / 1000000,
              })
            }
          >
            <svg>
              <use xlinkHref="/icons/sprites.svg#map" />
            </svg>
            {`BUY LAND`}
          </HomeButtonText>
        </HomeButton>
      </BuyTokenGrid>
    </BuyToken>
  )
}
