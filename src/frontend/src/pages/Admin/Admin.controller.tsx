// prettier-ignore
import { useAccountPkh, useOnBlock, useReady, useTezos, useWallet } from "dapp/dapp";
import { TEZOSLAND_ADDRESS } from "dapp/defaults";
import * as React from "react";
import { useEffect, useState } from "react";
import { Message, Page } from "styles";

import { AdminView } from "./Admin.view";

export type Coordinates = {
  x: number;
  y: number;
};

type AdminProp = {
  setMintTransactionPendingCallback: (b: boolean) => void;
  mintTransactionPending: boolean;
};

export const Admin = ({
  setMintTransactionPendingCallback,
  mintTransactionPending,
}: AdminProp) => {
  const wallet = useWallet();
  const ready = useReady();
  const tezos = useTezos();
  const accountPkh = useAccountPkh();
  const [contract, setContract] = useState(undefined);
  const [adminAdress, setAdminAdress] = useState(undefined);
  const [existingTokenIds, setExistingTokenIds] = useState<Array<number>>([]);

  const loadStorage = React.useCallback(async () => {
    if (contract) {
      const storage = await (contract as any).storage();
      setExistingTokenIds(
        storage["market"].landIds.map(
          (landIdAsObject: { c: any[] }) => landIdAsObject.c[0]
        )
      );
      setAdminAdress(storage.market.admin);
    }
  }, [contract]);

  useEffect(() => {
    loadStorage();
  }, [loadStorage]);

  useEffect(() => {
    (async () => {
      if (tezos) {
        const ctr = await (tezos as any).wallet.at(TEZOSLAND_ADDRESS);
        setContract(ctr);
      }
    })();
  }, [tezos, mintTransactionPending]);

  useOnBlock(tezos, loadStorage);

  type MintToken = {
    xCoordinates: number;
    yCoordinates: number;
    description: string;
    landName: string;
    owner: string;
    operator?: string;
  };

  const mint = React.useCallback(
    ({
      xCoordinates,
      yCoordinates,
      description,
      landName,
      owner,
    }: MintToken) => {
      return (contract as any).methods
        .mint(xCoordinates, yCoordinates, description, landName, owner, owner)
        .send();
    },
    [contract]
  );

  return (
    <Page>
      {wallet ? (
        <>
          {ready ? (
            <>
              {accountPkh === adminAdress ? (
                <AdminView
                  mintCallBack={mint}
                  connectedUser={(accountPkh as unknown) as string}
                  existingTokenIds={existingTokenIds}
                  setMintTransactionPendingCallback={
                    setMintTransactionPendingCallback
                  }
                  mintTransactionPending={mintTransactionPending}
                />
              ) : (
                <Message>You are not the admin of this smart contract</Message>
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
