import { LandMap } from "app/App.components/LandMap/LandMap.view";
import * as React from "react";
import { useAlert } from 'react-alert'

import { TokenOnSale } from "./Buy.controller";
// prettier-ignore
import { BuyLandBottom, BuyLandButton, BuyLandFirstRow, BuyLandLocation, BuyLandOnSale, BuyLandSecondRow, BuyLandStyled, BuyStyled } from "./Buy.style";

type BuyProps = {
  token_id: number;
  price: number;
};

type BuyViewProps = {
  buyTokenCallback: (buyProps: BuyProps) => Promise<any>;
  tokensOnSale: TokenOnSale[];
};

export const BuyView = ({
  buyTokenCallback: buyToken,
  tokensOnSale,
}: BuyViewProps) => {
  return (
    <BuyStyled>
      {tokensOnSale.map((myToken) => (
        <BuyLand
          key={myToken.id}
          buyTokenCallback={buyToken}
          tokenOnSale={myToken}
        />
      ))}
    </BuyStyled>
  );
};

const BuyLand = ({
  buyTokenCallback,
  tokenOnSale,
}: {
  buyTokenCallback: (buyProps: BuyProps) => Promise<any>;
  tokenOnSale: TokenOnSale;
}) => {
  const alert = useAlert()

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
          <BuyLandOnSale>
            On sale for {tokenOnSale.price / 1000000} ꜩ{" "}
          </BuyLandOnSale>
        </BuyLandFirstRow>

        <BuyLandSecondRow>
          {tokenOnSale.tokenOwnedByUser ? (
            <div>You are the owner</div>
          ) : (
            <BuyLandButton
              onClick={() =>
                buyTokenCallback({
                  token_id: tokenOnSale.id,
                  price: tokenOnSale.price,
                }).catch((e: any) => {
                  alert.show(e.message)
                  console.error(e.message)
                })
              }
            >
              Buy
            </BuyLandButton>
          )}
        </BuyLandSecondRow>
      </BuyLandBottom>
    </BuyLandStyled>
  );
};
