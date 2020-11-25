// prettier-ignore
import { useAccountPkh, useOnBlock, useReady, useTezos, useWallet } from "dapp/dapp";
import { TEZOSLAND_ADDRESS } from "dapp/defaults";
import * as React from "react";
import { useEffect, useState } from "react";

import { AdminStyled } from "./Admin.style";
import { AdminView } from "./Admin.view";

export const Admin = () => {
  const wallet = useWallet();
  const ready = useReady();
  const tezos = useTezos();
  const accountPkh = useAccountPkh();
  const [contract, setContract] = useState(undefined);
  const [storage, setStorage] = useState(undefined);

  const loadStorage = React.useCallback(async () => {
    if (contract) {
      const storage = await (contract as any).storage();
      console.info(`storage: ${JSON.stringify(storage)}`);
      setStorage(storage.toString());
      console.log(accountPkh);
    }
  }, [setStorage, contract]);

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
  }, [tezos]);

  useOnBlock(tezos, loadStorage);

  type MintToken = {
    token_id: string;
    land_type: string;
    owner: string;
    operator?: string;
  };
  const mint = React.useCallback(
    ({ token_id, owner, land_type }: MintToken) =>
      (contract as any).methods
        .mint(land_type, [["unit"]], owner, owner, parseInt(token_id))
        .send(),
    [contract]
  );

  return (
    <AdminStyled>
      {wallet ? (
        <>
          {ready ? (
            <AdminView
              mint={mint}
              connectedUser={(accountPkh as unknown) as string}
            />
          ) : (
            <div>Please connect your wallet.</div>
          )}
        </>
      ) : (
        <div>Please install the Thanos Wallet Chrome Extension.</div>
      )}
    </AdminStyled>
  );
};
