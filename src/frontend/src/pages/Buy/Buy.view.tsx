import { LandMap } from "app/App.components/LandMap/LandMap.view";
import { useAlert } from "react-alert";

import { Button } from "../../app/App.components/TinyButton/Button.controller";
import { TokenOnSale } from "./Buy.controller";
// prettier-ignore
import { BuyLandBottom, BuyLandButton, BuyLandData, BuyLandFirstRow, BuyLandFourthRow, BuyLandSecondRow, BuyLandStyled, BuyLandThirdRow, BuyStyled } from "./Buy.style";

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
  setTransactionPendingCallback,
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
  setTransactionPendingCallback,
}: {
  buyTokenCallback: (buyProps: BuyProps) => Promise<any>;
  tokenOnSale: TokenOnSale;
  setTransactionPendingCallback: (b: boolean) => void;
  transactionPending: boolean;
}) => {
  const alert = useAlert();

  return (
    <BuyLandStyled key={tokenOnSale.id}>
      <LandMap x={tokenOnSale.position.x} y={tokenOnSale.position.y} />

      <BuyLandBottom>
        <BuyLandFirstRow>
          <BuyLandData>
            <svg>
              <use xlinkHref="/icons/sprites.svg#location" />
            </svg>
            <div>{`${tokenOnSale.position.x}, ${tokenOnSale.position.y}`}</div>
          </BuyLandData>
          <BuyLandData>
            <svg>
              <use xlinkHref="/icons/sprites.svg#barcode" />
            </svg>
            <div>{tokenOnSale.id}</div>
          </BuyLandData>
          <BuyLandData>
            <svg>
              <use xlinkHref="/icons/sprites.svg#price" />
            </svg>
            <div>{tokenOnSale.price / 1000000} ꜩ</div>
          </BuyLandData>
        </BuyLandFirstRow>

        <BuyLandThirdRow>
          <BuyLandData>
            <svg>
              <use xlinkHref="/icons/sprites.svg#owner" />
            </svg>
            <div>{tokenOnSale.owner}</div>
          </BuyLandData>
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
                  alert.info("A transaction is pending. Try again later");
                  console.info("A transaction is pending. Try again later");
                } else {
                  buyTokenCallback({
                    token_id: tokenOnSale.id,
                    price: tokenOnSale.price,
                  })
                    .then((e) => {
                      alert.info("Buying land ...");
                      setTransactionPendingCallback(true);
                      e.confirmation().then((e: any) => {
                        alert.success("Land bought", {
                          onOpen: () => {
                            setTransactionPendingCallback(false);
                          },
                        });

                        return e;
                      });
                      return e;
                    })
                    .catch((e: any) => {
                      alert.show(e.message);
                      console.error(e.message);
                    });
                }
              }}
              loading={transactionPending}
            />
          )}
        </BuyLandFourthRow>
      </BuyLandBottom>
    </BuyLandStyled>
  );
};
