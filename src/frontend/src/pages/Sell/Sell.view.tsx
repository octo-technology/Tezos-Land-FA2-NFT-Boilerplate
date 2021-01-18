import { LandMap } from "app/App.components/LandMap/LandMap.view";
import * as React from "react";
import { useState } from "react";
import { useAlert } from 'react-alert'

import { Token } from "./Sell.controller";
// prettier-ignore
import { CancelSaleButton, SellLandBottom, SellLandButton, SellLandFirstRow, SellLandLocation, SellLandOnSale, SellLandPriceInput, SellLandSecondRow, SellLandStyled, SellStyled } from "./Sell.style";

type SellPorps = {
  token_id: number;
  price: number;
};

type CancelPorps = {
  token_id: number;
  price: number;
};

type SellViewProps = {
  sellTokenCallback: (sellProps: SellPorps) => Promise<any>;
  cancelSaleCallback: (cancelProps: CancelPorps) => Promise<any>;
  myTokens: Token[];
};

export const SellView = ({
  sellTokenCallback,
  cancelSaleCallback,
  myTokens,
}: SellViewProps) => {
  return (
    <SellStyled>
      {myTokens.map((myToken) => (
        <SellLand
          key={myToken.id}
          sellTokenCallback={sellTokenCallback}
          cancelSaleCallback={cancelSaleCallback}
          myToken={myToken}
        />
      ))}
    </SellStyled>
  );
};

const SellLand = ({
  sellTokenCallback,
  cancelSaleCallback,
  myToken,
}: {
  sellTokenCallback: (sellProps: SellPorps) => Promise<any>;
  cancelSaleCallback: (cancelProps: CancelPorps) => Promise<any>;
  myToken: Token;
}) => {
  const [price, setPrice] = useState<string>("");
  const alert = useAlert()

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
          <SellLandOnSale isOnSale={myToken.onSale}>
            {myToken.onSale
              ? `On sale for ${myToken.price / 1000000} ꜩ`
              : "Not on sale"}
          </SellLandOnSale>
        </SellLandFirstRow>

        <SellLandSecondRow>
          {myToken.onSale ? (
            <>
              <CancelSaleButton
                onClick={() =>
                  cancelSaleCallback({
                    token_id: myToken.id,
                    price: myToken.price,
                  }).catch((e: any) => {
                    alert.show(e.message)
                    console.error(e.message)
                  })
                }
              >
                Cancel sale
              </CancelSaleButton>
            </>
          ) : (
            <>
              <SellLandPriceInput
                value={price}
                onChange={(e) => setPrice(e.target.value)}
                placeholder="Enter price"
              />
              <SellLandButton
                onClick={() =>
                  sellTokenCallback({
                    token_id: myToken.id,
                    price: parseFloat(price),
                  }).catch((e: any) => {
                    alert.show(e.message)
                    console.error(e.message)
                  })
                }
              >
                Sell
              </SellLandButton>
            </>
          )}
        </SellLandSecondRow>
      </SellLandBottom>
    </SellLandStyled>
  );
};
