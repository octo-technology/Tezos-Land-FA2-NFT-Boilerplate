import { LandMap } from "app/App.components/LandMap/LandMap.view";
import * as React from "react";
import { useState } from "react";
import { useAlert } from 'react-alert'

import { Token } from "./Sell.controller";
// prettier-ignore
import {
  CancelSaleButton,
  SellLandBottom,
  SellLandButton,
  SellLandLocation,
  SellLandOnSale,
  SellLandPriceInput,
  SellLandFirstRow,
  SellLandSecondRow,
  SellLandThirdRow,
  SellLandFourthRow,
  SellLandStyled,
  SellStyled,
  SellLandId,
  SellLandOwner
} from "./Sell.style";

type SellProps = {
  token_id: number;
  price: number;
};

type CancelPorps = {
  token_id: number;
  price: number;
};

type SellViewProps = {
  sellTokenCallback: (sellProps: SellProps) => Promise<any>;
  cancelSaleCallback: (cancelProps: CancelPorps) => Promise<any>;
  setTransactionPendingCallback: (transactionPending: boolean) => void;
  transactionPending: boolean;
  myTokens: Token[];
};

export const SellView = ({
  sellTokenCallback,
  cancelSaleCallback,
  transactionPending,
  setTransactionPendingCallback,
  myTokens,
}: SellViewProps) => {
  return (
    <SellStyled>
      {myTokens.map((myToken) => (
        <SellLand
          key={myToken.id}
          sellTokenCallback={sellTokenCallback}
          cancelSaleCallback={cancelSaleCallback}
          transactionPending={transactionPending}
          setTransactionPendingCallback={setTransactionPendingCallback}
          myToken={myToken}
        />
      ))}
    </SellStyled>
  );
};

const SellLand = ({
  sellTokenCallback,
  cancelSaleCallback,
  setTransactionPendingCallback,
  transactionPending,
  myToken
}:
  {
    sellTokenCallback: (sellProps: SellProps) => Promise<any>;
    cancelSaleCallback: (cancelProps: CancelPorps) => Promise<any>;
    setTransactionPendingCallback: (transactionPending: boolean) => void;
    transactionPending: boolean;
    myToken: Token;
  }
) => {
  const [price, setPrice] = useState<string>("");
  const alert = useAlert()

  return (
    <SellLandStyled key={myToken.id}>
      <LandMap x={myToken.position.x} y={myToken.position.y} />

      <SellLandBottom>
        <SellLandFirstRow>
          <SellLandLocation>
            <svg>
              <use xlinkHref="/icons/sprites.svg#location2" />
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
          <SellLandId>
            <svg>
              <use xlinkHref="/icons/sprites.svg#barcode" />
            </svg>
            <div>{myToken.id}</div>
          </SellLandId>
        </SellLandSecondRow>
        <SellLandThirdRow>
          <SellLandOwner>
            <svg>
              <use xlinkHref="/icons/sprites.svg#owner" />
            </svg>
            <div>{myToken.owner}</div>
          </SellLandOwner>
        </SellLandThirdRow>
        <SellLandFourthRow>
          {myToken.onSale ? (
            <>
              <CancelSaleButton
                onClick={() => {
                  if (transactionPending) {
                    alert.info("A transaction is pending. Try again later")
                    console.info("A transaction is pending. Try again later")
                  } else {
                    cancelSaleCallback({
                      token_id: myToken.id,
                      price: myToken.price,
                    }).then(e => {
                      alert.info("Removing land from sales ...")
                      setTransactionPendingCallback(true)
                      e.confirmation().then((e: any) => {
                        alert.success("Land is not on sale anymore", {
                          onOpen: () => {
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
                  value={price}
                  onChange={(e) => setPrice(e.target.value)}
                  placeholder="Enter price"
                />
                <SellLandButton
                  onClick={() => {
                    if (transactionPending) {
                      alert.info("A transaction is pending. Try again later")
                      console.info("A transaction is pending. Try again later")
                    } else {
                      sellTokenCallback({
                        token_id: myToken.id,
                        price: parseFloat(price),
                      }).then(e => {
                        alert.info("Putting land on sale ...")
                        setTransactionPendingCallback(true)
                        e.confirmation().then((e: any) => {
                          alert.success("Land is on sale", {
                            onOpen: () => {
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
                  Sell
              </SellLandButton>
              </>
            )}
        </SellLandFourthRow>
      </SellLandBottom>
    </SellLandStyled>
  );
};