import { BuyLandMap } from "app/App.components/BuyLandMap/BuyLandMap.view";
import * as React from "react";
import { useState } from "react";
import { useAlert } from 'react-alert'
import { TokenOnSale } from "./Buy.controller";
// prettier-ignore
import { BuyLandBottom, BuyOwnerDiv, BuyLandSecondRow, BuyLandThirdRow, BuyLandButton, BuyLandCoordinateInput, BuyLandFirstRow, BuyLandLocation, BuyLandPriceInput, BuyLandStyled as BuyLandStyled, BuyStyled as BuyStyled, BuyLandOwner, BuyLandFourthRow, BuyLandId } from "./Buy.style";

type BuyProps = {
  token_id: number;
  price: number;
};

type BuyViewProps = {
  buyTokenCallback: (sellProps: BuyProps) => Promise<any>;
  setTransactionPendingCallback: (b: boolean) => void;
  setSelectedTokenCallback: (p : any) => void;
  selectedToken: any;
  transactionPending: boolean;
  tokensOnSale: TokenOnSale[];
  connectedUser: string;
};

export const BuyView = ({ buyTokenCallback: buyTokenCallback, tokensOnSale, connectedUser, setTransactionPendingCallback, transactionPending, selectedToken, setSelectedTokenCallback }: BuyViewProps) => {
  return (
    <BuyStyled>
      <BuyLand buyTokenCallback={buyTokenCallback}
        tokensOnSale={tokensOnSale}
        connectedUser={connectedUser}
        transactionPending={transactionPending}
        setTransactionPendingCallback={setTransactionPendingCallback}
        setSelectedTokenCallback={setSelectedTokenCallback}
        selectedToken={selectedToken}
        />
    </BuyStyled>
  );
};

const BuyLand = ({ buyTokenCallback: buyTokenCallback,
  tokensOnSale, connectedUser, transactionPending, setTransactionPendingCallback, selectedToken, setSelectedTokenCallback }: BuyViewProps) => {
  const [xCoordinate, setXCoordinate] = useState<number>(tokensOnSale[0].position.x);
  const [yCoordinate, setYCoordinate] = useState<number>(tokensOnSale[0].position.y);
  React.useEffect(() => {
    if (!!selectedToken){
        var selectedTokenOwned = tokensOnSale.filter(token => token.id === yCoordinate * 10 + xCoordinate + 1)
        if (selectedTokenOwned.length > 0){
          setSelectedTokenCallback(selectedTokenOwned[0])
        } else {
          setSelectedTokenCallback(undefined)
        }
    }

  }, [selectedToken, tokensOnSale])
  const alert = useAlert()

  return (
    <BuyLandStyled>
      <BuyLandMap
        x={xCoordinate}
        y={yCoordinate}
        landsOnSale={tokensOnSale}
        setXCoordinatesCallback={setXCoordinate}
        setYCoordinatesCallback={setYCoordinate}
        setSelectedTokenCallback={setSelectedTokenCallback}
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
        <BuyLandFourthRow>
            <BuyLandId>
            <svg>
              <use xlinkHref="/icons/sprites.svg#location" />
            </svg>
            <div>{`${xCoordinate + 1 + 10 * yCoordinate}`}</div>
            </BuyLandId>
        </BuyLandFourthRow>
        <BuyLandSecondRow>
          <BuyOwnerDiv>
            {selectedToken == undefined ? "" :  (<> 
        <BuyLandOwner>
        <svg>
              <use xlinkHref="/icons/sprites.svg#location" />
            </svg>
            <div>{`${selectedToken.owner}`}</div>
        </BuyLandOwner>
        
        </>)}
          </BuyOwnerDiv>
        </BuyLandSecondRow>
        <BuyLandThirdRow>
          {selectedToken == undefined ? (<>This land is not on sale </>) : (<>{
            selectedToken.owner == connectedUser ? (<> You are the owner </>) : (<>
              <BuyLandPriceInput
                value={selectedToken.price / 1000000 + " ꜩ"}
                placeholder="Price"
              />
              <BuyLandButton
                onClick={() => {
                  if (transactionPending) {
                    alert.info("A transaction is pending. Try again later")
                    console.info("A transaction is pending. Try again later")
                  } else {
                    buyTokenCallback({
                      token_id: selectedToken.id,
                      price: parseFloat(String(selectedToken.price)),
                    }).then(e => {
                      alert.info("Buying land ...")
                      setTransactionPendingCallback(true)
                      e.confirmation().then((e: any) => {
                        alert.success("Land bought", {
                          onOpen: () => {
                            setSelectedTokenCallback({ ...selectedToken, onSale: false });
                            setTransactionPendingCallback(false)
                          }
                        })

                        return e
                      })
                      return e
                    }).catch((e: any) => {
                      alert.show(e.message)
                      console.error(e.message)
                    })
                  }

                }

                }
              >
                Buy this land
          </BuyLandButton> </>)
          }  </>)}



        </BuyLandThirdRow>

      </BuyLandBottom>
    </BuyLandStyled>
  );
};


