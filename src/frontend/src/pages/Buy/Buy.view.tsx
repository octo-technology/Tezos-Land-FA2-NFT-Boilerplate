import { LandMap } from "app/App.components/LandMap/LandMap.view";
import * as React from "react";
import { TokenOnSale } from './Buy.controller'
import { BuyLandBottom, BuyLandButton, BuyLandFirstRow, BuyLandLocation, BuyLandOnSale, BuyLandSecondRow, BuyLandStyled } from './Buy.style'

type BuyViewProps = {
  buyTokenCallback: ({}: any) => void
  tokensOnSale: TokenOnSale[]
}

export const BuyView = ({ buyTokenCallback: buyToken, tokensOnSale }: BuyViewProps) => {
  return (
    <>
      {tokensOnSale.map((myToken) => (
        <BuyLand key={myToken.id} buyTokenCallback={buyToken} tokenOnSale={myToken} />
      ))}
    </>
  )
}

const BuyLand = ({ buyTokenCallback, tokenOnSale }: {buyTokenCallback: ({}: any) => void, tokenOnSale: TokenOnSale }) => {
  return (    
  <BuyLandStyled key={tokenOnSale.id}>
    <LandMap x={tokenOnSale.position.x} y={tokenOnSale.position.y} />

    <BuyLandBottom>
      <BuyLandFirstRow>
        <BuyLandLocation>
          <svg>
            <use xlinkHref="/icons/sprites.svg#location" />
          </svg>
          <div>{`${tokenOnSale.position.x}, ${tokenOnSale.position.y}`}</div>
        </BuyLandLocation>
        <BuyLandOnSale onSale={tokenOnSale.onSale} > On sale for {tokenOnSale.price} ꜩ </BuyLandOnSale>
      </BuyLandFirstRow>

      <BuyLandSecondRow>
      {tokenOnSale.tokenOwnedByUser ? <div>You are the owner</div> : <BuyLandButton onClick={() =>
            buyTokenCallback({
              token_id: tokenOnSale.id,
              price:tokenOnSale.price,
            })
          }>Buy</BuyLandButton> }
      </BuyLandSecondRow>
    </BuyLandBottom>
  </BuyLandStyled>
  );
}
