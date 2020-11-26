import { useAccountPkh, useReady, useTezos, useWallet } from "dapp/dapp";
import { TEZOSLAND_ADDRESS } from "dapp/defaults";
import * as React from "react";
import { useEffect, useState } from "react";

import { SellStyled } from "./Sell.style";
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
  landType: LandType;
  isOwned: boolean;
  onSale: boolean;
  price: number;
  id: number;
};

export const Sell = () => {
  const wallet = useWallet();
  const ready = useReady();
  const tezos = useTezos();
  const accountPkh = useAccountPkh();
  const [contract, setContract] = useState(undefined);
  const [myTokens, setMyTokens] = useState<Token[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  
  useEffect(() => {
    (async () => {
      if (tezos) {
        const ctr = await (tezos as any).wallet.at(TEZOSLAND_ADDRESS);
        setContract(ctr);
      }
    })();
  }, [tezos]);

  useEffect(() => {
    (async () => {
      if (contract && accountPkh) {
        const storage = await (contract as any).storage();
        const tokensOwnedFromStorage = await storage.market.owners.get(
          accountPkh
        );
        if (tokensOwnedFromStorage) {
          const tokenIds: number[] = tokensOwnedFromStorage.map(
            (token: { c: any[] }) => token.c[0]
          );

          const myTokens = await Promise.all(tokenIds.map(async (tokenId) => {
            const tokenRaw = await storage.market.lands.get(tokenId.toString());
            const token: Token = {
              name: tokenRaw.name,
              description: tokenRaw.description,
              position: {
                x: tokenRaw.position[6].c[0],
                y: tokenRaw.position[7].c[0]
              },
              landType: LandType.District, // TO FIX
              isOwned: tokenRaw.isOwned,
              onSale: tokenRaw.onSale,
              price: tokenRaw.price, // TO FIX
              id: tokenRaw.id.c[0],
            }
            return token;
          }));

          setMyTokens(myTokens)
          setLoading(false);
        }
      }
    })();
  }, [contract, accountPkh]);

  // useOnBlock(tezos, loadStorage)

  type SellToken = { token_id: number; price: number };
  const sellTokenCallback = React.useCallback(
    ({ token_id, price }: SellToken) => {
      console.log(token_id, price);
      (contract as any).methods.sellLand(price * 1000000, token_id).send();
    },
    [contract]
  );
  type Sale = { token_id: number; price: number };
  const cancelSaleCallback = React.useCallback(
    ({ token_id, price }: Sale) => {
      console.log(token_id, price);
      (contract as any).methods.withdrawFromSale(price, token_id).send();
    },
    [contract]
  );

  return (
    <SellStyled>
      {wallet ? (
        <>
          {ready ? (
            <>
              {myTokens && myTokens.length > 0 ? (
                <SellView sellTokenCallback={sellTokenCallback} cancelSaleCallback={cancelSaleCallback} myTokens={myTokens} />
              ) : (
                <div>
                  {loading ? (
                    <div>Loading lands... Please wait.</div>
                  ) : (
                    <div>No land available</div>
                  )}
                </div>
              )}
            </>
          ) : (
            <div>Please connect your wallet.</div>
          )}
        </>
      ) : (
        <div>Please install the Thanos Wallet Chrome Extension.</div>
      )}
    </SellStyled>
  );
};
