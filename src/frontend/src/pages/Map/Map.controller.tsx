import { useAccountPkh, useReady, useTezos, useWallet } from "dapp/dapp";
import { TEZOSLAND_ADDRESS } from "dapp/defaults";
import * as React from "react";
import { useEffect, useState } from "react";
import { Message, Page } from "styles";
import { compose, TezosToolkit } from '@taquito/taquito';
import { MapView } from "./Map.view";

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
  owner: string
  onSale: boolean;
  price: number;
  id: number;
};

type MapProp = {
  transactionPending: boolean;
};

export const Map = ({
  transactionPending
}: MapProp) => {
  const rpcProvider: string = "https://edonet.smartpy.io"
  const tk: TezosToolkit = new TezosToolkit(rpcProvider);
  const [contractTaquito, setContractTaquito] = useState(undefined);
  const [tokens, setTokens] = useState<Token[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    (async () => {
      const contract2: any = await tk.contract.at("KT1GuwfE5nrLzKizwnqbP5or2jKqPAGC8EfJ");
      setContractTaquito(contract2)
    })();
  }, [transactionPending]);

  useEffect(() => {
    (async () => {
      if (contractTaquito) {
        const storage: any = await (contractTaquito as any).storage();
        const landIds = storage["market"].landIds
        if (landIds) {
          const tokenIds: number[] = landIds.map(
            (token: { c: any[] }) => token.c[0]
          );
          const tokens2 = await Promise.all(tokenIds.map(async (tokenId) => {
            const tokenRaw = await storage.market.lands.get(tokenId.toString());
            const token: Token = {
              name: tokenRaw.name,
              description: tokenRaw.description,
              position: {
                x: tokenRaw.position[6].c[0],
                y: tokenRaw.position[7].c[0]
              },
              landType: LandType.District,
              isOwned: tokenRaw.isOwned,
              owner: tokenRaw.owner,
              onSale: tokenRaw.onSale,
              price: tokenRaw.price,
              id: tokenRaw.id.c[0],
            }
            return token;
          }));
          setTokens(tokens2)
          setLoading(false);
        }
      }
    })();
  }, [contractTaquito]);

  // useOnBlock(tezos, loadStorage)  

  return (
    <Page>
      {tokens && tokens.length > 0 ? (
        <MapView existingTokens={tokens} />
      ) : (
        <div>
          {loading ? (
            <Message>Loading lands... Please wait.</Message>
          ) : (
            <Message>No land available</Message>
          )}
        </div>
      )}
    </Page>
  );
};
