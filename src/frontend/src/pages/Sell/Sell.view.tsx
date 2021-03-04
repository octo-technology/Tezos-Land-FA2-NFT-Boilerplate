import { SellLandMap } from "app/App.components/SellLandMap/SellLandMap.view";
import * as React from "react";
import { useState } from "react";
import { useAlert } from 'react-alert'
import { Token } from "./Sell.controller";
// prettier-ignore
import { SellLandBottom, SellLandSecondRow, SellLandId, SellLandOwner, CancelLandInput, CancelSaleButton, SellLandButton, SellLandCoordinateInput, SellLandFirstRow, SellLandLocation, SellLandPriceInput, SellLandStyled, SellStyled, SellLandThirdRow } from "./Sell.style";

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
  setTransactionPendingCallback: (b: boolean) => void;
  transactionPending: boolean;
  setSelectedTokenCallback: (token: any) => void;
  selectedToken: any;
  myTokens: Token[];
};

export const SellView = ({ sellTokenCallback, cancelSaleCallback, setTransactionPendingCallback, transactionPending, myTokens, setSelectedTokenCallback, selectedToken }: SellViewProps) => {
  return (
    <SellStyled>
      <SellLand sellTokenCallback={sellTokenCallback}
        cancelSaleCallback={cancelSaleCallback}
        myTokens={myTokens}
        setTransactionPendingCallback={setTransactionPendingCallback}
        transactionPending={transactionPending}
        setSelectedTokenCallback={setSelectedTokenCallback}
        selectedToken={selectedToken} />
    </SellStyled>
  );
};

const SellLand = ({ sellTokenCallback,
  cancelSaleCallback,
  setTransactionPendingCallback, transactionPending,
  myTokens, setSelectedTokenCallback, selectedToken }: SellViewProps) => {
  const [landPrice, setPrice] = useState<string>("");
  var x = myTokens.length > 0 ? myTokens[0].position.x : 0;
  var y = myTokens.length > 0 ? myTokens[0].position.y : 0;

  const [xCoordinate, setXCoordinate] = useState<number>(!!selectedToken ? selectedToken.position.x : x);
  const [yCoordinate, setYCoordinate] = useState<number>(!!selectedToken ? selectedToken.position.y : y);
  const alert = useAlert()
  React.useEffect(() => {
    if (!!selectedToken) {
      if (selectedToken.id != yCoordinate * 10 + xCoordinate + 1) {
        var selectedTokenOwned = myTokens.filter(token => token.id === yCoordinate * 10 + xCoordinate + 1)
        if (selectedTokenOwned.length > 0) {
          setSelectedTokenCallback(selectedTokenOwned[0])
        }
      }
    }

  }, [selectedToken])
  return (
    <SellLandStyled>
      <SellLandMap
        x={xCoordinate}
        y={yCoordinate}
        landsOwned={myTokens}
        setSelectedTokenCallback={setSelectedTokenCallback}
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
        <SellLandThirdRow>
          <SellLandId>
          <svg>
              <use xlinkHref="/icons/sprites.svg#location" />
            </svg>
            <div>{`${xCoordinate + 1 + 10 * yCoordinate}`}</div>
          </SellLandId>
        </SellLandThirdRow>

        <SellLandSecondRow>
          {myTokens.filter(token => !!selectedToken ? token.id === selectedToken.id : false).length === 0 ? (<> You don't own this land </>) :
            (<> {selectedToken.onSale ? (
              <><CancelLandInput
                value={selectedToken.price / 1000000 + " ꜩ"}
                placeholder="Price (ꜩ)"
              />
                <CancelSaleButton
                  onClick={() => {
                    if (transactionPending) {
                      alert.info("A transaction is pending. Try again later")
                      console.info("A transaction is pending. Try again later")
                    } else {
                      cancelSaleCallback({
                        token_id: selectedToken.id,
                        price: selectedToken.price,
                      }).then(e => {
                        alert.info("Removing land from sales ...")
                        setTransactionPendingCallback(true)
                        e.confirmation().then((e: any) => {
                          alert.success("Land is not on sale anymore", {
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
                  Cancel sale
              </CancelSaleButton>
              </>
            ) : (
                <>
                  <SellLandPriceInput
                    value={landPrice}
                    onChange={(e) => setPrice(e.target.value)}
                    placeholder="Price (ꜩ)"
                  />
                  <SellLandButton
                    onClick={() => {
                      if (transactionPending) {
                        alert.info("A transaction is pending. Try again later")
                        console.info("A transaction is pending. Try again later")
                      } else {
                        sellTokenCallback({
                          token_id: selectedToken.id,
                          price: parseFloat(landPrice),
                        }).then(e => {
                          alert.info("Putting land on sale ...")
                          setTransactionPendingCallback(true)
                          e.confirmation().then((e: any) => {
                            alert.success("Land is on sale", {
                              onOpen: () => {
                                setSelectedTokenCallback({ ...selectedToken, onSale: true });
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
                    Sell this land
        </SellLandButton>
                </>
              )} </>)}

        </SellLandSecondRow>

      </SellLandBottom>
    </SellLandStyled>
  );
};
