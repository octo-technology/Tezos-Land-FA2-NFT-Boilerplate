import { useAccountPkh, useReady, useTezos, useWallet, useOnBlock } from "dapp/dapp";
import { TEZOSLAND_ADDRESS } from "dapp/defaults";
import * as React from "react";
import { useEffect, useState } from "react";
import { Message, Page } from "styles";

import { BuyView } from "./Buy.view";

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

export type TokenOnSale = {
  name?: string;
  description?: string;
  position: Coordinates;
  landType: LandType;
  isOwned: boolean;
  onSale: boolean;
  owner: string;
  price: number;
  id: number;
  tokenOwnedByUser: boolean;
};

type BuyProp = {
  setTransactionPendingCallback: (b: boolean) => void;
  transactionPending: boolean;
};


export const Buy = ({ setTransactionPendingCallback, transactionPending }: BuyProp) => {
  const wallet = useWallet();
  const ready = useReady();
  const tezos = useTezos();
  const accountPkh = useAccountPkh();
  const [contract, setContract] = useState(undefined);
  const [tokensOnSale, setTokensOnSale] = useState<TokenOnSale[]>([]);
  const [selectedToken, setSelectedToken] = useState<any>();
  const [loading, setLoading] = useState<boolean>(true);

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
      const tokensOnSaleFromStorage = storage["market"].sales;
      const tokenOnSaleIds: number[] = tokensOnSaleFromStorage.map(
        (sale: { token_id: { c: any[] }; price: { c: any[] } }) =>
          sale.token_id.c[0]
      );

      const tokensOnSaleList = await Promise.all(
        tokenOnSaleIds.map(async (tokenId) => {
          const tokenRaw = await storage.market.lands.get(tokenId.toString());
          const token: TokenOnSale = {
            name: tokenRaw.name,
            description: tokenRaw.description,
            position: {
              x: tokenRaw.position[6].c[0],
              y: tokenRaw.position[7].c[0],
            },
            landType: LandType.District, // TO FIX
            isOwned: tokenRaw.isOwned,
            owner: tokenRaw.owner,
            onSale: tokenRaw.onSale,
            price: tokenRaw.price.c[0],
            id: tokenRaw.id.c[0],
            tokenOwnedByUser: accountPkh === tokenRaw.owner,
          };
          return token;
        })
      );
      setTokensOnSale(tokensOnSaleList);
      setSelectedToken(tokensOnSaleList[0]);
      setLoading(false);
    }
  }, [contract, accountPkh, transactionPending]);

  useEffect(() => {
    loadStorage();
  }, [loadStorage, transactionPending]);

  useOnBlock(tezos, loadStorage)

  type BuyToken = { token_id: number; price: number };
  const buyToken = React.useCallback(
    ({ token_id, price }: BuyToken) => {
      return (contract as any).methods
        .buyLand(price, token_id)
        .send({ amount: price / 1000000 });
    },
    [contract]
  );

  return (
    <Page>
      {wallet ? (
        <>
          {ready ? (
            <>
              {tokensOnSale && tokensOnSale.length > 0 ? (
                <BuyView
                  buyTokenCallback={buyToken}
                  tokensOnSale={tokensOnSale}
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
    </Page>
  );
};
