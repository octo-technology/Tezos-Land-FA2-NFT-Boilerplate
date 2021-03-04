import { useAccountPkh, useReady, useTezos, useWallet, useOnBlock } from "dapp/dapp";
import { TEZOSLAND_ADDRESS } from "dapp/defaults";
import * as React from "react";
import { useEffect, useState } from "react";
import { useAlert } from 'react-alert'
import { Message } from "styles";

import { SellView } from "./Sell.view";

export type Coordinates = {
  x: number;
  y: number;
};

export enum LandType {
  Road = "Road",
  Water = "Water",
  Land = "Land",
  District = "District",
  Plaza = "Plaza",
}

export type Token = {
  name?: string;
  description?: string;
  position: Coordinates;
  isOwned: boolean;
  owner: string;
  onSale: boolean;
  price: number;
  id: number;
};

type SellProp = {
  setTransactionPendingCallback: (b: boolean) => void;
  transactionPending: boolean;
};

export const Sell = ({
  transactionPending,
  setTransactionPendingCallback,
}: SellProp) => {
  const wallet = useWallet();
  const ready = useReady();
  const tezos = useTezos();
  const accountPkh = useAccountPkh();
  const [contract, setContract] = useState(undefined);
  const [myTokens, setMyTokens] = useState<Token[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const alert = useAlert()


  useEffect(() => {
    (async () => {
      if (tezos) {
        const ctr = await (tezos as any).wallet.at(TEZOSLAND_ADDRESS);
        setContract(ctr);
      }
    })();
  }, [tezos]);

  const loadStorage = React.useCallback(async () => {
    if (contract && accountPkh) {
      const storage = await (contract as any).storage();
      try {
        const tokensOwnedFromStorage = await storage.market.owners.get(
          accountPkh
        );
        if (tokensOwnedFromStorage) {
          const tokenIds: number[] = tokensOwnedFromStorage.map(
            (token: { c: any[] }) => token.c[0]
          );
          const myTokens = await Promise.all(
            tokenIds.map(async (tokenId) => {
              const tokenRaw = await storage.market.lands.get(
                tokenId.toString()
              );
              const token: Token = {
                name: tokenRaw.name,
                description: tokenRaw.description,
                position: {
                  x: tokenRaw.position[6].c[0],
                  y: tokenRaw.position[7].c[0],
                },
                isOwned: tokenRaw.isOwned,
                owner: tokenRaw.owner,
                onSale: tokenRaw.onSale,
                price: tokenRaw.price, // TO FIX
                id: tokenRaw.id.c[0],
              };
              return token;
            })
          );
          setMyTokens(myTokens);
          setLoading(false);
        }
      } catch (e) {
        alert.show(e.message)
        setLoading(false);
      }
    }
  }, [alert, contract, accountPkh, transactionPending]);

  useEffect(() => {
    loadStorage();
  }, [loadStorage, transactionPending, alert]);

  useOnBlock(tezos, loadStorage)

  type SellToken = { token_id: number; price: number };
  const sellTokenCallback = React.useCallback(
    ({ token_id, price }: SellToken) => {
      return (contract as any).methods
        .sellLand(price * 1000000, token_id)
        .send();
    },
    [contract]
  );
  type Sale = { token_id: number; price: number };
  const cancelSaleCallback = React.useCallback(
    ({ token_id, price }: Sale) => {
      return (contract as any).methods.withdrawFromSale(price, token_id).send();
    },
    [contract]
  );

  return (
    <>
      {wallet ? (
        <>
          {ready ? (
            <>
              {myTokens && myTokens.length > 0 ? (
                <SellView
                  sellTokenCallback={sellTokenCallback}
                  cancelSaleCallback={cancelSaleCallback}
                  myTokens={myTokens}
                  transactionPending={transactionPending}
                  setTransactionPendingCallback={setTransactionPendingCallback}
                />
              ) : (
                  <div>
                    {loading ? (
                      <Message>Loading lands... Please wait.</Message>
                    ) : (
                        <Message>No land available</Message>
                      )}
                  </div>
                )}
            </>
          ) : (
              <Message>Please connect your wallet</Message>
            )}
        </>
      ) : (
          <Message>Please install the Thanos Wallet Chrome Extension.</Message>
        )}
    </>
  );
};
