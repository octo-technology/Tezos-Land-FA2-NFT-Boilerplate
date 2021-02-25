import { SellLandMap } from "app/App.components/SellLandMap/SellLandMap.view";
import * as React from "react";
import { useState } from "react";
import { useAlert } from 'react-alert'
import { Token } from "./Sell.controller";
// prettier-ignore
import { SellLandBottom, SellLandSecondRow, CancelSaleButton, SellLandButton, SellLandCoordinateInput, SellLandFirstRow, SellLandLocation, SellLandPriceInput, SellLandStyled, SellStyled } from "./Sell.style";

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

export const SellView = ({ sellTokenCallback, cancelSaleCallback, myTokens }: SellViewProps) => {
  return (
    <SellStyled>
      <SellLand sellTokenCallback={sellTokenCallback} cancelSaleCallback={cancelSaleCallback}
        myTokens={myTokens} />
    </SellStyled>
  );
};

const SellLand = ({ sellTokenCallback,
  cancelSaleCallback,
  myTokens }: SellViewProps) => {
  const [landPrice, setPrice] = useState<string>("");
  const [xCoordinate, setXCoordinate] = useState<number>(0);
  const [yCoordinate, setYCoordinate] = useState<number>(0);
  const [selectedToken, setSelectedToken] = useState<number>(1);
  const alert = useAlert()

  return (
    <SellLandStyled>
      <SellLandMap
        x={xCoordinate}
        y={yCoordinate}
        landsOwned={myTokens.map(token => [token.position.x, token.position.y])}
        setSelectedTokenCallback={setSelectedToken}
        setXCoordinatesCallback={setXCoordinate}
        setYCoordinatesCallback={setYCoordinate}
      />

      <SellLandBottom>
        <SellLandFirstRow>
          <SellLandLocation>
            <svg>
              <use xlinkHref="/icons/sprites.svg#location" />
            </svg>
            <SellLandCoordinateInput
              value={xCoordinate}
              onChange={(e) => {
                if (!isNaN(Number(e.target.value))) {
                  if (e.target.value) {
                    setXCoordinate(parseInt(e.target.value));
                  } else {
                    setXCoordinate(0);
                  }
                }
              }}
              placeholder="x"
            ></SellLandCoordinateInput>
            <SellLandCoordinateInput
              value={yCoordinate}
              onChange={(e) => {
                if (!isNaN(Number(e.target.value))) {
                  if (e.target.value) {
                    setYCoordinate(parseInt(e.target.value));
                  } else {
                    setYCoordinate(0);
                  }
                }
              }}
              placeholder="y"
            ></SellLandCoordinateInput>
          </SellLandLocation>
        </SellLandFirstRow>

        <SellLandSecondRow>
          {myTokens.filter(token => selectedToken == token.id).length == 0 ? (<> You don't own this land </>) : (<> {myTokens.filter(token => token.position.x == xCoordinate && token.position.y == yCoordinate)[0].onSale ? (
            <>
              <CancelSaleButton
                onClick={() =>
                  cancelSaleCallback({
                    token_id: myTokens.filter(token => token.position.x == xCoordinate && token.position.y == yCoordinate)[0].id,
                    price: myTokens.filter(token => token.position.x == xCoordinate && token.position.y == yCoordinate)[0].price,
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
                  value={landPrice}
                  onChange={(e) => setPrice(e.target.value)}
                  placeholder="Price"
                />
                <SellLandButton
                  onClick={() => {
                    var tokenToSell = myTokens.filter(token => token.position.x == xCoordinate && token.position.y == yCoordinate);
                    if (tokenToSell.length > 0) {
                      sellTokenCallback({
                        token_id: tokenToSell[0].id,
                        price: parseFloat(landPrice),
                      }).catch((e: any) => {
                        alert.show(e.message)
                        console.error(e.message)
                      })

                    } else {
                      alert.show("You don't own this token. You cannot sell it")
                      console.error("You don't own this token. You cannot sell it")
                    }
                  }

                  }
                >
                  Sell this land
        </SellLandButton>
              </>
            )} </>)}

        </SellLandSecondRow>

      </SellLandBottom>
    </SellLandStyled>
  );
};
