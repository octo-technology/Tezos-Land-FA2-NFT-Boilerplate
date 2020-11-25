import { LandMap } from "app/App.components/LandMap/LandMap.view";
import * as React from "react";
import { useState } from "react";

import { Token } from "./Sell.controller";
// prettier-ignore
import { SellLandBottom, SellLandButton, SellLandFirstRow, SellLandLocation, SellLandOnSale, SellLandPriceInput, SellLandSecondRow, SellLandStyled } from "./Sell.style";

type SellViewProps = {
  sellTokenCallback: ({}: any) => void;
  myTokens: Token[];
};

export const SellView = ({ sellTokenCallback, myTokens }: SellViewProps) => {
  return (
    <>
      {myTokens.map((myToken) => (
        <SellLand
          key={myToken.id}
          sellTokenCallback={sellTokenCallback}
          myToken={myToken}
        />
      ))}
    </>
  );
};

const SellLand = ({
  sellTokenCallback,
  myToken,
}: {
  sellTokenCallback: ({}: any) => void;
  myToken: Token;
}) => {
  const [price, setPrice] = useState<string>("");

  return (
    <SellLandStyled key={myToken.id}>
      <LandMap x={myToken.position.x} y={myToken.position.y} />

      <SellLandBottom>
        <SellLandFirstRow>
          <SellLandLocation>
            <svg>
              <use xlinkHref="/icons/sprites.svg#location" />
            </svg>
            <div>{`${myToken.position.x}, ${myToken.position.y}`}</div>
          </SellLandLocation>
          <SellLandOnSale onSale={myToken.onSale} >{myToken.onSale ? `On sale for ${myToken.price}` : 'Not on sale'}</SellLandOnSale>
        </SellLandFirstRow>

        <SellLandSecondRow>
          <SellLandPriceInput value={price} onChange={(e) => setPrice(e.target.value)} placeholder="Enter price" />
          <SellLandButton onClick={() =>
              sellTokenCallback({
                token_id: myToken.id,
                price: parseFloat(price),
              })
            }>Sell</SellLandButton>
        </SellLandSecondRow>
      </SellLandBottom>
    </SellLandStyled>
  );
};
