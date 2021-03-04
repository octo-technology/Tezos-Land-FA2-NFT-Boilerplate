import { LandMap } from "app/App.components/LandMap/LandMap.view";
import * as React from "react";
import { useAlert } from 'react-alert'

import { TokenOnSale } from "./Buy.controller";
// prettier-ignore
import {
  BuyLandBottom,
  BuyLandButton,
  BuyLandFirstRow,
  BuyLandSecondRow,
  BuyLandThirdRow,
  BuyLandLocation,
  BuyLandOwner,
  BuyLandOnSale,
  BuyLandFourthRow,
  BuyLandStyled,
  BuyLandId,
  BuyStyled
} from "./Buy.style";

import {Button} from "../../app/App.components/TinyButton/Button.controller"


type BuyProps = {
  token_id: number;
  price: number;
};

type BuyViewProps = {
  buyTokenCallback: (sellProps: BuyProps) => Promise<any>;
  setTransactionPendingCallback: (b: boolean) => void;
  transactionPending: boolean;
  tokensOnSale: TokenOnSale[];
};

export const BuyView = ({
  buyTokenCallback: buyToken,
  tokensOnSale,
  transactionPending,
  setTransactionPendingCallback
}: BuyViewProps) => {
  return (
    <BuyStyled>
      {tokensOnSale.map((myToken) => (
        <BuyLand
          key={myToken.id}
          buyTokenCallback={buyToken}
          tokenOnSale={myToken}
          setTransactionPendingCallback={setTransactionPendingCallback}
          transactionPending={transactionPending}
        />
      ))}
    </BuyStyled>
  );
};

const BuyLand = ({
  buyTokenCallback,
  tokenOnSale,
  transactionPending,
  setTransactionPendingCallback
}: {
  buyTokenCallback: (buyProps: BuyProps) => Promise<any>;
  tokenOnSale: TokenOnSale;
  setTransactionPendingCallback: (b: boolean) => void;
  transactionPending: boolean;
}) => {
  const alert = useAlert()

  return (
    <BuyLandStyled key={tokenOnSale.id}>
      <LandMap x={tokenOnSale.position.x} y={tokenOnSale.position.y} />

      <BuyLandBottom>
        <BuyLandFirstRow>
          <BuyLandLocation>
            <svg>
              <use xlinkHref="/icons/sprites.svg#location2" />
            </svg>
            <div>{`${tokenOnSale.position.x}, ${tokenOnSale.position.y}`}</div>
          </BuyLandLocation>
          <BuyLandOnSale>
            On sale for {tokenOnSale.price / 1000000} ꜩ{" "}
          </BuyLandOnSale>
        </BuyLandFirstRow>
        <BuyLandSecondRow>
          <BuyLandId>
            <svg>
              <use xlinkHref="/icons/sprites.svg#barcode" />
            </svg>
            <div>{tokenOnSale.id}</div>
          </BuyLandId>
        </BuyLandSecondRow>
        <BuyLandThirdRow>
          <BuyLandOwner>
            <svg>
              <use xlinkHref="/icons/sprites.svg#owner" />
            </svg>
            <div>{tokenOnSale.owner}</div>
          </BuyLandOwner>
        </BuyLandThirdRow>

        <BuyLandFourthRow>
          {tokenOnSale.tokenOwnedByUser ? (
            <div>You are the owner</div>
          ) : (
<Button
          text={"Buy this land"}
          color={"primary"}
          onClick={() => {
            if (transactionPending) {
              alert.info("A transaction is pending. Try again later")
              console.info("A transaction is pending. Try again later")
            } else {
              buyTokenCallback({
                token_id: tokenOnSale.id,
                price: tokenOnSale.price,
              }).then(e => {
                alert.info("Buying land ...")
                setTransactionPendingCallback(true)
                e.confirmation().then((e: any) => {
                  alert.success("Land bought", {
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
          loading={transactionPending} />
            )}
        </BuyLandFourthRow>
        
      </BuyLandBottom>
    </BuyLandStyled>
  );
};