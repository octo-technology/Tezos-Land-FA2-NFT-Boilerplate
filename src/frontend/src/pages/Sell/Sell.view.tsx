import { Input } from 'app/App.components/Input/Input.controller'
import { HomeButton, HomeButtonBorder, HomeButtonText } from 'pages/Home/Home.style'
import * as React from 'react'
import { useState } from 'react'
import { Token } from './Sell.controller'
import { SellToken, SellTokenGrid } from './Sell.style'

type SellViewProps = {
  sellToken: ({}: any) => void
  myTokens: Token[]
}

export const SellView = ({ sellToken, myTokens }: SellViewProps) => {
  return (
    <>
      {myTokens.map((myToken) => (
        <SellLand key={myToken.token_id} sellToken={sellToken} myToken={myToken} />
      ))}
    </>
  )
}

const SellLand = ({ sellToken, myToken }: any) => {
  const [price, setPrice] = useState<string>('1')

  return (
    <SellToken key={myToken.token_id}>
      {myToken.name}
      <SellTokenGrid>
        <Input
          placeholder="Price"
          onChange={(e) => setPrice(e.target.value)}
          onBlur={() => {}}
          value={price}
          icon="sell"
        />
        <HomeButton>
          <HomeButtonBorder />
          <HomeButtonText
            onClick={() =>
              sellToken({
                token_id: myToken.token_id,
                price: parseFloat(price),
              })
            }
          >
            <svg>
              <use xlinkHref="/icons/sprites.svg#map" />
            </svg>
            {`SELL LAND`}
          </HomeButtonText>
        </HomeButton>
      </SellTokenGrid>
    </SellToken>
  )
}
