import { BuyLandMap } from "app/App.components/BuyLandMap/BuyLandMap.view";
import * as React from "react";
import { useState } from "react";
import { useAlert } from 'react-alert'
import { TokenOnSale } from "./Buy.controller";
// prettier-ignore
import { BuyLandBottom, BuyLandSecondRow, BuyLandButton, BuyLandCoordinateInput, BuyLandFirstRow, BuyLandLocation, BuyLandPriceInput, BuyLandStyled as BuyLandStyled, BuyStyled as BuyStyled } from "./Buy.style";

type BuyProps = {
  token_id: number;
  price: number;
};

type BuyViewProps = {
  buyTokenCallback: (sellProps: BuyProps) => Promise<any>;
  tokensOnSale: TokenOnSale[];
  connectedUser: string;
};

export const BuyView = ({ buyTokenCallback: buyTokenCallback, tokensOnSale, connectedUser }: BuyViewProps) => {
  return (
    <BuyStyled>
      <BuyLand buyTokenCallback={buyTokenCallback}
        tokensOnSale={tokensOnSale}
        connectedUser={connectedUser}/>
    </BuyStyled>
  );
};

const BuyLand = ({ buyTokenCallback: buyTokenCallback,
  tokensOnSale, connectedUser }: BuyViewProps) => {
  const [landPrice, setPrice] = useState<string>("");
  const [xCoordinate, setXCoordinate] = useState<number>(0);
  const [yCoordinate, setYCoordinate] = useState<number>(0);
  const [selectedToken, setSelectedToken] = useState<number>(1);
  const [selectedTokenPrice, setSelectedTokenPrice] = useState<number>(0);
  const alert = useAlert()

  return (
    <BuyLandStyled>
      <BuyLandMap
        x={xCoordinate}
        y={yCoordinate}
        landsOnSale={tokensOnSale}
        setXCoordinatesCallback={setXCoordinate}
        setYCoordinatesCallback={setYCoordinate}
        setSelectedTokenCallback={setSelectedToken}
        setSelectedTokenPriceCallback={setSelectedTokenPrice}
      />

      <BuyLandBottom>
        <BuyLandFirstRow>
          <BuyLandLocation>
            <svg>
              <use xlinkHref="/icons/sprites.svg#location" />
            </svg>
            <BuyLandCoordinateInput
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
            ></BuyLandCoordinateInput>
            <BuyLandCoordinateInput
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
            ></BuyLandCoordinateInput>
          </BuyLandLocation>
        </BuyLandFirstRow>

        <BuyLandSecondRow>
          {tokensOnSale.filter(token => String(token.id) == String(selectedToken)).length == 0 ? (<>This land is not on sale </>) : (<>{
            tokensOnSale.filter(token => String(token.id) == String(selectedToken)).filter(token => token.owner == connectedUser).length > 0 ? (<> You are the owner </>) : (<> <BuyLandPriceInput
              value={selectedTokenPrice}
              placeholder="Price"
            />
              <BuyLandButton
                onClick={() => {
                  var tokenToSell = tokensOnSale.filter(token => token.position.x == xCoordinate && token.position.y == yCoordinate);
                  if (tokenToSell.length > 0) {
                    buyTokenCallback({
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
                Buy this land
          </BuyLandButton> </>)
          }  </>)}



        </BuyLandSecondRow>

      </BuyLandBottom>
    </BuyLandStyled>
  );
};


