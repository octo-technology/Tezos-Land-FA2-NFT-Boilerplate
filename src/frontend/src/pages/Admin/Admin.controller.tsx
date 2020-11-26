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
  const [adminAdress, setAdminAdress] = useState(undefined);
  const [storage, setStorage] = useState(undefined);

  const loadStorage = React.useCallback(async () => {
    if (contract) {
      const storage = await (contract as any).storage();
      setAdminAdress(storage.market.admin);
      setStorage(storage.toString());
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
    xCoordinates: number;
    yCoordinates: number;
    description: string;
    landType: string;
    landName: string;
    owner: string;
    operator?: string;
  };

  const mint = React.useCallback(
    ({
      xCoordinates,
      yCoordinates,
      description,
      landType,
      landName,
      owner,
    }: MintToken) =>
      (contract as any).methods
        .mint(
          xCoordinates,
          yCoordinates,
          description,
          landType,
          [["unit"]],
          landName,
          owner,
          owner
        )
        .send(),
    [contract]
  );

  return (
    <AdminStyled>
      {wallet ? (
        <>
          {ready? (
            <>
              {accountPkh == adminAdress  ? (
                <AdminView
                  mint={mint}
                  connectedUser={(accountPkh as unknown) as string}
                />
              ) : (
                <div>Please connect your wallet</div>
              )}
            </>
          ) : (
            <div>Unauthorized</div>
          )}
        </>
      ) : (
        <div>Please install the Thanos Wallet Chrome Extension.</div>
      )}
    </AdminStyled>
  );
};
